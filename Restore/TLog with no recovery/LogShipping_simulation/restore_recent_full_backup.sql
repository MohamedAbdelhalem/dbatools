declare @backup_root_path varchar(1000) = 'D:\Backups\2024\May\FULL\'
--declare @backup_root_path varchar(1000) = '\\192.168.2.119\Backups\2024\May\FULL\'
declare 
@xp_cmdshell_root		varchar(1500),
@log_backup_db_path		varchar(1500),
@folder_db_name			varchar(500)

set @xp_cmdshell_root = 'xp_cmdshell '+''''+'dir cd "'+@backup_root_path+'"'+''''
declare @backup_folders table (output_text varchar(max))
declare @log_backup_folders table (output_text varchar(max), path varchar(max), db_name varchar(500))
--declare @backup_folders table (database_name varchar(500), folder_path varchar(max))

set nocount on
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

declare @db_name varchar(500), @full_backup_file_name varchar(max)
declare full_restore_cursor cursor fast_forward
for
select db_name, log_backup_file_name
from (
select db_name, path, path+'\'+log_backup_file_name log_backup_file_name, file_creation_date
,row_number() over(partition by db_name order by file_creation_date desc) id
from (
select file_creation_date, path, ltrim(rtrim(substring(output_text, charindex(' ', output_text)+1, len(output_text)))) log_backup_file_name, db_name
from (
select ltrim(rtrim(substring(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text , 
convert(datetime,ltrim(rtrim(substring(output_text, 1, charindex('M ', output_text)))),120) file_creation_date, path, db_name
from @log_backup_folders
where output_text not like '%<DIR>%'
and output_text like '%M  %')a)b)c
where id = 1
order by db_name

open full_restore_cursor
fetch next from full_restore_cursor into @db_name, @full_backup_file_name
while @@FETCH_STATUS = 0
begin

exec [master].[dbo].[sp_restore_database_distribution_groups]
@backupfile					= @full_backup_file_name,
@option_03					= 1,
@restore_loc_data			= 'D:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\',
@restore_loc_log			= 'E:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data\',
@with_recovery				= 0,  
@percent					= 10,
@replace					= 0,
@action						= 2


fetch next from full_restore_cursor into @db_name, @full_backup_file_name
end
close full_restore_cursor
deallocate full_restore_cursor

set nocount off
