select 
state_desc, permission_name, obj.name, dbpr.name, dbpr.type_desc database_principal_type,
state_desc collate SQL_Latin1_General_CP1_CI_AS+' '+permission_name collate SQL_Latin1_General_CP1_CI_AS+' ON 'collate SQL_Latin1_General_CP1_CI_AS+obj.name collate SQL_Latin1_General_CP1_CI_AS+' TO ['collate SQL_Latin1_General_CP1_CI_AS+dbpr.name+'];' collate SQL_Latin1_General_CP1_CI_AS permission_script
from sys.database_permissions dbp inner join sys.database_principals dbpr
on dbp.grantee_principal_id = dbpr.principal_id
inner join sys.objects obj
on dbp.major_id = object_id
where dbpr.name = 'SqlJDBCXAUser'
