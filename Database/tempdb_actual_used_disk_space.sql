use master
go
exec database_size @with_system = 1, @databases = 'tempdb'
go

use Tempdb
go
select count(*) numberOfFiles, left(physical_name,'3'), 
master.dbo.numbersize(sum(FILEPROPERTY(mf.name,'spaceused')) * 8.0,'k') used_space, 
logical_volume_name, 
master.dbo.numbersize(total_bytes,'b') disk_total_size, 
master.dbo.numbersize(available_bytes,'b') disk_free_space, 
master.dbo.numbersize(((total_bytes / 1024.0) - (sum(FILEPROPERTY(mf.name,'spaceused')) * 8.0 )),'k') actual_available_space,
cast((((total_bytes / 1024.0) - (sum(FILEPROPERTY(mf.name,'spaceused')) * 8.0 ))) / (total_bytes / 1024.0) * 100.0 as numeric(10,2)) [percent_actual_available_disk_space],
100 - cast((((total_bytes / 1024.0) - (sum(FILEPROPERTY(mf.name,'spaceused')) * 8.0 ))) / (total_bytes / 1024.0) * 100.0 as numeric(10,2)) [percent_actual_used_disk_space],
case when 85 < 100 - cast((((total_bytes / 1024.0) - (sum(FILEPROPERTY(mf.name,'spaceused')) * 8.0 ))) / (total_bytes / 1024.0) * 100.0 as numeric(10,2)) then 'bad' else 'good' end status
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) os
where mf.database_id = 2
group by left(physical_name,'3'), logical_volume_name,  total_bytes, available_bytes 

