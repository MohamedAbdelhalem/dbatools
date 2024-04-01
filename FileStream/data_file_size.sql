select 
f.FILE_ID, f.type_desc, f.name, fg.name [filegroup_name], 
case fg.type 
when 'fg' then 'File Group'
when 'fd' then 'File Stream Data'
when 'fx' then 'Memory Optimized'
end filegroup_type,
f.physical_name, 
master.dbo.numbersize(case when fg.type = 'fx' then cp.file_size_kb else f.size * 8.0 end, 'k') file_size, 
master.dbo.numbersize(case when fg.type = 'fx' then cp.file_size_used_kb else FILEPROPERTY(f.name, 'spaceused') * 8.0 end, 'k') file_used,  
master.dbo.numbersize(case when fg.type = 'fx' then cp.file_size_kb - cp.file_size_used_kb 
						   else (f.size - FILEPROPERTY(f.name, 'spaceused')) * 8.0 end, 'k') file_free,  
cast(case when fg.type = 'fx' then (cast((cp.file_size_kb - cp.file_size_used_kb) as float) / cp.file_size_kb) * 100.0 
								 else cast((f.size - FILEPROPERTY(f.name, 'spaceused')) as float) / f.size * 100.0 end as numeric(10,2)) file_free_pct,  
master.dbo.numbersize(growth * 8.0, 'k') file_growth,
case when max_size < 0 then 'Unlimited' else master.dbo.numbersize(max_size * 8.0, 'k') end file_max_size
from sys.database_files f left outer join (select container_id, 
											    sum(file_size_in_bytes)/1024.0 file_size_kb, 
												sum(file_size_used_in_bytes)/1024.0 file_size_used_kb 
										   from sys.dm_db_xtp_checkpoint_files 
										  group by container_id) cp
on f.file_id = cp.container_id
left outer join sys.filegroups fg
on fg.data_space_id = f.data_space_id
order by f.file_id
