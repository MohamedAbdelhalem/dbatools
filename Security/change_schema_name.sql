create procedure sp_change_schema
(@old_schema varchar(200), @new_schema varchar(200), @object_type varchar(100))
as
begin
declare @sql varchar(1500)
declare i cursor fast_forward
for
select 'ALTER SCHEMA ['+@new_schema+'] TRANSFER ['+schema_name(schema_id)+'].['+name+']'
from sys.objects
where type_desc = @object_type
and schema_name(schema_id) = @old_schema
and name in (
select name
from (
select count(*) schema_count, name
from sys.objects
where type_desc = @object_type
group by name
having count(*) = 1)a)

open i
fetch next from i into @sql
while @@FETCH_STATUS = 0
begin

--exec(@sql)
print(@sql)

fetch next from i into @sql
end
close i
deallocate i
end

go

select 'drop procedure ['+SCHEMA_name(schema_id)+'].['+name+']'
from sys.procedures
where schema_id= 1

select schema_name(schema_id), name
from sys.procedures
where name in (
select name
from sys.procedures
where schema_id= 1)
and schema_id != 1
