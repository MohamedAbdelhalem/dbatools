--create extended event
CREATE EVENT SESSION [index_oper_pc_ttc] --index operation percent complete and Time to complete
ON SERVER 
ADD 
EVENT sqlserver.progress_report_online_index_operation(
ACTION (
	package0.last_error,
	sqlserver.client_app_name,
	sqlserver.client_hostname,
	sqlserver.database_id,
	sqlserver.database_name,
	sqlserver.is_system,
	sqlserver.session_id,
	sqlserver.sql_text,
	sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'index_oper_pc_ttc')
WITH (
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=ON)
go
ALTER EVENT SESSION [index_oper_pc_ttc] ON SERVER STATE = START
