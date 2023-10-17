select case type_desc 
when 'heap' then 'alter table '+ schema_table_name+' REBUILD'
when 'clustered' then 'ALTER INDEX '+index_name+' ON '+schema_table_name+' REBUILD'
when 'nonclustered' then 'ALTER INDEX '+index_name+' ON '+schema_table_name+' REBUILD'
end rebuild_script,
table_name, index_name, schema_table_name, type_desc, ver, 
master.dbo.format(rows,-1) r_o_w_s 
from (
select table_name, index_name, schema_table_name, type_desc, ver, sum(rows) rows 
from (
select '['+t.name+']' table_name, '['+i.name+']' index_name, '['+schema_name(schema_id)+'].['+t.name+']' schema_table_name, i.type_desc, rows, 
substring(cast(serverproperty('edition') as varchar(20)) , 1, charindex(' ', cast(serverproperty('edition') as varchar(20)))-1) ver
from sys.partitions p inner join sys.tables t with (nolock)
on p.object_id = t.object_id
left outer join sys.indexes i
on t.object_id = i.object_id
and p.index_id = i.index_id)a
group by table_name, index_name, schema_table_name, type_desc, ver)b
order by rows desc

