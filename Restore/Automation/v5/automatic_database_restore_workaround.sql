CREATE 
PROCEDURE [dbo].[automatic_database_restore_workaround]
( 
@before_date				datetime		= '2022-12-07 05:00:00', 
@db_restore_name			varchar(500)	= 'T24Prod',
@username					varchar(100)	= 'T24login',
@locations					varchar(max)	= '\\npci2.d2fs.albilad.com\T24_BK_staging_FULL\;\\npci2.d2fs.albilad.com\T24_BK_staging\DIFF\;\\npci2.d2fs.albilad.com\T24_BK_staging_LOGS\',
@workaround_loc				bit				= 1,
@SDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\',
@PDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\',
@continue_after_file_number int				= 0,
@dbrecovery					bit				= 1,
@action						int				= 1
--1 = show backup files
--2 = begin restore 
--3 = 1 + 2
)
as
begin
declare @final_table table (id int identity(1,1), backup_type varchar(100), backup_time_from datetime, backup_time_to datetime, 
backup_file_name varchar(1000), with_stopat varchar(100), [recovery] tinyint)

declare @backup_files table (backup_type varchar(10), backup_time datetime, backup_file_name varchar(2000))
declare @full table (output_text varchar(1000), directory varchar(3000))
declare @diff table (output_text varchar(1000), directory varchar(3000))
declare @logs table (output_text varchar(1000), directory varchar(3000))
declare 
@xp_folder_full_f_SDC		varchar(1000),
@xp_folder_full_f_PDC		varchar(1000),
@xp_folder_full_t_SDC		varchar(1000),
@xp_folder_full_t_PDC		varchar(1000),
@xp_folder_diff_f_SDC		varchar(1000),
@xp_folder_diff_f_PDC		varchar(1000),
@xp_folder_diff_t_SDC		varchar(1000),
@xp_folder_diff_t_PDC		varchar(1000),
@xp_folder_logs_f_SDC		varchar(1000),
@xp_folder_logs_f_PDC		varchar(1000),
@xp_folder_logs_t_SDC		varchar(1000),
@xp_folder_logs_t_PDC		varchar(1000),
@month_f					varchar(20),
@month_t					varchar(20),
@year_f						varchar(4),
@year_t						varchar(4),
@date_time_f				datetime,
@date_time_t				datetime,
@directory_map				varchar(2000),
@backup_type				varchar(4),
@backup_time				datetime, 
@backup_time_from			datetime, 
@backup_time_to				datetime, 
@backup_file_name			varchar(2000), 
@stopat						varchar(100),
@recovery					tinyint,
@max_id						int, 
@max_file_name				varchar(2000),
@error						varchar(2000),
@add_username				varchar(2000),
@change_recovery_setting	varchar(1000)

declare 
@backup_pathes_workaround varchar(2000),
@xp_backup_pathes_workaround varchar(2000)
set nocount on

declare @sql_restore_header varchar(max)
declare @table_header table (
col01 varchar(500),col02 varchar(500),col03 varchar(500),col04 varchar(500),col05 varchar(500),col06 varchar(5),
col07 varchar(max),col08 varchar(100),col09 varchar(500),DatabaseName varchar(500),col11 varchar(max),
col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),CheckpointLSN numeric(25),DatabaseBackupLSN numeric(25),BackupStartDate datetime,
BackupFinishDate datetime,col18 varchar(max),col19 varchar(max),col20 varchar(max),col21 varchar(max),
col22 varchar(max),col23 varchar(max),col24 varchar(max),col25 varchar(max),col26 varchar(max),
col27 varchar(max),col28 varchar(max),col29 varchar(max),col30 varchar(max),col31 varchar(max),
col32 varchar(max),col33 varchar(max),col34 varchar(max),col35 varchar(max),col36 varchar(max),
col37 varchar(max),col38 varchar(max),col39 varchar(max),col40 varchar(max),col41 varchar(max),
col42 varchar(max),col43 varchar(max),col44 varchar(max),col45 varchar(max),col46 varchar(max),
col47 varchar(100),BackupTypeDescription varchar(max),col49 varchar(max),col50 varchar(100),col51 varchar(max),
col52 varchar(max),col53 varchar(max),col54 varchar(max), backup_file_name varchar(max))

