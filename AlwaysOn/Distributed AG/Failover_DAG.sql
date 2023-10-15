--failover steps
--Nodes
--10.5.2.97  - (PRIMARY local ag) - (PRIMARY   dag)
--10.37.2.97 - (PRIMARY local ag) - (SECONDARY dag)

--on PRIMARY
SELECT ag.[name] AS [Distributed AG Name], ar.replica_server_name AS [Underlying AG], dbs.[name] AS [Database], ars.role_desc AS [Role], drs.synchronization_health_desc AS [Sync Status], drs.log_send_queue_size, drs.log_send_rate, drs.redo_queue_size, drs.redo_rate 
FROM sys.databases AS dbs 
INNER JOIN sys.dm_hadr_database_replica_states AS drs 
ON dbs.database_id = drs.database_id 
INNER JOIN sys.availability_groups AS ag 
ON drs.group_id = ag.group_id 
INNER JOIN sys.dm_hadr_availability_replica_states AS ars 
ON ars.replica_id = drs.replica_id 
INNER JOIN sys.availability_replicas AS ar 
ON ar.replica_id = ars.replica_id 
WHERE ag.is_distributed = 1 

--run this command on (PRIMARY dag) node on PDC to set the it as a SECONDARY
ALTER AVAILABILITY GROUP DAG_Test SET (ROLE = SECONDARY)
--then run this command on (SECONDARY dag) to complete the failover
ALTER AVAILABILITY GROUP DAG_Test FORCE_FAILOVER_ALLOW_DATA_LOSS;


--on SECONARY
SELECT ag.[name] AS [Distributed AG Name], ar.replica_server_name AS [Underlying AG], dbs.[name] AS [Database], ars.role_desc AS [Role], drs.synchronization_health_desc AS [Sync Status], drs.log_send_queue_size, drs.log_send_rate, drs.redo_queue_size, drs.redo_rate 
FROM sys.databases AS dbs 
INNER JOIN sys.dm_hadr_database_replica_states AS drs 
ON dbs.database_id = drs.database_id 
INNER JOIN sys.availability_groups AS ag 
ON drs.group_id = ag.group_id 
INNER JOIN sys.dm_hadr_availability_replica_states AS ars 
ON ars.replica_id = drs.replica_id 
INNER JOIN sys.availability_replicas AS ar 
ON ar.replica_id = ars.replica_id 
WHERE ag.is_distributed = 1 
