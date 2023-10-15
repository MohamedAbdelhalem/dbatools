declare @assembly varchar(300) = 'numsort'
select o.name reference_objects, 'DROP '+case 
when o.type_desc = 'CLR_SCALAR_FUNCTION' then 'FUNCTION' 
else '' end+' ['+schema_name(o.schema_id)+'].['+o.name+']' drop_reference_objects,
o.type_desc
from sys.assembly_modules ao inner join sys.assemblies a
on a.assembly_id = ao.assembly_id
inner join sys.objects o
on ao.object_id = o.object_id
where a.name = @assembly
union 
select @assembly, 'DROP ASSEMBLY ['+@assembly+']', 'assembly'
order by type_desc desc


--CREATE ASSEMBLY [numsort]
--AUTHORIZATION [dbo]
--FROM 'C:\Program Files\Microsoft SQL Server\130\Tools\Binn\numsort.dll'
--WITH PERMISSION_SET = SAFE
