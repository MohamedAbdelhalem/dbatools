use [BAB_MIS_2023]
go
select al.table_name, partition_rows, partition_size, table_size, prv.boundary_id partition_number, 
prv.value, dateadd(s,-1,convert(datetime,LEAD(prv.value,1,1) over(order by prv.boundary_id),120))
from (
select i.data_space_id, p.object_id,p.index_id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name, partition_id, partition_number, hobt_id, 
master.dbo.format(max(rows),-1) partition_rows, master.dbo.numbersize(a.total_pages * 8.0,'k') partition_size, master.dbo.numbersize(sum(a.total_pages) over(partition by p.object_id) * 8.0,'k') table_size
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.indexes i
on  p.object_id = i.object_id
and p.index_id = i.index_id
where p.index_id = 1
group by i.data_space_id, schema_id, p.object_id, p.index_id, t.name, partition_id, partition_number, hobt_id, a.total_pages) al
inner join sys.partition_schemes ps
on al.data_space_id = ps.data_space_id
inner join sys.partition_functions pf
on ps.function_id = pf.function_id
inner join sys.partition_range_values prv
on prv.function_id = pf.function_id
and (prv.boundary_id + 1) = al.partition_number
where table_name = '[dbo].[MIS_LD]'

