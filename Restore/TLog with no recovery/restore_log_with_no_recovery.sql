USE [master]
GO
/****** Object:  StoredProcedure [dbo].[restore_log_with_no_recovery]    Script Date: 10/3/2023 12:28:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[restore_log_with_no_recovery]
as
begin

declare @log_path varchar(1000)
select @log_path = case 
when left(name,2) = 'D1' then '\\npci1.d1fs.albilad.com\T24_BACKUP_2023\LOGs\2023\October\'
when left(name,2) = 'D2' then '\\npci2.d2fs.albilad.com\T24_BACKUP_2023\LOGs\2023\October\'
end
from sys.servers where server_id = 0

declare @xp_cmdshell varchar(max)
declare @path_table table (output_text varchar(max))
set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@log_path+'"'''
insert into @path_table
exec(@xp_cmdshell)

insert into dbo.migration_log_files (file_datetime, backup_file_name, full_backup_file_name)
select file_datetime, ltrim(rtrim(SUBSTRING(output_text, charindex(' ',output_text)+1, len(output_text)))),
@log_path+ltrim(rtrim(SUBSTRING(output_text, charindex(' ',output_text)+1, len(output_text))))
from (
select 
convert(datetime,ltrim(rtrim(SUBSTRING(output_text, 1, charindex('M ',output_text)))),120) file_datetime,
ltrim(rtrim(SUBSTRING(output_text, charindex('M ',output_text)+2, len(output_text)))) output_text
from @path_table
where output_text not like '%<DIR>%'
and output_text like '%M  %')a
except
select file_datetime, backup_file_name, full_backup_file_name
from dbo.migration_log_files 

declare 
@database_name				varchar(500) = 'T24Prod',
@last_restoreed_file_name	varchar(max),
@backup_file_name			varchar(max)

select top 1
@last_restoreed_file_name = case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end 
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
where backup_file_name > @last_restoreed_file_name
order by file_datetime

open restore_log_cursor
fetch next from restore_log_cursor into @backup_file_name
while @@FETCH_STATUS = 0
begin

exec [master].[dbo].[sp_restore_database_distribution_groups]
@backupfile					= @backup_file_name,
@option_01					= 1,
@with_recovery				= 0,  
@percent					= 10,
@replace					= 0,
@action						= 2

--update dbo.migration_log_files 
--set is_done = 1 
--where full_backup_file_name = @backup_file_name

fetch next from restore_log_cursor into @backup_file_name
end
close restore_log_cursor 
deallocate restore_log_cursor 

end


