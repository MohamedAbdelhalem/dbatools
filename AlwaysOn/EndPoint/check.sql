SELECT ar.replica_server_name
   ,ag.name AS ag_name
   ,ar.owner_sid
   ,sp.name
FROM sys.availability_replicas ar
LEFT JOIN sys.server_principals sp
   ON sp.sid = ar.owner_sid 
INNER JOIN sys.availability_groups ag
   ON ag.group_id = ar.group_id
WHERE ar.replica_server_name = SERVERPROPERTY('ServerName') ;

--It looks like you can use the command

ALTER AUTHORIZATION ON availability group::[agname] TO [newowner]


--Check Endpoint Owner
USE master;
SELECT SUSER_NAME(principal_id) AS endpoint_owner, name AS endpoint_name
FROM sys.database_mirroring_endpoints;


USE [master]
GO
SELECT pm.class, pm.class_desc, pm.major_id, pm.minor_id, 
   pm.grantee_principal_id, pm.grantor_principal_id, 
   pm.[type], pm.[permission_name], pm.[state],pm.state_desc, 
   pr.[name] AS [owner], gr.[name] AS grantee, e.[name] AS endpoint_name
FROM sys.server_permissions pm 
   JOIN sys.server_principals pr ON pm.grantor_principal_id = pr.principal_id
   JOIN sys.server_principals gr ON pm.grantee_principal_id = gr.principal_id
   JOIN sys.endpoints e ON pm.grantor_principal_id = e.principal_id 
        AND pm.major_id = e.endpoint_id
WHERE pm.class = 'endpoint';

