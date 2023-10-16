use master
go
select 
ar.replica_server_name, db.name [database_name], db.state_desc, cm.member_state_desc,ars.role_desc, cm.number_of_quorum_votes quorum_votes, 
synchronization_state_desc sync_state_desc, rs.synchronization_health_desc sync_health_desc, database_state_desc, 
master.dbo.numbersize(isnull(log_send_queue_size,0),'kb') log_send_queue_size,
master.dbo.numbersize(isnull(redo_queue_size,0),'kb') redo_queue_size_not_yet,
master.dbo.numbersize(isnull((isnull(log_send_queue_size,0) + isnull(redo_queue_size,0)),0),'kb') total_waiting_logs,
--cast((((100972.0+6335935.0) / case when (cast(redo_queue_size+log_send_queue_size as float) + .1) = .1 then 2 else (cast(redo_queue_size+log_send_queue_size as float) + .1) end) * 100.0) - 100 as numeric(10,2)),
master.dbo.duration('s', case when isnull(datediff(s,last_redone_time,getdate()),0) < 0 then 0 else isnull(datediff(s,last_redone_time,getdate()),0) end) last_redone_time,
case when isnull(datediff(s,last_sent_time,getdate()),0) < 60*60*1 then 'No Data Loss' else 'Data Loss' end PRO,
convert(varchar(20), dateadd(s, (cast(substring(master.dbo.numbersize(isnull(redo_queue_size,0) + isnull(log_send_queue_size,0),'kb'),1,charindex(' ',master.dbo.numbersize(isnull(redo_queue_size,0) + isnull(log_send_queue_size,0),'kb'))-1) as float) * 100.0 * 2.0), '2000-01-01'), 108) [Time to complete (0.01 GB = 2 sec)],
master.dbo.duration('s', case when isnull(datediff(s,last_sent_time,getdate()),0) < 0 then 0 else isnull(datediff(s,last_sent_time,getdate()),0) end) [Data_loss_Time RPO], 
master.dbo.duration('s', isnull(datediff(s,last_sent_time,last_received_time),0)) [Network latency]
--master.dbo.duration('ms', case when isnull(datediff(ms,last_sent_time,last_commit_time),0)		< 0 then 0 else isnull(datediff(ms,last_sent_time,last_commit_time),0)		end) [Overall Latency],
--master.dbo.duration('ms', isnull(datediff(ms,last_received_time, last_hardened_time),0)) [IO latency], 
--master.dbo.duration('ms', case when isnull(datediff(ms,last_sent_time,last_hardened_time),0)	< 0 then 0 else isnull(datediff(ms,last_sent_time,last_hardened_time),0)	end) [Acknowledgement Rate],
--master.dbo.duration('ms', case when isnull(datediff(ms,last_hardened_time,getdate()),0)			< 0 then 0 else isnull(datediff(ms,last_redone_time, last_hardened_time),0)			end) [last_hardened_time (LOG IO)]
from sys.dm_hadr_database_replica_states rs inner join sys.databases db 
on rs.database_id = db.database_id
inner join sys.availability_replicas ar
on ar.replica_id = rs.replica_id
inner join sys.dm_hadr_cluster_members cm
--on ar.replica_server_name = cm.member_name
on case when charindex('\',ar.replica_server_name) > 0 then substring(ar.replica_server_name, 1, charindex('\',ar.replica_server_name)-1) else ar.replica_server_name end = cm.member_name
inner join sys.dm_hadr_availability_replica_states ars
on ar.replica_id = ars.replica_id
where rs.is_local = 1
--and synchronization_state_desc != 'SYNCHRONIZED'
--and  name in ('T24_Staging')
order by --[Data_loss_Time RPO] desc, 
total_waiting_logs desc


--105 GB
--D2T24DBSQPWV5
--sp_configure 'max server memory (MB)'
--use ePO_D1EPOAPMTPWV2_Events
--checkpoint

--select master.dbo.duration('s',datediff(s,'2000-01-01 00:00:00','2000-01-01 00:02:15') * 134 )
/*
declare @start_value float = 19900609, @start_time datetime = '2023-01-05 20:24:00'
select [object_name],[cntr_value],
[counter_name], percent_complete,
[Log remaining for undo size],
dbo.duration('s',cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, @start_time, getdate()) as int)
-
datediff(s, @start_time, getdate())) time_to_complete
from (
SELECT distinct [object_name],[cntr_value],
[counter_name], 
cast(((@start_value / case when (cast([cntr_value] as float) + .1) = .1 then 2 else (cast([cntr_value] as float) + .1) end) * 100.0) - 100 as numeric(10,5)) percent_complete,
master.dbo.numbersize([cntr_value],'byte') [Log remaining for undo size] --REVERTING/RECOVERING status
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Database Replica%'
AND [counter_name] = 'Log remaining for undo')a
*/



--SELECT DB_name() as DatabaseName,File_ID as transaction_log_file_ID, vlf_active , vlf_status, *
--FROM sys.dm_db_log_info(DB_ID());


--SELECT  StartTime   =   sqlserver_start_time
--  FROM  sys.dm_os_sys_info;

--SELECT  StartTime   =   DATEADD(MILLISECOND, sqlserver_start_time_ms_ticks - ms_ticks, GETDATE()), ms_ticks
--  FROM  sys.dm_os_sys_info;
