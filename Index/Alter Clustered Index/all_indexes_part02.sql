use T24Prod
go
declare @tables varchar(max) = '[dbo].[scFOMS_SC_V031],[dbo].[FOMS_SC_CASH_FLOW_TRANS]'

insert into nonclustered_indexes_of_converted_tables (
table_name, table_size, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx
)
select 
conv.table_name, tab.table_size, conv.index_id, conv.index_name, conv.index_type, conv.is_disabled, conv.index_columns, conv.column_is_computed, conv.column_is_persisted, conv.columns_computed_function, conv.filegroup, conv.fill_factor, conv.synatx
from (
select distinct p.object_id, index_id, 
SUM(alo.total_pages) over(partition by p.object_id) table_size
from (
select count(*)c, ltrim(rtrim(value)) table_name
from master.dbo.Separator(@tables,',') 
group by ltrim(rtrim(value)))a inner join sys.partitions p
on object_id(a.table_name) = p.object_id
inner join sys.allocation_units alo
on (alo.type in (1,3) and alo.container_id = p.hobt_id)
or (alo.type = 2 and alo.container_id = p.partition_id))tab
inner join dbo.indexes_of_converted_tables conv
on tab.object_id = object_id(conv.table_name)
and tab.index_id = conv.index_id
where table_name not in (select table_name from dbo.indexes_of_converted_tables where index_type = 'CLUSTERED' and [index_columns] like '%nvarchar%')
and index_type = 'NONCLUSTERED'
order by table_size desc

insert into promoted_columns_of_converted_tables
select 
table_name,  
c.name column_name,
cc.definition,
table_size
from dbo.nonclustered_indexes_of_converted_tables con inner join sys.columns c
on c.object_id = object_id(table_name)
inner join sys.computed_columns cc
on c.object_id = cc.object_id
and c.column_id = cc.column_id
and c.name = replace(replace(substring(index_columns,1,CHARINDEX(' ',index_columns)-1),'[',''),']','')
order by table_size desc

insert into clustered_indexes_of_converted_tables (
table_name, table_size, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx
)
select 
conv.table_name, tab.table_size, conv.index_id, conv.index_name, conv.index_type, conv.is_disabled, conv.index_columns, conv.column_is_computed, conv.column_is_persisted, conv.columns_computed_function, conv.filegroup, conv.fill_factor, conv.synatx
from (
select distinct p.object_id, index_id, 
SUM(alo.total_pages) over(partition by p.object_id) table_size
from (
select count(*)c, ltrim(rtrim(value)) table_name
from master.dbo.Separator(@tables,',') 
group by ltrim(rtrim(value)))a inner join sys.partitions p
on object_id(a.table_name) = p.object_id
inner join sys.allocation_units alo
on (alo.type in (1,3) and alo.container_id = p.hobt_id)
or (alo.type = 2 and alo.container_id = p.partition_id))tab
inner join dbo.indexes_of_converted_tables conv
on tab.object_id = object_id(conv.table_name)
and tab.index_id = conv.index_id
where table_name not in (select table_name from dbo.indexes_of_converted_tables where index_type = 'CLUSTERED' and [index_columns] like '%nvarchar%')
and index_type = 'CLUSTERED'
order by table_size desc


select * from nonclustered_indexes_of_converted_tables 
select * from promoted_columns_of_converted_tables
select * from clustered_indexes_of_converted_tables 
