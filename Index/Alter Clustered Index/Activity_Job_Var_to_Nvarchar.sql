USE [msdb]
GO

/****** Object:  Job [Var_to_nVarchar]    Script Date: 10/4/2023 10:34:40 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/4/2023 10:34:40 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Var_to_nVarchar', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ALBILAD\c904529', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [drop_non_cluster]    Script Date: 10/4/2023 10:34:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'drop_non_cluster', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--drop non-clustered indexes
declare @drop_non_clustered_indexes varchar(max)
declare drop_non cursor fast_forward
for
select ''DROP INDEX [''+index_name+''] ON ''+table_name 
from dbo.nonclustered_indexes_of_converted_tables 
order by table_size desc

open drop_non
fetch next from drop_non into @drop_non_clustered_indexes 
while @@FETCH_STATUS = 0
begin
exec(@drop_non_clustered_indexes )
fetch next from drop_non into @drop_non_clustered_indexes 
end
close drop_non
deallocate drop_non', 
		@database_name=N'T24Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [drop_computed_columns]    Script Date: 10/4/2023 10:34:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'drop_computed_columns', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--drop computed columns
declare @drop_computed_columns varchar(max)
declare drop_compute cursor fast_forward
for
select ''ALTER TABLE ''+table_name+'' DROP COLUMN [''+column_name+'']'' 
from dbo.promoted_columns_of_converted_tables
order by table_size desc

open drop_compute
fetch next from drop_compute into @drop_computed_columns 
while @@FETCH_STATUS = 0
begin
exec(@drop_computed_columns )
fetch next from drop_compute into @drop_computed_columns 
end
close drop_compute
deallocate drop_compute
go', 
		@database_name=N'T24Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [cluster_index_change]    Script Date: 10/4/2023 10:34:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'cluster_index_change', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--drop primry keyu clustered indexes, alter table change the data type to nvarchar, then create again the prmary key clustered index
SET STATISTICS PROFILE ON
go
set QUOTED_IDENTIFIER ON
GO
set nocount on
go
declare 
@table_name	varchar(1000),
@index_name	varchar(1000),
@index_columns	varchar(1000),
@type_name	varchar(100),
@index_id	int,
@drop_constraint	varchar(4000),
@alter_table	varchar(4000),
@add_constraint	varchar(4000)

declare clust_cursor cursor fast_forward
for
select table_name--, index_name, index_columns,ty.name ,i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = ''RECID''
and ((ty.name = ''varchar'' and i.index_id in (0,1))
or (ty.name = ''nvarchar'' and i.index_id in (0)))
and index_type = ''clustered''
order by table_size 

open clust_cursor
fetch next from clust_cursor into @table_name--, @index_name, @index_columns , @type_name, @index_id
while @@FETCH_STATUS = 0
begin

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = ''RECID''
and ((ty.name = ''varchar'' and i.index_id in (0,1))
or (ty.name = ''nvarchar'' and i.index_id in (0)))
and index_type = ''clustered''
and table_name = @table_name
order by table_size 

if @index_id = 1 and @type_name = ''varchar''
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''before'', ''drop primary key'', GETDATE())

set @drop_constraint = ''ALTER TABLE ''+@table_name+'' DROP CONSTRAINT ''+@index_name
exec(@drop_constraint)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''after'', ''drop primary key'', GETDATE())

end

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = ''RECID''
and ((ty.name = ''varchar'' and i.index_id in (0,1))
or (ty.name = ''nvarchar'' and i.index_id in (0)))
and index_type = ''clustered''
and table_name = @table_name
order by table_size 

if @type_name = ''varchar''
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''before'', ''column convert'', GETDATE())

set @alter_table = ''ALTER TABLE ''+@table_name+'' ALTER COLUMN ''+replace(@index_columns,''var'',''nvar'')+'' NOT NULL''
exec(@alter_table)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''after'', ''column convert'', GETDATE())

end

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = ''RECID''
and ((ty.name = ''varchar'' and i.index_id in (0,1))
or (ty.name = ''nvarchar'' and i.index_id in (0)))
and index_type = ''clustered''
and table_name = @table_name
order by table_size 

if @index_id = 0 and @type_name = ''nvarchar''
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''before'', ''create primary key'', GETDATE())

set @add_constraint = ''ALTER TABLE ''+@table_name+'' ADD CONSTRAINT ''+@index_name+'' PRIMARY KEY (RECID)''
exec(@add_constraint)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''after'', ''create primary key'', GETDATE())

end

fetch next from clust_cursor into @table_name--, @index_name, @index_columns , @type_name, @index_id
end
close clust_cursor
deallocate clust_cursor

set nocount off
go
SET STATISTICS PROFILE off
go
', 
		@database_name=N'T24Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [create_compute]    Script Date: 10/4/2023 10:34:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'create_compute', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--add computed columns
declare @sql varchar(max)
declare computed_cursor cursor fast_forward
for
select ''ALTER TABLE ''+table_name+'' ADD [''+column_name+''] AS ''+definition
from dbo.promoted_columns_of_converted_tables
order by table_size desc

open computed_cursor
fetch next from computed_cursor into @sql
while @@FETCH_STATUS = 0
begin

exec(@sql)

fetch next from computed_cursor into @sql
end
close computed_cursor
deallocate computed_cursor
', 
		@database_name=N'T24Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [create_non_cluster]    Script Date: 10/4/2023 10:34:41 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'create_non_cluster', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--recreate the non-clustered indexes
SET STATISTICS PROFILE ON
go
set QUOTED_IDENTIFIER ON
GO
set nocount on
go
declare @table_name varchar(1000), @index_name varchar(1000), @sql varchar(max)
declare non_cursor cursor 
for
select table_name, index_name, replace(synatx, '' WITH ('', '' WITH (ONLINE = ON, '')
from dbo.nonclustered_indexes_of_converted_tables 
order by table_size desc

set nocount on
open non_cursor
fetch next from non_cursor into @table_name, @index_name, @sql
while @@FETCH_STATUS = 0
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''before'', ''create non-clustered index'', GETDATE())

exec(@sql)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, ''after'', ''create non-clustered index'', GETDATE())

fetch next from non_cursor into @table_name, @index_name, @sql
end
close non_cursor
deallocate non_cursor

set nocount off
go
SET STATISTICS PROFILE off
go

', 
		@database_name=N'T24Prod', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'one_time1', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20231003, 
		@active_end_date=99991231, 
		@active_start_time=171300, 
		@active_end_time=235959, 
		@schedule_uid=N'ac36bd07-df51-41ae-bf52-5d2a0efe8d1b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