select 
@date_time_f = convert(varchar(10), dateadd(day, -10, @before_date),120), 
@year_f = year(dateadd(day, -10, @before_date)),
@month_f = case month(dateadd(day, -10, @before_date))
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end,
@date_time_t = DATEADD(HOUR, 1, @before_date),
@year_t = year(DATEADD(HOUR, 1, @before_date)),
@month_t = case month(DATEADD(HOUR, 1, @before_date))
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end

if @workaround_loc = 0
begin
if month(@date_time_f) = month(@date_time_t)
begin 
set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

end
else if month(@date_time_f) != month(@date_time_t)
begin 

set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_t_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_full_t_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_t_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_t_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_t_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_t_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_full_t_SDC)
print(@xp_folder_full_t_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_diff_t_SDC)
print(@xp_folder_diff_t_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)
print(@xp_folder_logs_t_SDC)
print(@xp_folder_logs_t_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_SDC
update @full set directory = replace(substring(@xp_folder_full_t_SDC,charindex('\',@xp_folder_full_t_SDC),len(@xp_folder_full_t_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_PDC
update @full set directory = replace(substring(@xp_folder_full_t_PDC,charindex('\',@xp_folder_full_t_PDC),len(@xp_folder_full_t_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_SDC
update @diff set directory = replace(substring(@xp_folder_diff_t_SDC,charindex('\',@xp_folder_diff_t_SDC),len(@xp_folder_diff_t_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_PDC
update @diff set directory = replace(substring(@xp_folder_diff_t_PDC,charindex('\',@xp_folder_diff_t_PDC),len(@xp_folder_diff_t_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_SDC
update @logs set directory = replace(substring(@xp_folder_logs_t_SDC,charindex('\',@xp_folder_logs_t_SDC),len(@xp_folder_logs_t_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_PDC
update @logs set directory = replace(substring(@xp_folder_logs_t_PDC,charindex('\',@xp_folder_logs_t_PDC),len(@xp_folder_logs_t_PDC)),'"','') where directory is null

end
end
else
begin
declare cursor_pathes cursor fast_forward
for
select value from master.dbo.Separator(@locations,';')

open cursor_pathes 
fetch next from cursor_pathes into @backup_pathes_workaround
while @@FETCH_STATUS = 0
begin

set @xp_backup_pathes_workaround = 'dir cd "'+@backup_pathes_workaround+'"'
print(@xp_backup_pathes_workaround)

if @backup_pathes_workaround like '%Full%'
begin
insert into @full (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @full set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
else
if @backup_pathes_workaround like '%DIFF%'
begin
insert into @diff (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @diff set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
else
if @backup_pathes_workaround like '%LOGS%'
begin
insert into @logs (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @logs set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
fetch next from cursor_pathes into @backup_pathes_workaround
end
close cursor_pathes
deallocate cursor_pathes

end

--select * from @full 
--select * from @diff 
--select * from @logs 

--all above are only to get the backup files from which months like it's from july and august on the same year or only on august of this year

insert into @backup_files
(backup_type, backup_time, backup_file_name)
select distinct 'full' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @full
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select distinct 'diff' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @diff
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select distinct 'log' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @logs
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'

-- here to insert into @backup_files all backup files on the whole chosen month(s)

declare restore_header_cursor cursor fast_forward
for
select backup_file_name 
from @backup_files

open restore_header_cursor
fetch next from restore_header_cursor into @backup_file_name
while @@FETCH_STATUS = 0
begin

set @sql_restore_header = 'restore headeronly from disk = '+''''+@backup_file_name+''''

insert into @table_header
([col01], [col02], [col03], [col04], [col05], [col06], [col07], [col08], [col09], [DatabaseName], [col11], [col12], [col13], [col14], [col15], 
[CheckpointLSN], [DatabaseBackupLSN], [BackupStartDate], [BackupFinishDate], [col18], [col19], [col20], [col21], [col22], [col23], [col24], [col25], 
[col26], [col27], [col28], [col29], [col30], [col31], [col32], [col33], [col34], [col35], [col36], [col37], [col38], [col39], [col40], [col41], [col42], 
[col43], [col44], [col45], [col46], [col47], [BackupTypeDescription], [col49], [col50], [col51], [col52], [col53], [col54])
exec(@sql_restore_header)

update @table_header set backup_file_name = @backup_file_name where backup_file_name is null

fetch next from restore_header_cursor into @backup_file_name
end
close restore_header_cursor
deallocate restore_header_cursor

declare 
@full_backup_end_date datetime, @checkpointLSN numeric(25),
@diff_backup_end_date datetime,
@logs_backup_end_date datetime,
@backup_file_full_path varchar(3000)

select @full_backup_end_date = 
max(BackupFinishDate), @checkpointLSN = CheckpointLSN
from @table_header
where BackupFinishDate <= @before_date
and BackupTypeDescription = 'Database'
group by CheckpointLSN

select @diff_backup_end_date = 
max(BackupFinishDate)
from @table_header
where BackupfinishDate between @full_backup_end_date and @before_date 
and BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN

select @logs_backup_end_date =
max(BackupStartDate)
from (
select 
BackupStartDate,
case when @before_date between isnull(LAG(BackupStartDate,1) over(order by BackupStartDate ),0) and BackupStartDate
then 1 else 0 end end_file
from @table_header
where BackupTypeDescription = 'Transaction Log'
and DatabaseBackupLSN = @checkpointLSN
and BackupStartDate >= isnull(@diff_backup_end_date, @full_backup_end_date))a
where end_file = 1

select @directory_map = directorys_map 
from master.dbo.restore_loction_groups

insert into @final_table
select BackupTypeDescription, BackupStartDate, BackupFinishDate, backup_file_name, [with_stopat],
case when id = total_files then 1 else 0 end [recovery]
from (
select row_number() over(order by BackupStartDate) id, count(*) over() total_files, BackupTypeDescription, BackupStartDate, BackupFinishDate, 
case 
when BackupTypeDescription = 'Transaction Log' and last_file = 1 then 'STOPAT = '+''''+convert(varchar(40), @before_date, 120)+''''+'' 
else 'default' end [with_stopat], backup_file_name
from (
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Database'
and checkpointLSN = @checkpointLSN
and BackupFinishDate = @full_backup_end_date
union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN
and BackupFinishDate = @diff_backup_end_date
union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate >= isnull(@diff_backup_end_date, @full_backup_end_date) 
and BackupStartDate <= @logs_backup_end_date)a)b
order by BackupStartDate 

--and here to filler out the specific backup files 

if @action in (1)
begin
	select * from @final_table
	where id > @continue_after_file_number
	and id <= (select id from @final_table where recovery = 1)
	order by backup_time_from 
end
else
if @action in (2,3)
begin
	if @action in (3)
	begin
		select * from @final_table
		where id > @continue_after_file_number
		and id <= (select id from @final_table where recovery = 1)
		order by backup_time_from 
	end

	select @max_id = id - @continue_after_file_number, @max_file_name = backup_file_name
	from @final_table
	where id in (select max(id) from @final_table where id <= (select id from @final_table where recovery = 1))
	and id > @continue_after_file_number
	
	declare restore_cur cursor fast_forward
	for
	select backup_file_name, [with_stopat], [recovery]
	from @final_table
	where id > @continue_after_file_number
	and id <= (select id from @final_table where recovery = 1)
	order by id

	update master.dbo.restore_notification set status = 1

	insert into master.dbo.restore_notification
	(database_name, status, start_time, total_files, current_file, last_file_name)
	values
	(@db_restore_name, 0, getdate(), @max_id, 1, @max_file_name)

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
			current_file		= current_file + 1 + @continue_after_file_number
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

if @dbrecovery = 1
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	exec(@change_recovery_setting)
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
if @dbrecovery = 1
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	print(@change_recovery_setting)
end
end
report:
if @action in (2,3)
begin
exec [dbo].[errors_email] 
@project_name			 ='T24SDC6 restore',
@ccteam					 = 'T24 Team', 
@dba_in_to				 = 'ALBILAD\c904529',
@with_cc				 = 1,
@spid					 = @@spid
exec [dbo].[XEvent_errors] @@spid, 0
end
end
