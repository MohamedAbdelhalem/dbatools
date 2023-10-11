select
vs.volume_mount_point, ds.style,sum(case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 1 else 0 end) condition ,
case when sum(case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 1 else 0 end) > 0 then 1 else 0 end warrning_file
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
--where volume_mount_point in ('F:\')
group by vs.volume_mount_point, ds.style

select db_name(mf.database_id),* 
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
where volume_mount_point in ('F:\')


select distinct
db_name(mf.database_id) database_name, name, type_desc, volume_mount_point ,((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) pct,
(case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) max_size,
case when 
((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 
and growth != 0 
and ds.style = 'MBR' 
and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 
then 1 else 0 end condition,
((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) pct, growth, ds.style, master.dbo.numbersize(vs.total_bytes,'byte') total_size
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
where volume_mount_point in ('F:\')

select distinct
vs.volume_mount_point, ds.style,mf.name,
case when case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 0 else 1 end > 0 then 1 else 0 end warrning_file
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
where volume_mount_point in ('F:\')
--group by vs.volume_mount_point, ds.style

select * from sys.master_files
where database_id = db_id('PRODmfreportsdbBAB')

select * from master.dbo.disks d where d.disk_letter = 'F'

Exec [master].[dbo].[database_size]
@databases		= '*',
@with_system	= 0,
@threshold_pct	= 85,
@volumes		= '*',
@where_size_gt  = 0,
@datafile		= '*',
@report			= 1,
@over_threshold = 0
