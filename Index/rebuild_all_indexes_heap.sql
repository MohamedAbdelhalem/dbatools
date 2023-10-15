--use Data_Hub_Cortex_2021
go
declare @table_go1 table (
id int, 
script varchar(3000), 
table_name varchar(100), 
index_name varchar(100), 
schema_table_name varchar(100), 
[type_desc] varchar(100), 
ver varchar(100), 
r_o_w_s varchar(100))

insert into @table_go1
select * 
from (
select top 100 percent row_number() over(order by rows desc) id, case [type_desc]
when 'heap' then 'alter table '+ schema_table_name+' REBUILD'
when 'clustered' then 'ALTER INDEX '+index_name+' ON '+schema_table_name+' REBUILD'
when 'nonclustered' then 'ALTER INDEX '+index_name+' ON '+schema_table_name+' REBUILD'
end rebuild_script,
table_name, index_name, schema_table_name, [type_desc], ver,
master.dbo.format(rows,-1) r_o_w_s 
from (
select table_name, index_name, schema_table_name, type_desc, ver, sum(rows) rows 
from (
select '['+t.name+']' table_name, '['+i.name+']' index_name, '['+schema_name(schema_id)+'].['+t.name+']' schema_table_name, i.type_desc, rows, 
substring(cast(serverproperty('edition') as varchar(20)) , 1, charindex(' ', cast(serverproperty('edition') as varchar(20)))-1) ver
from sys.partitions p with (nolock) inner join sys.tables t with (nolock)
on p.object_id = t.object_id
left outer join sys.indexes i with (nolock)
on t.object_id = i.object_id
and p.index_id = i.index_id)a
--where schema_table_name = '[dbo].[FBNK_BAB_VISA_CRD_ISSUE]'
group by table_name, index_name, schema_table_name, type_desc, ver)b
order by rows)a

select id, script, table_name, index_name, schema_table_name, type_desc, ver, r_o_w_s
from @table_go1
union all
select id, 'go', '0', null, null, null, null, null
from @table_go1
union all
select id, 'go', '2', null, null, null, null, null
from @table_go1
union all
select id, 'update master.dbo.start_step set start_time = getdate()', '1', null, null, null, null, null
from @table_go1
order by id, table_name


