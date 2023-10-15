--check indexes in all computed column's related tables
declare @tables varchar(max)
select @tables = isnull(@tables,'')+'['+schema_name(t.schema_id)+'].['+t.name+']'+','
from sys.computed_columns cc inner join sys.tables t
on cc.object_id = t.object_id
left outer join sys.indexes i
on t.object_id = i.object_id
--where t.name = 'FBNK_STMT_ENTRY'

exec dbo.sp_tables_indexes @tables

go

--generate script to create missing non-clustered indexes on computed columns
select 
schema_table_name, 
table_name,
compute_column, 
definition,
'CREATE NONCLUSTERED INDEX [Ind_'+compute_column+'_'+table_name+'_'+reverse(substring(function_name,1,charindex('_',function_name)-1))+'] ON '+schema_table_name+'(['+compute_column+'])'
from (
select '['+schema_name(t.schema_id)+'].['+t.name+']' schema_table_name, 
t.name table_name,
cc.name compute_column, 
cc.definition, 
reverse(replace(replace(substring(cc.definition,charindex('.',cc.definition)+1,charindex(']',cc.definition,10)-charindex('.',cc.definition)),']',''),'[','')) function_name
from sys.computed_columns cc inner join sys.tables t
on cc.object_id = t.object_id
where t.object_id in (
select t.object_id
from sys.tables t left outer join sys.indexes i
on t.object_id = i.object_id
and i.index_id != 1))a
