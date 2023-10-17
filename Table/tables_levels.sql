--CREATE View [dbo].[table_levels_view]
--as
select row_number() over(order by level desc) id, name, table_name, level
from (
select row_number() over(order by levels desc) id, name, table_name, 100 level
from (
select distinct t.name, '['+schema_name(t.schema_id)+'].['+t.name+']' table_name, dbo.fk_level(t.object_id) levels,
case when dbo.fk_level(t.object_id) = 0 and case 
when fk.referenced_object_id is null then 0 else 1 end > 0 then 100 else dbo.fk_level(t.object_id) 
end has_ref
from sys.tables t left outer join sys.foreign_keys fk
on t.object_id = fk.parent_object_id
where t.name != 'sysdiagrams')a
where has_ref = 0
union all
select row_number() over(order by levels desc), name, table_name, levels
from (
select distinct t.name, '['+schema_name(t.schema_id)+'].['+t.name+']' table_name, dbo.fk_level(t.object_id) levels,
case when dbo.fk_level(t.object_id) = 0 and case 
when fk.referenced_object_id is null then 0 else 1 end > 0 then 100 else dbo.fk_level(t.object_id) 
end has_ref
from sys.tables t left outer join sys.foreign_keys fk
on t.object_id = fk.parent_object_id
where t.name != 'sysdiagrams')a
where has_ref between 1 and 99
union all
select row_number() over(order by levels desc), name, table_name, 0
from (
select distinct t.name, '['+schema_name(t.schema_id)+'].['+t.name+']' table_name, dbo.fk_level(t.object_id) levels,
case when dbo.fk_level(t.object_id) = 0 and case 
when fk.referenced_object_id is null then 0 else 1 end > 0 then 100 else dbo.fk_level(t.object_id) 
end has_ref
from sys.tables t left outer join sys.foreign_keys fk
on t.object_id = fk.parent_object_id
where t.name != 'sysdiagrams')a
where has_ref = 100)aa

GO