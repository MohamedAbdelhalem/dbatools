--use [AdventureWorks2019]
go
select 
Partition_Function, Partition_Scheme, table_name, partition_size, table_size, partition_number, partition_rows, Partition_Key_Value, 
case when Partition_Value_From = 1 then case when boundary_value_on_right = 1 then '<' else '<=' end else 
case 
when (select name from sys.types tp where tp.user_type_id = x.user_type_id) in ('tinyint','smallint','int','bigint','decimal','numeric','float') then cast(Partition_Value_From as varchar(100)) 
when (select name from sys.types tp where tp.user_type_id = x.user_type_id) in ('datetime2','smalldate','datetime','date') then convert(varchar(20),Partition_Value_From,120) 
end end Partition_Value_From,
Partition_Value_To	Partition_Range, 
case when Partition_Value_To not in ('>=') then cast((cast(Partition_Value_To as bigint) - cast(Partition_Value_From as bigint)) as varchar(200)) end Partition_Range
from (
select '['+pf.name+']' Partition_Function, '['+ps.name+']' Partition_Scheme, al.table_name, partition_size,pp.user_type_id,boundary_value_on_right,
master.dbo.numbersize(sum(total_pages) over(partition by al.table_name) *8.0,'k') table_size,
isnull((prv.boundary_id + boundary_value_on_right),al.partition_number) partition_number, partition_rows, prv.value Partition_Key_Value, 
LAG(prv.value,1,1) OVER(ORDER BY table_name, partition_number) Partition_Value_From,
case when prv.value is null then '>=' else prv.value end Partition_Value_To
from (
select i.data_space_id, p.object_id, p.index_id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name,partition_number,
master.dbo.format(max(rows),-1) partition_rows,
master.dbo.numbersize(sum(a.total_pages) * 8.0,'k') partition_size,sum(a.total_pages) total_pages
from sys.partitions p with (nolock) inner join sys.tables t with (nolock)
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.indexes i
on  p.object_id = i.object_id
and p.index_id = i.index_id
where p.index_id = 1
group by i.data_space_id, schema_id, p.object_id, p.index_id, t.name,partition_number) al
left outer join sys.partition_schemes ps
on al.data_space_id = ps.data_space_id
left outer join sys.partition_functions pf
on ps.function_id = pf.function_id
left outer join sys.partition_parameters pp
on pf.function_id = pp.function_id
left outer join sys.partition_range_values prv
on prv.function_id = pf.function_id
--and (prv.boundary_id + boundary_value_on_right) = al.partition_number
and (prv.boundary_id + boundary_value_on_right) = al.partition_number
where table_name = '[Sales].[SalesOrderDetail]'
--and prv.value = datepart(DY,'2024-01-01')
)x
order by table_name, partition_number
