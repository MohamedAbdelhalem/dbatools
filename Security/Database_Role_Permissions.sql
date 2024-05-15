select dbr.principal_id, dbr.name [database_role_name], pm.permission_name, pm.state_desc, pm.class_desc, s.name [schema_name]
,
pm.state_desc+' '+pm.permission_name+' ON '+ case pm.class_desc 
when 'OBJECT_OR_COLUMN' then '['+schema_name(o.schema_id)+'].['+o.name+']'
when 'SCHEMA' then 'SCHEMA::['+s.name collate SQL_Latin1_General_CP1_CI_AS+']'
else pm.class_desc 
end+' TO '+dbr.name
from sys.database_permissions pm inner join (select * from sys.database_principals
where type = 'R'
and principal_id > 0
and is_fixed_role = 0
) dbr
on pm.grantee_principal_id = dbr.principal_id
left outer join sys.schemas s
on pm.major_id = s.schema_id
and pm.class_desc = 'SCHEMA'
left outer join sys.objects o
on pm.major_id = o.object_id
and pm.class_desc = 'OBJECT_OR_COLUMN'
