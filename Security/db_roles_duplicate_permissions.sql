select count(*), pm.permission_name, pm.state_desc,  '['+schema_name(o.schema_id)+'].['+o.name+']' [object_name]
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
where o.object_id is not null
group by pm.permission_name, pm.state_desc, o.schema_id, o.name
having count(*) > 1
order by count(*) desc
--where dbr.name = 'ServerRoleUsersAudit'

