--select * from sys.partition_schemes
--select * from sys.destination_data_spaces
--select * from sys.partition_functions
--select * from sys.partition_range_values
--select * from sys.dm_db_partition_stats

select a.partition_schema_name, a.partition_function_name, a.[filegroup_name], a.destination_id, a.value value_from, 
case 
when len(cast(a.value as varchar(10))) = 6 then cast(b.value as varchar(10))
else
convert(varchar(50), dateadd(s,-1, convert(datetime, isnull(b.value,dateadd(month,1,convert(datetime, a.value,120))), 120)), 120) end value_to
from (
select ps.name partition_schema_name, pf.name partition_function_name, fg.name [filegroup_name], d.destination_id, pr.value
from sys.partition_schemes ps inner join sys.partition_functions pf
on ps.function_id = pf.function_id
inner join sys.destination_data_spaces d 
on ps.data_space_id = d.partition_scheme_id
inner join sys.partition_range_values pr
on pf.function_id = pr.function_id 
and d.destination_id = pr.boundary_id
inner join sys.filegroups fg
on d.data_space_id = fg.data_space_id)a
left outer join (
select ps.name partition_schema_name, pf.name partition_function_name, fg.name [filegroup_name], d.destination_id, pr.value
from sys.partition_schemes ps inner join sys.partition_functions pf
on ps.function_id = pf.function_id
inner join sys.destination_data_spaces d 
on ps.data_space_id = d.partition_scheme_id
inner join sys.partition_range_values pr
on pf.function_id = pr.function_id 
and d.destination_id = pr.boundary_id
inner join sys.filegroups fg
on d.data_space_id = fg.data_space_id)b
on  a.destination_id = b.destination_id - 1
and a.partition_function_name = b.partition_function_name
and a.partition_schema_name = b.partition_schema_name


select convert(varchar(30), getdate(), 112)
