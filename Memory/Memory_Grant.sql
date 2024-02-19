SELECT *,
cntr_value AS [Memory Grants Pending]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%'
AND counter_name = N'Memory Grants Pending'


SELECT mg.session_id
,mg.granted_memory_kb
,mg.requested_memory_kb
,mg.ideal_memory_kb
,mg.request_time
,mg.grant_time
,mg.query_cost
,mg.dop
,st.[TEXT]
,qp.query_plan,
ex.bind_variables, ex.parameter_values
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
CROSS APPLY master.dbo.fn_executionPlan_params(qp.query_plan) ex
ORDER BY mg.required_memory_kb DESC;


CREATE EVENT SESSION [MemoryGrant] ON SERVER 
ADD EVENT 
sqlserver.memory_grant_feedback_loop_disabled(
ACTION(package0.last_error,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.memory_grant_updated_by_feedback(
ACTION(package0.last_error,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sql_statement_starting
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO
