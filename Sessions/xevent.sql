CREATE EVENT SESSION [mon] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(package0.last_error,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.last_error,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.last_error,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.sql_text,sqlserver.username))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


