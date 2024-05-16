--declare @backup_root_path varchar(1000) = 'D:\Backups\2024\May\Log\'
declare @backup_root_path varchar(1000) = '\\192.168.2.119\Backups\2024\May\Log\'
declare 
@xp_cmdshell_root		varchar(1500),
@log_backup_db_path		varchar(1500),
@folder_db_name			varchar(500)

set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+'"'+''''
declare @backup_folders table (output_text varchar(max))
declare @log_backup_folders table (output_text varchar(max), path varchar(max), db_name varchar(500))
--declare @backup_folders table (database_name varchar(500), folder_path varchar(max))
insert into @backup_folders
exec(@xp_cmdshell_root)

declare log_backup_cursor cursor fast_forward
for
select output_text
from (
select ltrim(rtrim(substring(output_text, charindex('<DIR>', output_text)+5, len(output_text)))) output_text
from @backup_folders
where output_text like '%<DIR>%'
and output_text like '%M  %')a
where output_text not like '.%'

open log_backup_cursor
fetch next from log_backup_cursor into @folder_db_name
while @@FETCH_STATUS = 0
begin

set @log_backup_db_path = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+@folder_db_name+'"'+''''

insert into @log_backup_folders (output_text)
exec(@log_backup_db_path)

update @log_backup_folders 
set path = @backup_root_path+@folder_db_name,
db_name = @folder_db_name
where path is null

fetch next from log_backup_cursor into @folder_db_name
end
close log_backup_cursor 
deallocate log_backup_cursor 

insert into dbo.migration_log_files (db_name, file_datetime, backup_file_name, full_backup_file_name)
select db_name, file_creation_date, backup_file_name, log_backup_file_name
from (
select db_name, log_backup_file_name backup_file_name, path+'\'+log_backup_file_name log_backup_file_name, file_creation_date
--,row_number() over(partition by db_name order by file_creation_date desc) id
from (
select file_creation_date, path, ltrim(rtrim(substring(output_text, charindex(' ', output_text)+1, len(output_text)))) log_backup_file_name, db_name
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text , 
convert(datetime,ltrim(rtrim(substring(output_text, 1, charindex('M ', output_text)))),120) file_creation_date, path, db_name
from @log_backup_folders
where output_text not like '%<DIR>%'
and output_text like '%M  %')a)b)c
except
select db_name, file_datetime, backup_file_name, full_backup_file_name
from dbo.migration_log_files 

declare 
@database_name				varchar(500),
@last_restoreed_file_name	varchar(max),
@backup_file_name			varchar(max)

declare db_cursor cursor fast_forward
for
select distinct db_name
from @log_backup_folders
order by db_name

open db_cursor
fetch next from db_cursor into @database_name
while @@FETCH_STATUS = 0
begin

select top 1
@last_restoreed_file_name = case 
when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) 
else '' end 
from msdb.dbo.backupmediafamily bmf inner join msdb.dbo.backupset bs
on bmf.media_set_id = bs.media_set_id
inner join msdb.dbo.restorehistory rh
on rh.backup_set_id = bs.backup_set_id
where restore_date >= (select max(restore_date) 
					   from msdb.dbo.restorehistory rh2 inner join msdb.dbo.backupset bs2 
					   on rh2.backup_set_id = bs2.backup_set_id
					   where restore_type = 'D'
					   and bs2.database_name = @database_name) --last restore files since last full bakup restore
and bs.database_name = @database_name
order by rh.restore_date desc

declare restore_log_cursor cursor fast_forward
for
select full_backup_file_name 
from dbo.migration_log_files
where isnull(is_done,0) = 0
and backup_file_name > @last_restoreed_file_name
and db_name = @database_name
order by file_datetime

open restore_log_cursor
fetch next from restore_log_cursor into @backup_file_name
while @@FETCH_STATUS = 0
begin

exec [master].[dbo].[sp_restore_database_distribution_groups]
@backupfile					= @backup_file_name,
@option_03					= 1,
@restore_loc_data			= 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\',
@restore_loc_log			= 'E:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data\',
@with_recovery				= 0,  
@percent					= 10,
@replace					= 0,
@action						= 2

update dbo.migration_log_files 
set is_done = 1 
where full_backup_file_name = @backup_file_name
and db_name = @database_name

fetch next from restore_log_cursor into @backup_file_name
end
close restore_log_cursor 
deallocate restore_log_cursor 

fetch next from db_cursor into @database_name
end
close db_cursor 
deallocate db_cursor 

