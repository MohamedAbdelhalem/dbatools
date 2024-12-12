use master
go
create table [msdb].[dbo].[send_log_redo_queue_history] (
id int identity(1,1) not null primary key, 
replica_server varchar(300), availability_group_name varchar(300), database_name varchar(300), 
state_desc varchar(50), member_state varchar(50), role_desc varchar(50), quorum_votes int, sync_state_desc varchar(50), 
sync_health_desc varchar(50), database_state_desc varchar(50), 
[log_send_queue_size (RPO = Data Loss)] varchar(20), 
[redo_queue_size_not_yet (RTO = Long catch up)] varchar(20), 
total_waiting_logs varchar(20), 
[last_redone_time] varchar(20), 
[RPO] varchar(50), 
[Data_loss_Time RPO] varchar(50), 
[Long_catch_up RTO] varchar(50), 
[send or received latency] varchar(50),
capture_datetime datetime default getdate())
 
 
use master
go
create procedure sp_send_log_redo_queue_history 
as 
begin
 
insert into [msdb].[dbo].[send_log_redo_queue_history]
(replica_server, availability_group_name, database_name, 
state_desc, member_state, role_desc, quorum_votes, sync_state_desc, 
sync_health_desc, 
database_state_desc , 
[log_send_queue_size (RPO = Data Loss)], 
[redo_queue_size_not_yet (RTO = Long catch up)], 
total_waiting_logs, 
[last_redone_time], 
[RPO], 
[Data_loss_Time RPO], 
[Long_catch_up RTO], 
[send or received latency])
select 
ar.replica_server_name replica_server,ag.name availability_group_name, db.name database_name, db.state_desc, 
cm.member_state_desc member_state,ars.role_desc, cm.number_of_quorum_votes quorum_votes, 
synchronization_state_desc sync_state_desc, rs.synchronization_health_desc sync_health_desc, database_state_desc, 
master.dbo.numbersize(isnull(log_send_queue_size,0),'kb') 'log_send_queue_size (RPO = Data Loss)', 
master.dbo.numbersize(isnull(redo_queue_size,0),'kb') 'redo_queue_size_not_yet (RTO = Long catch up)',
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
end
 
 
--select * from msdb.dbo.send_log_redo_queue_history order by capture_datetime desc
 
go
USE [msdb]
GO
if exists (select * from msdb.dbo.sysjobs where name = 'Send_log_redo_queue_History_job')
begin
exec msdb.dbo.sp_delete_job @job_name=N'Send_log_redo_queue_History_job'
end
 
go
/****** Object:  Job [Send_log_redo_queue_History_job]    Script Date: 11/20/2024 11:16:52 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/20/2024 11:16:52 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END
 
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Send_log_redo_queue_History_job', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [log_send_redo_queue_history_step]    Script Date: 11/20/2024 11:16:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'log_send_redo_queue_history_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sp_send_log_redo_queue_history ', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every_10s', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20241118, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'ec8d1056-26db-478f-bf72-34fd460d40df'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
EXEC msdb.dbo.sp_update_job 
@job_name=N'Send_log_redo_queue_History_job', 
@enabled=1
 
go
USE [msdb]
GO
 
/****** Object:  Job [send_queue_history_purge_keep_one_month]    Script Date: 11/20/2024 11:31:03 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 11/20/2024 11:31:03 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
 
END
 
DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'send_queue_history_purge_keep_one_month', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'BANKSA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [purge]    Script Date: 11/20/2024 11:31:03 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'purge', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'delete from msdb.dbo.send_log_redo_queue_history
where capture_datetime < dateadd(day,-31, getdate())
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily_one_time', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20241120, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'1a1d9f73-1ea1-4f1d-840a-e7393f683f69'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
 
