select 
ar.replica_server_name replica_server, count(*) [sync_databases], db.state_desc, cm.member_state_desc member_state,ars.role_desc, cm.number_of_quorum_votes quorum_votes, 
synchronization_state_desc sync_state_desc, rs.synchronization_health_desc sync_health_desc, database_state_desc, 
master.dbo.numbersize(isnull(sum(log_send_queue_size),0),'kb') log_send_queue_size, --master.dbo.format(cast(cast(sum(log_send_queue_size) as float) /1024.0 as numeric(10,5)),5)log_send_queue_size_mb,
master.dbo.numbersize(isnull(sum(redo_queue_size),0),'kb') redo_queue_size_not_yet,
convert(varchar(20), dateadd(s, (cast(substring(master.dbo.numbersize(isnull(sum(redo_queue_size),0) + isnull(sum(log_send_queue_size),0),'kb'),1,charindex(' ',master.dbo.numbersize(isnull(sum(redo_queue_size),0) + isnull(sum(log_send_queue_size),0),'kb'))-1) as float) * 100.0), '2000-01-01'), 108) [Time to complete (0.01 GB = 2 sec)],
master.dbo.numbersize(isnull((isnull(sum(log_send_queue_size),0) + isnull(sum(redo_queue_size),0)),0),'kb') total_waiting_logs,
master.dbo.duration('s', sum(case when isnull(datediff(s,last_redone_time,getdate()),0) < 0 then 0 else isnull(datediff(s,last_redone_time,getdate()),0) end)) last_redone_time,
case when sum(isnull(datediff(s,last_sent_time,getdate()),0)) < 60*60*1 then 'No Data Loss' else 'Data Loss' end PRO,
master.dbo.duration('s', sum(case when isnull(datediff(s,last_sent_time,getdate()),0) < 0 then 0 else isnull(datediff(s,last_sent_time,getdate()),0) end)) [Data_loss_Time RPO], 
master.dbo.duration('s', sum(isnull(datediff(s,last_sent_time,last_received_time),0))) [Network latency]
from sys.dm_hadr_database_replica_states rs inner join sys.databases db 
on rs.database_id = db.database_id
inner join sys.availability_replicas ar
on ar.replica_id = rs.replica_id
inner join sys.dm_hadr_cluster_members cm
on case when charindex('\',ar.replica_server_name) > 0 then substring(ar.replica_server_name, 1, charindex('\',ar.replica_server_name)-1) else ar.replica_server_name end = cm.member_name
inner join sys.dm_hadr_availability_replica_states ars
on ar.replica_id = ars.replica_id
where rs.is_local = 1
group by ar.replica_server_name, db.state_desc, cm.member_state_desc,ars.role_desc, cm.number_of_quorum_votes, 
synchronization_state_desc, rs.synchronization_health_desc, database_state_desc
order by 
total_waiting_logs desc
--142.63 GB

--check for upgrade
--select count(*), log_reuse_wait_desc from sys.databases where database_id > 4 group by log_reuse_wait_desc
--select @@VERSION
--Microsoft SQL Server 2014 (SP3) (KB4022619) - 12.0.6024.0 (X64)   Sep  7 2018 01:37:51   Copyright (c) Microsoft Corporation  Enterprise Edition: Core-based Licensing (64-bit) on Windows NT 6.3 <X64> (Build 9600: ) (Hypervisor) 
--Microsoft SQL Server 2014 (SP3-CU4-GDR) (KB5014164) - 12.0.6439.10 (X64)   Apr 20 2022 03:13:42   Copyright (c) Microsoft Corporation  Enterprise Edition: Core-based Licensing (64-bit) on Windows NT 6.3 <X64> (Build 9600: ) (Hypervisor) 