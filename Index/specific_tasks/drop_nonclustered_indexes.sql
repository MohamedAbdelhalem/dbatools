select 'DROP INDEX ['+index_name+'] ON ['+schema_name(schema_id)+'].['+table_name+']', table_name, index_name, type_desc index_type 
from (
select t.schema_id, t.name table_name, 
i.name index_name, i.is_primary_key, i.type_desc
from sys.indexes i with (nolock) inner join sys.tables t with (nolock) 
on i.object_id = t.object_id
where is_primary_key != 1
and i.type_desc not in ('HEAP','CLUSTERED')
and t.name not in ('sysdiagrams'))a
where table_name not in ('sysdiagrams')
order by table_name 
