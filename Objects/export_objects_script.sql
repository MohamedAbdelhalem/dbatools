create procedure export_objects_script
(@object_name varchar(500))
as
begin

select o.name, o.type_desc, s.id line_no, s.value syntax
from sys.sql_modules sm inner join sys.objects o
on o.object_id = sm.object_id
cross apply master.dbo.Separator(definition, char(10)) s
where o.object_id = object_id(@object_name)
order by sm.object_id, s.id

end
