select 
row_number() over(order by case when count(distinct partition_id) = 1 then max(rows) else sum(rows) end desc) id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name, 
fg.name [filegroup_name],
master.dbo.format(case when count(distinct partition_id) = 1 then max(rows) else sum(rows) end,-1) rows, 
count(distinct partition_id) nr_partitions, 
master.dbo.numbersize(cast(sum(a.total_pages) as float) * 8.0,'k') size_n
from sys.partitions p inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.hobt_id)
--or (a.type = 3 and a.container_id = p.partition_id)
inner join sys.filegroups fg
on a.data_space_id = fg.data_space_id
inner join sys.tables t
on p.object_id = t.object_id
where p.index_id in (0,1)
group by partition_id, t.name, t.schema_id, fg.name
order by case when count(distinct partition_id) = 1 then max(rows) else sum(rows) end desc
