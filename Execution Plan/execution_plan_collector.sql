CREATE EVENT SESSION [execution_plan_collector] ON SERVER 
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(
	package0.last_error,
	sqlos.task_time,
	sqlserver.client_app_name,
	sqlserver.client_hostname,
	sqlserver.database_id,
	sqlserver.database_name,
	sqlserver.is_system,
	sqlserver.query_hash,
	sqlserver.session_id,
	sqlserver.sql_text,
	sqlserver.transaction_id,
	sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'execution_plan_collector')
WITH (
MAX_MEMORY=4096 KB,
EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,
STARTUP_STATE=OFF)
GO


