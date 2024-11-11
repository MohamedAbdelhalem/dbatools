--open a registered servers and add group to add all replicas then open new query for this group and run this query
use master
go
select 
ar.replica_server_name replica_server,ag.name availability_group_name, db.name database_name, db.state_desc, 
cm.member_state_desc member_state,ars.role_desc, cm.number_of_quorum_votes quorum_votes, 
synchronization_state_desc sync_state_desc, rs.synchronization_health_desc sync_health_desc, database_state_desc, 
master.dbo.numbersize(isnull(log_send_queue_size,0),'kb') 'log_send_queue_size (RPO = Data Loss)', 
--master.dbo.format(cast(cast(sum(log_send_queue_size) as float) /1024.0 as numeric(10,5)),5)log_send_queue_size_mb,
master.dbo.numbersize(isnull(redo_queue_size,0),'kb') 'redo_queue_size_not_yet (RTO = Long catch up)',
--convert(varchar(20), dateadd(s, (cast(substring(master.dbo.numbersize(isnull(sum(redo_queue_size),0) + isnull(sum(log_send_queue_size),0),'kb'),1,charindex(' ',master.dbo.numbersize(isnull(sum(redo_queue_size),0) + isnull(sum(log_send_queue_size),0),'kb'))-1) as float) * 100.0), '2000-01-01'), 108) [Time to complete (0.01 GB = 2 sec)],
master.dbo.numbersize(isnull((isnull(log_send_queue_size,0) + isnull(redo_queue_size,0)),0),'kb') total_waiting_logs,
master.dbo.duration('s', case when isnull(datediff(s,last_redone_time,last_sent_time),0) < 0 then 0 else isnull(datediff(s,last_redone_time,last_sent_time),0) end) last_redone_time,
case when isnull(datediff(s,last_sent_time,getdate()),0) < 60 then 'No Data Loss' else 'Data Loss' end RPO, --more than 1 minute
master.dbo.duration('ms', case when isnull(datediff(ms,last_sent_time,getdate()),0) <= 0 then 0 else isnull(datediff(ms,last_sent_time,getdate()),0) end) [Data_loss_Time RPO], 
master.dbo.duration('ms', case when isnull(datediff(ms,last_sent_time,last_received_time),0) <= 0 then 0 else isnull(datediff(ms,last_redone_time,GETDATE()),0) end) [Long_catch_up RTO], 
master.dbo.duration('ms', isnull(datediff(ms,last_sent_time,last_received_time),0)) [send or received latency]
--last_sent_time, --last sent means last time primary sent log and when time diff is big it could indecates of potential data loss = [Data_loss_Time RPO]
--last_received_time, -- this means last time secondary has received log, when time between received and sent small the catching up will be minimal
--last_redone_time -- this means secondary has received if received = sent but it doesn't applied yet and that can cause long recovery time if failover happened
--for last_redone_time is big when no sync issues? it means no data has been added on the primary database 
from sys.dm_hadr_database_replica_states rs inner join sys.databases db 
on rs.database_id = db.database_id
inner join sys.availability_replicas ar
on ar.replica_id = rs.replica_id
inner join sys.dm_hadr_cluster_members cm
on case when charindex('\',ar.replica_server_name) > 0 then substring(ar.replica_server_name, 1, charindex('\',ar.replica_server_name)-1) else ar.replica_server_name end = cm.member_name
inner join sys.dm_hadr_availability_replica_states ars
on ar.replica_id = ars.replica_id
inner join sys.availability_groups ag
on ar.group_id = ag.group_id
where rs.is_local = 1
order by 
total_waiting_logs desc
