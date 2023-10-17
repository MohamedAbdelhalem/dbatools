select * from mohamed

insert into mohamed values 
(2, 'fawzy'),
(3, 'ismail'),
(4, 'abdelhalem'),
(5, 'sayed')

truncate table mohamed



delete mohamed where id = 3



SELECT 
event_time,
action_id,
session_id,
server_principal_id,
database_principal_id,
session_server_principal_name,
server_principal_name,
database_principal_name,
server_instance_name,
database_name,
schema_name,
object_name,
file_name,
statement
FROM sys.fn_get_audit_file ('C:\TempDB\Server Auditing\UserServerAudit_5E8FFEEF-7653-49E3-8272-463F1627CEF2_0_132998925677210000.sqlaudit',default,default)
where statement like '%truncate%'
and db_id(database_name) > 4
and object_name = 'FBNK_ACCOUNT'

