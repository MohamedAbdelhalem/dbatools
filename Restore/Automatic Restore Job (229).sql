USE [msdb]
GO

/****** Object:  Job [Automatic Restore Job]    Script Date: 8/2/2023 9:44:55 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8/2/2023 9:44:55 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Automatic Restore Job', 
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
/****** Object:  Step [update before date]    Script Date: 8/2/2023 9:44:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'update before date', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Update [master].[dbo].[auto_restore_job_parameters]
set [before_date] = dateadd(Hour, 5,convert(varchar(10), getdate(), 120))
', 
		@database_name=N'master', 
		@output_file_name=N'I:\MSSQL13.MSSQLSERVER\MSSQL\JOBS\step_1', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [restore_step]    Script Date: 8/2/2023 9:44:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'restore_step', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare 
@before_date		datetime,
@db_restore_name		varchar(500),
@username		varchar(500),
@workaround_locations	varchar(3000),
@is_using_workaround	bit,
@dbsync			int

select 
@before_date		= before_date,
@db_restore_name		= db_restore_name,
@username		= username,
@dbsync			= isAG,
@workaround_locations 	= workaround_locations,
@is_using_workaround = case when @before_date < ''2022-12-01'' then 0 else 1 end
from master.dbo.auto_restore_job_parameters

exec dbo.automatic_database_restore
@before_date		 = @before_date, 
@db_restore_name		 = @db_restore_name,
@username		 = @username,
@locations		 = @workaround_locations,
@isAG			= @dbsync,
@workaround_loc		 = @is_using_workaround,		-- 0 before December
@continue_after_file_number = 0,
@action			 = 5
', 
		@database_name=N'master', 
		@output_file_name=N'I:\MSSQL13.MSSQLSERVER\MSSQL\JOBS\step_2', 
		@flags=6
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'T24AutmoateRestore', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=31, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20191213, 
		@active_end_date=99991231, 
		@active_start_time=61000, 
		@active_end_time=235959, 
		@schedule_uid=N'676ca16b-f89b-4a5f-859c-f99dcd53ed5f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


