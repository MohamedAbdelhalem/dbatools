select distinct 
volume_mount_point, 
master.dbo.numberSize(total_bytes,'byte') volume_size, 
master.dbo.numberSize(total_bytes-available_bytes,'byte') volume_used,
cast((cast((total_bytes-available_bytes) as float) / cast(total_bytes as float)) * 100.0 as numeric(10,2))[volume_used %],
master.dbo.numberSize(available_bytes,'byte') volume_free,
cast((cast(available_bytes as float) / cast(total_bytes as float)) * 100.0 as numeric(10,2)) [volume_free %]
from (
select database_id, min(file_id) [file_id], type
from sys.master_files 
group by database_id, type)a cross apply sys.dm_os_volume_stats(database_id,file_id)
