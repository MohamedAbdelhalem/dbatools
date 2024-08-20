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