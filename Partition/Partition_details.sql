--use [AdventureWorks2019]
go
select *, 
case when Partition_Value_To not in ('>') then cast((cast(Partition_Value_To as bigint) - cast(Partition_Value_From as bigint)) as varchar(200)) end Partition_Range
from (
select al.table_name, partition_rows, partition_size,
master.dbo.numbersize(sum(total_pages) over(partition by al.table_name) *8.0,'k') table_size,
isnull((prv.boundary_id + boundary_value_on_right),al.partition_number) partition_number, prv.value Partition_Key_Value, 
LAG(prv.value,1,1) OVER(ORDER BY table_name, partition_number) Partition_Value_From,
case when prv.value is null then '>' else prv.value end Partition_Value_To
from (
select i.data_space_id, p.object_id, p.index_id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name,partition_number,
master.dbo.format(max(rows),-1) partition_rows,
master.dbo.numbersize(sum(a.total_pages) * 8.0,'k') partition_size,sum(a.total_pages) total_pages
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.indexes i
on  p.object_id = i.object_id
and p.index_id = i.index_id
where p.index_id = 1
group by i.data_space_id, schema_id, p.object_id, p.index_id, t.name,partition_number) al
inner join sys.partition_schemes ps
on al.data_space_id = ps.data_space_id
inner join sys.partition_functions pf
on ps.function_id = pf.function_id
left outer join sys.partition_range_values prv
on prv.function_id = pf.function_id
--and (prv.boundary_id + boundary_value_on_right) = al.partition_number
and (prv.boundary_id + boundary_value_on_right) = al.partition_number
--where table_name = '[Sales].[SalesOrderHeader]'
--and prv.value = datepart(DY,'2024-01-01')
)x
order by table_name, partition_number
