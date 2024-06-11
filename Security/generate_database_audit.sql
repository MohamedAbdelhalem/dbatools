declare 
@drop varchar(1000),
@p1 varchar(2000),
@p2 varchar(max)

select top 1
@drop =
'ALTER DATABASE AUDIT SPECIFICATION ['+name+'] WITH (STATE = OFF)
GO
USE ['+db_name(db_id())+']
GO
DROP DATABASE AUDIT SPECIFICATION ['+name+']
GO'
from sys.database_audit_specifications
--name = ''

select top 1 @p1 = 'CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-'+db_name(db_id())+']
FOR SERVER AUDIT ['+name+']'
from sys.server_audits
--name = ''

select @p2 = isnull(@p2+',
','') + 'ADD (SELECT ON ['+schema_name(schema_id)+'].['+t.name+'] BY [Public])'
from sys.tables t

print(@drop)
print(@p1)
print(@p2)
print('WITH (STATE = ON)
GO')


--to fetch from the audit file(s)

select event_time, database_name, session_server_principal_name, succeeded, action_id, is_column_permission,schema_name, object_name, statement, application_name, client_ip  
from sys.fn_get_audit_file(
'E:\temp_db_audit_ARC_02\*',
DEFAULT,
DEFAULT)
