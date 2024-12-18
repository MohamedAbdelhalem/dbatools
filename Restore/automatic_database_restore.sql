USE [master]
GO
/****** Object:  StoredProcedure [dbo].[automatic_database_restore]    Script Date: 8/1/2023 3:20:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER
PROCEDURE [dbo].[automatic_database_restore]
( 
@before_date				datetime		= '2022-12-07 05:00:00', 
@db_restore_name			varchar(500)	= 'T24Prod',
@username					varchar(100)	= 'T24login',
--@locations parameter used for any restore request on December 2022 and to use it make @workaround_loc = 1
@locations					varchar(max)	= '\\npci2.d2fs.albilad.com\T24_BK_staging_FULL\;\\npci2.d2fs.albilad.com\T24_BK_staging\DIFF\;\\npci2.d2fs.albilad.com\T24_BK_staging_LOGS\',
@workaround_loc				bit				= 1,
--@SDC_backup_path & @PDC_backup_path parameters used for any restore request befor December 2022 and to use those pathes make @workaround_loc = 0
@SDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\',
@PDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\',
--if the restore has any issues and stopped after some backup files like after differential the logs unable to restore for some reseans you can continue after the diffential 
--by add in this parameter @continue_after_file_number = 2 "this is an example"
@continue_after_file_number int				= 0,
@isAG						int				= 0,
@dbrecovery					bit				= 1,
@action						int				= 1
--1 = show backup files
--2 = only restore 
--3 = 1 + 2
--4 = 1 (show backup files) without update the metadata
--5 = 2 (only restore)		without update the metadata
--6 = 4 + 5					without update the metadata
)
as
begin
declare @final_table table (id int identity(1,1), backup_type varchar(100), backup_time_from datetime, backup_time_to datetime, 
backup_file_name varchar(1000), with_stopat varchar(100), [recovery] tinyint)

declare 
@full_backup_end_date		datetime, 
@full_backup_start_date		datetime,
@checkpointLSN				numeric(25),
@diff_backup_end_date		datetime,
@logs_backup_end_date		datetime,
@logs_backup_start_date		datetime,
@backup_file_full_path		varchar(3000),
@directory_map				varchar(2000),
@backup_type				varchar(4),
@backup_time				datetime, 
@backup_time_from			datetime, 
@backup_time_to				datetime, 
@stopat						varchar(100),
@recovery					tinyint,
@max_id						int, 
@max_file_name				varchar(2000),
@error						varchar(2000),
@add_username				varchar(2000),
@backup_file_name			varchar(2000),
@change_recovery_setting	varchar(1000),
@add_db_on_ag				varchar(1000),
@ag_name					varchar(1000),
@using_workaround			int,
@max_available_BackupStartDate datetime

select @using_workaround = case when @before_date < '2022-12-01' then 0 else 1 end
from master.dbo.auto_restore_job_parameters

if @action in (1,2,3)
begin
exec master.dbo.update_backups_metadata
@before_date = @before_date
end

select top 1 
@full_backup_start_date = BackupStartDate,
@full_backup_end_date = BackupFinishDate, 
@checkpointLSN = CheckpointLSN
from table_header
where BackupFinishDate in (
select max(BackupFinishDate) BackupFinishDate
from table_header
where BackupFinishDate <= @before_date
and BackupTypeDescription = 'Database')
and BackupTypeDescription = 'Database'

select @diff_backup_end_date = 
max(BackupFinishDate)
from table_header
where BackupfinishDate between @full_backup_end_date and @before_date 
and BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN

select @logs_backup_end_date =
min(BackupStartDate)
from (
select 
BackupStartDate,
case when @before_date between isnull(LAG(BackupStartDate,1) over(order by BackupStartDate ),0) and BackupStartDate
then 1 else 0 end end_file
from table_header
where BackupTypeDescription = 'Transaction Log'
and DatabaseBackupLSN = @checkpointLSN
and BackupStartDate >= isnull(@diff_backup_end_date, @full_backup_end_date))a
where end_file = 1

select @logs_backup_start_date =
max(BackupStartDate)
from (
select 
BackupStartDate,
case when isnull(@diff_backup_end_date, @full_backup_end_date) between BackupStartDate and LAG(BackupFinishDate,1,1) over(order by BackupStartDate desc) then 1 else 0 end start_file
from table_header
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate between @full_backup_start_date and @before_date
--and DatabaseBackupLSN = @checkpointLSN
)a
where start_file = 1

--select @logs_backup_start_date

--if start backup logs result is null then means that there is log backup file with 2 checkpoints 
--example last log backup start at 11:00:05 finished 11:00:24 and the full backup finished at 11:00:11 and the next log backup starts at 11:10:18 
--then we have 13 seconds missing between 11:00:11 and 11:00:24 and that needs to be restored before the first log backup with the same LSN (checkpoint of the full backup)
--select @logs_backup_start_date = case when @logs_backup_start_date is null then (select top 1 BackupStartDate
--														from table_header
--														where BackupTypeDescription = 'Transaction Log'
--														and BackupFinishDate > isnull(@logs_backup_start_date,isnull(@diff_backup_end_date, @full_backup_end_date)) order by BackupStartDate) end

select @max_available_BackupStartDate = max(BackupStartDate) from table_header where BackupTypeDescription = 'Transaction Log'

select @directory_map = directorys_map 
from master.dbo.restore_loction_groups

insert into @final_table
select BackupTypeDescription, BackupStartDate, BackupFinishDate, backup_file_name, [with_stopat],
case when id = total_files and @before_date between lag(BackupFinishDate,1,1) over(order by BackupFinishDate) and BackupFinishDate  then 1 else 0 end [recovery]
from (
select row_number() over(order by BackupStartDate) id, count(*) over() total_files, BackupTypeDescription, BackupStartDate, BackupFinishDate, 
case 
when BackupTypeDescription = 'Transaction Log' and last_file = 1 and @before_date between lag(BackupFinishDate,1,1) over(order by BackupFinishDate) and BackupFinishDate then 'STOPAT = '+''''+convert(varchar(40), @before_date, 120)+''''+'' 
else 'default' end [with_stopat], backup_file_name
from (

select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from (
select distinct DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name
from table_header
where BackupTypeDescription = 'Database'
and checkpointLSN = @checkpointLSN
and BackupFinishDate = @full_backup_end_date)fb

union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from (
select distinct DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name
from table_header
where BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN
and BackupFinishDate = @diff_backup_end_date)db

union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from (
select distinct DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name
from table_header
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate between isnull(@logs_backup_start_date,isnull(@diff_backup_end_date, @full_backup_end_date)) and isnull(@logs_backup_end_date, @max_available_BackupStartDate))lb
--and BackupStartDate between isnull(@diff_backup_end_date, @full_backup_end_date) and isnull(@logs_backup_end_date, @max_available_BackupStartDate))lb
)a)b
order by BackupStartDate 

--and here to filler out the specific backup files 

if @action in (1,4)
begin
	select distinct * from @final_table
	where id > @continue_after_file_number
	order by backup_time_from 
end
else
if @action in (2,3,5,6)
begin
	if @action in (3,6)
	begin
		select distinct * from @final_table
		where id > @continue_after_file_number
		order by backup_time_from 
	end

	select @max_id = id - @continue_after_file_number, @max_file_name = backup_file_name
	from @final_table
	where id in (select max(id) from @final_table)
	and id > @continue_after_file_number
	
	declare restore_cur cursor fast_forward
	for
	select backup_file_name, [with_stopat], case when @isAG in (0,1) then [recovery] else 0 end
	from @final_table
	where id > @continue_after_file_number
	order by id

	update master.dbo.restore_notification set status = 1
	
	insert into master.dbo.restore_notification
	(database_name, status, start_time, total_files, current_file, last_file_name)
	values
	(@db_restore_name, 0, getdate(), @max_id - @continue_after_file_number, 1, @max_file_name)

	--select @db_restore_name, 0, getdate(), @max_id, 1, @max_file_name

	exec master.[dbo].[kill_sessions_before_restore] @type = 'database', @name = @db_restore_name
	exec master.[dbo].[kill_sessions_before_restore] @type = 'database', @name = @db_restore_name

	EXEC msdb.dbo.sp_update_job  
    @job_name = N'Notification Restore',  
    @enabled = 1  

	exec dbo.XEvent_errors @@spid

	open restore_cur 
	fetch next from restore_cur into @backup_file_name, @stopat, @recovery
	while @@fetch_status = 0
	begin
			exec [master].[dbo].[sp_restore_database_distribution_groups]
			@backupfile					= @backup_file_name,
			@option_04					= 1,
			@number_of_files_per_type	= '2-4',  --"2" is the file type id, and "4" is the number of files per location
			@restore_loction_groups		= @directory_map,
			@with_recovery				= @recovery,  
			@new_db_name				= @db_restore_name,
			@percent					= 5,
			@replace					= 1,
			@log_stopat					= @stopat,
			@action						= 3

			update master.dbo.restore_notification 
			set 
			status				= case when @max_id = (select current_file from restore_notification where status = 0) + 1 + @continue_after_file_number then 1 else 0 end,
			finish_time			= case when @max_id = (select current_file from restore_notification where status = 0) + 1 + @continue_after_file_number then getdate() else null end,
			current_file		= current_file + 1
			where status		= 0
			and database_name	= @db_restore_name

	fetch next from restore_cur into @backup_file_name, @stopat, @recovery
	end
	close restore_cur
	deallocate restore_cur
end
set nocount off


if	(select count(*) from master.dbo.restore_notification where status = 0) = 0 and
	(select enabled from msdb.dbo.sysjobs where name = 'Notification Restore') = 1
begin

	exec [master].[dbo].[sp_notification_restore]
			@done = 1,
			@ccteam = 't24 team'
	exec [msdb].[dbo].[sp_update_job]  
			@job_name = 'Notification Restore',  
			@enabled = 0

set @add_username = 'use ['+@db_restore_name+']
declare @username varchar(300)
declare @loginname varchar(300)

select @username = name 
from sys.sysusers 
where issqlrole = 0
and name = '+''''+@username+''''+'

select @loginname = loginname 
from sys.syslogins 
where loginname = '+''''+@username+''''+'

if @username is not null and @loginname is not null
begin
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end
else
if @username is null and @loginname is not null
begin
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is not null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end'
exec(@add_username)

if @dbrecovery = 1 and @isAG = 0
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	exec(@change_recovery_setting)
end

if @dbrecovery = 1 and @isAG = 1
begin
	-- you can add here a logic for multi-groups but i will just use the first ag that supose it's the only ag.
	select top 1 @ag_name = name from sys.availability_groups
	set @add_db_on_ag = 'use [master] 
	ALTER AVAILABILITY GROUP ['+@ag_name+'] ADD DATABASE ['+@db_restore_name+'];'
	exec(@add_db_on_ag)
end
else
if @dbrecovery = 0 and @isAG = 2
begin
	select top 1 @ag_name = name from sys.availability_groups
	set @add_db_on_ag = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET HADR AVAILABILITY GROUP = ['+@ag_name+'];'
	exec(@add_db_on_ag)
end

exec master.dbo.set_compatibility @db_restore_name
end

set @add_username = 'use ['+@db_restore_name+']
declare @username varchar(300)
declare @loginname varchar(300)

select @username = name 
from sys.sysusers 
where issqlrole = 0
and name = '+''''+@username+''''+'

select @loginname = loginname 
from sys.syslogins 
where loginname = '+''''+@username+''''+'

if @username is not null and @loginname is not null
begin
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end
else
if @username is null and @loginname is not null
begin
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is not null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end'
if @action = 1
begin
print(@add_username)
if @dbrecovery = 1 and @isAG = 0
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	print(@change_recovery_setting)
end
if @dbrecovery = 1 and @isAG = 1
begin
	-- you can add here a logic for multi-groups but i will just use the first ag that supose it's the only ag.
	select top 1 @ag_name = name from sys.availability_groups
	set @add_db_on_ag = 'use [master] 
	ALTER AVAILABILITY GROUP ['+@ag_name+'] ADD DATABASE ['+@db_restore_name+'];'
	print(@add_db_on_ag)
end
else
if @dbrecovery = 0 and @isAG = 2
begin
	select top 1 @ag_name = name from sys.availability_groups
	set @add_db_on_ag = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET HADR AVAILABILITY GROUP = ['+@ag_name+'];'
	print(@add_db_on_ag)
end
end
report:
if @action in (2,3,5,6)
begin
exec [dbo].[errors_email] 
@project_name			 ='T24SDC6 restore',
@ccteam					 = '', 
@dba_in_to				 = 'ALBILAD\c904529',
@with_cc				 = 0,
@spid					 = @@spid
exec [dbo].[XEvent_errors] @@spid, 0
end
end
