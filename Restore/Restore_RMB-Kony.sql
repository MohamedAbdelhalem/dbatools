declare @database_name varchar(1000), @physical_device_name varchar(max)
declare @full_backup_file table (database_name varchar(1000), physical_device_name varchar(max))
insert into @full_backup_file
select top 11 database_name, physical_device_name 
from (
select --top 10
database_name, 
case type 
when 'L' then 'Log'
when 'I' then 'Differential'
when 'D' then 'Full'
when 'F' then 'File or filegroup'
when 'G' then 'Differential file'
when 'P' then 'Partial'
when 'Q' then 'Differential partial'
else 'Others' end backup_type, 
backup_start_date, backup_finish_date, 
master.dbo.duration('s', datediff(s,backup_start_date,backup_finish_date)) backup_duration, 
is_damaged, is_force_offline,
server_name,
user_name, recovery_model, master.dbo.numbersize(backup_size,'byte') backup_size, 
master.dbo.numbersize(compressed_backup_size,'byte') backup_compressed_size , 
physical_device_name, case device_type 
when 2 then 'Disk' 
when 4 then 'Tape' 
when 7 then 'Virtual device' 
when 9 then 'Azure Storage' 
when 105  then 'A permanent backup device' 
end device_type
from msdb.dbo.backupset bs inner join msdb.dbo.backupmediafamily bmf
on bs.media_set_id = bmf.media_set_id)a
--where db_id(database_name) = db_id('T24SDC10')
where backup_type = 'FULL'
and db_id(database_name) > 4
order by backup_finish_date desc

declare i cursor fast_forward
for
select database_name, physical_device_name 
from @full_backup_file

EXEC msdb.dbo.sp_update_job  
@job_name = N'Notification Restore',  
@enabled = 1  

open i
fetch next from i into @database_name, @physical_device_name 
while @@FETCH_STATUS = 0
begin
set @database_name = @database_name+'_18'

exec [dbo].[sp_restore_database_distribution_groups]
@backupfile					= @physical_device_name, 
@option_02					= 1,
@restore_loc				= 'J:\Datafiles\',
@with_recovery				= 1,  
@new_db_name				= @database_name,
@percent					= 5,
@replace					= 0,
@action						= 3

update [dbo].[restore_notification] set current_file = current_file + 1

fetch next from i into @database_name, @physical_device_name 
end
close i
deallocate i

update [dbo].[restore_notification] set status = 1, finish_time = getdate()

exec [master].[dbo].[sp_notification_restore]
@done = 1,
@ccteam = 'Kony Team'

exec [msdb].[dbo].[sp_update_job]  
@job_name = 'Notification Restore',  
@enabled = 0
