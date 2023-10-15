declare 
@original_table_rows	float			= 753701622.0,
@start_time				datetime		= '2023-04-27 16:16:31',
@table_name				varchar(355)	= '[dbo].[MIS_LIMIT]'
select * from (
select 
master.dbo.format(case when count(*) = 1 then max(rows) else sum(rows) end,-1) transferred_rows, 
cast(case when count(*) = 1 then max(rows) else sum(rows) end / @original_table_rows * 100.0 as numeric(10,5)) percent_complete, 
master.[dbo].[time_to_complete](case when count(*) = 1 then max(rows) else sum(rows) end, @original_table_rows, @start_time) time_to_complete,
'['+schema_name(schema_id)+'].['+t.name+']' table_name
from sys.partitions p inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type = 3 and a.container_id = p.partition_id)
inner join sys.tables t
on p.object_id = t.object_id
where p.index_id in (0,1)
group by t.schema_id, t.name)a
where table_name = @table_name
