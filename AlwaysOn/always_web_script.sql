;WITH UpTime AS
			(
			SELECT DATEDIFF(SECOND,create_date,GETDATE()) [upTime_secs]
			FROM sys.databases
			WHERE name = 'T24Prod'
			),
	AG_Stats AS 
			(
			SELECT AR.replica_server_name,
				   HARS.role_desc, 
				   Db_name(DRS.database_id) [DBName], 
				   CAST(DRS.log_send_queue_size AS DECIMAL(19,2)) log_send_queue_size_KB, 
				   (CAST(perf.cntr_value AS DECIMAL(19,2)) / CAST(UpTime.upTime_secs AS DECIMAL(19,2))) / CAST(1024 AS DECIMAL(19,2)) [log_KB_flushed_per_sec]
			FROM   sys.dm_hadr_database_replica_states DRS 
			INNER JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id 
			INNER JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id 
				AND AR.replica_id = HARS.replica_id 
			--I am calculating this as an average over the entire time that the instance has been online.
			--To capture a smaller, more recent window, you will need to:
			--1. Store the counter value.
			--2. Wait N seconds.
			--3. Recheck counter value.
			--4. Divide the difference between the two checks by N.
			INNER JOIN sys.dm_os_performance_counters perf ON perf.instance_name = Db_name(DRS.database_id)
				AND perf.counter_name like 'Log Bytes Flushed/sec%'
			CROSS APPLY UpTime
			),
	Pri_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					, [log_KB_flushed_per_sec]
			FROM	AG_Stats
			WHERE	role_desc = 'PRIMARY'
			),
	Sec_CommitTime AS 
			(
			SELECT	replica_server_name
					, DBName
					--Send queue will be NULL if secondary is not online and synchronizing
					, log_send_queue_size_KB
			FROM	AG_Stats
			WHERE	role_desc = 'SECONDARY'
			)
SELECT p.replica_server_name [primary_replica]
	, p.[DBName] AS [DatabaseName]
	, s.replica_server_name [secondary_replica]
	, CAST(s.log_send_queue_size_KB / p.[log_KB_flushed_per_sec] AS BIGINT) [Sync_Lag_Secs]
FROM Pri_CommitTime p
LEFT JOIN Sec_CommitTime s ON [s].[DBName] = [p].[DBName]