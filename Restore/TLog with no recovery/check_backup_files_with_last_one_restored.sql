
declare @last_restoreed_file_name varchar(max)
declare @backup_file_name varchar(max)

select top 1
@last_restoreed_file_name = case when charindex('\', reverse(bmf.physical_device_name)) > 0 then reverse(substring(reverse(bmf.physical_device_name), 1, charindex('\', reverse(bmf.physical_device_name))-1)) else '' end 
--backup_file_name,
--bmf.physical_device_name full_path_of_backup_file
from msdb.dbo.restorehistory rh inner join msdb.dbo.backupset bs
on rh.backup_set_id = bs.backup_set_id
inner join msdb.dbo.backupmediafamily bmf
on bmf.media_set_id = bs.backup_set_id
where restore_date >= (select max(restore_date) from msdb.dbo.restorehistory where restore_type = 'D') --last restore files since last full bakup restore
--where restore_date >= '2023-01-01'
order by rh.restore_date desc

select @last_restoreed_file_name, 
convert(datetime,substring(REVERSE(substring(REVERSE(@last_restoreed_file_name),charindex('.',REVERSE(@last_restoreed_file_name))+1, CHARINDEX('_',REVERSE(@last_restoreed_file_name)) - charindex('.',REVERSE(@last_restoreed_file_name))-1 )),1,8),120),
substring(REVERSE(substring(REVERSE(@last_restoreed_file_name),charindex('.',REVERSE(@last_restoreed_file_name))+1, CHARINDEX('_',REVERSE(@last_restoreed_file_name)) - charindex('.',REVERSE(@last_restoreed_file_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(@last_restoreed_file_name),charindex('.',REVERSE(@last_restoreed_file_name))+1, CHARINDEX('_',REVERSE(@last_restoreed_file_name)) - charindex('.',REVERSE(@last_restoreed_file_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(@last_restoreed_file_name),charindex('.',REVERSE(@last_restoreed_file_name))+1, CHARINDEX('_',REVERSE(@last_restoreed_file_name)) - charindex('.',REVERSE(@last_restoreed_file_name))-1 )),13,2)

select backup_file_name,
convert(datetime,substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),1,8),120),
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),13,2)

from dbo.migration_log_files
where is_done = 0
and backup_file_name > @last_restoreed_file_name
order by file_datetime

select backup_file_name,
convert(datetime,substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),1,8),120),
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),9,2)+':'+
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),11,2)+':'+
substring(REVERSE(substring(REVERSE(backup_file_name),charindex('.',REVERSE(backup_file_name))+1, CHARINDEX('_',REVERSE(backup_file_name)) - charindex('.',REVERSE(backup_file_name))-1 )),13,2)

from dbo.migration_log_files
order by file_datetime