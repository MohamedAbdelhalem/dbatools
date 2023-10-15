use msdb
go
if object_id('[dbo].[Latency_log_AG_v]') is null 
begin
CREATE TABLE [dbo].[Latency_log_AG_v](
[id] [int] IDENTITY(1,1) NOT NULL,
[database_id] [int] NULL,
[database_name] [varchar](255) NULL,
[Primary_node_Latency_ms] [bigint] NULL,
[Primary_node_Latency] [varchar](50) NULL,
[Secondary_node1_Latency_ms] [bigint] NULL,
[Secondary_node1_Latency] [varchar](50) NULL,
[Secondary_node2_Latency_ms] [bigint] NULL,
[Secondary_node2_Latency] [varchar](50) NULL,
[Secondary_node3_Latency_ms] [bigint] NULL,
[Secondary_node3_Latency] [varchar](50) NULL,
[insert_date] [datetime] default getdate()
)
end
go
use [master]
go
declare 
@type varchar(30),
@name varchar(300),
@sql varchar(1000)

declare i cursor fast_forward
for
select case type 
when 'P'	then 'PROCEDURE' 
when 'V'	then 'VIEW' 
when 'U'	then 'TABLE'
when 'TF'	then 'FUNCTION'
when 'FN'	then 'FUNCTION'
when 'FS'	then 'FUNCTION'
end type, '['+schema_name(schema_id)+'].['+name+']'
from sys.objects
where object_id in (
object_id('[dbo].[sp_latency_history]')
)
union all
select 'JOB', name 
from msdb.dbo.sysjobs
where name in (
'AG_Latency_monitor',
'Clear_Latency_History')
order by type

open i
fetch next from i into @type, @name
while @@FETCH_STATUS = 0
begin
if @type = 'JOB'
begin
	set @sql = 'EXEC msdb.dbo.sp_delete_job @job_name=N'+''''+@name+''''+', @delete_unused_schedule=1'
	exec(@sql)
	print(@sql)
end
else
begin
	set @sql = 'DROP '+@type+' '+@name
	exec(@sql)
	print(@sql)
end
fetch next from i into @type, @name
end
close i
deallocate i
GO

CREATE Procedure [dbo].[sp_latency_history] (
@filter					float = 0,
@date					varchar(200) = '2023-05-14 18:25:00 and 2023-05-15 00:00:00',
@order_by				nvarchar(20) = 'date', --date, Latency
@order_by_node			int = 2, --0 = all or 1,2,3,4
@database				nvarchar(255) = 'VRPCrmIntegration',
@desc					bit = 0,
@Only_job				int = 0)
as
begin
declare
@replicas_server_name	varchar(max),
@replicas_ss			varchar(max),
@date_time				varchar(200),
@delay_day				int

if @date = 'default'
begin
set @delay_day = 0
end
else
if @date not like '%and%'
begin
set @delay_day = @date
set @date = 'convert(datetime,convert(varchar(10),getdate()-'+cast(abs(cast(@delay_day as int)) as varchar(10))+',120),120) and dateadd(ms,-2,dateadd(day,1,convert(varchar(10),getdate()-'+cast(abs(cast(@delay_day as int)) as varchar(10))+',120)))'
end

select @replicas_server_name = isnull(@replicas_server_name+',','') + 
case replica_id_rank 
when 1 then 'Primary_node_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Primary_node_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 2 then 'Secondary_node1_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node1_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 3 then 'Secondary_node2_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node2_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
when 4 then 'Secondary_node3_Latency as ['+replica_server_name+' ('+role_desc+')], cast(Secondary_node3_Latency_ms/1000.0 as numeric(10,3)) as ['+replica_server_name+'_sec]'
end
from (
select DENSE_RANK() over(order by ars.role, ar.replica_server_name) replica_id_rank, dbrs.database_id, ar.replica_server_name, ars.role_desc, dbrs.last_commit_time
from  master.sys.dm_hadr_database_replica_states dbrs inner join sys.dm_hadr_availability_replica_states ars
on dbrs.replica_id = ars.replica_id
inner join sys.availability_replicas ar
on dbrs.replica_id = ar.replica_id
where database_id = (select top 1 database_id from sys.databases where database_id > 4))a
order by replica_id_rank

declare @sql nvarchar(max) = '
select id, database_name, '+'
'+@replicas_server_name+',
insert_date, case when 
master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end job_dataLost_should_catch
from msdb.dbo.Latency_log_AG_v
where database_id '+ case when @database is null then '> 0 ' else ' = db_id('+''''+@database+''''+')' end +'
'+
case when @date is null then '' else 'and insert_Date between '+case when dbo.vertical_array(@date,' and ',1) not like '%getdate%' then ''''+dbo.vertical_array(@date,' and ',1)+'''' else dbo.vertical_array(@date,' and ',1) end+
case when dbo.vertical_array(@date,' and ',2) not like '%getdate%' then ' and '+''''+dbo.vertical_array(dbo.vertical_array(@date,' and ',2),' ',2)+' '+dbo.vertical_array(dbo.vertical_array(@date,' and ',2),' ',3)+'''' else dbo.vertical_array(@date,' and ',2) end end+'
'+case @filter
when 0 then '' 
when 1 then ' and Primary_node_Latency_ms + isnull(Secondary_node1_Latency_ms,0) + isnull(Secondary_node2_Latency_ms,0) + isnull(Secondary_node3_Latency_ms,0) > 0' 
else		' and '+case 
					when @order_by_node = 1 then 'Primary_node_Latency_ms' 
					when @order_by_node = 2 then 'Secondary_node1_Latency_ms' 
					when @order_by_node = 3 then 'Secondary_node2_Latency_ms' 
					when @order_by_node = 4 then 'Secondary_node3_Latency_ms' 
					end +' >= '+cast((@filter * 1000) as varchar(10)) end+'
'+case @Only_job when 0 then '' 
when 1 then 'and case when master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end = 1' 
when 2 then 'and case when master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',2)%10 = 0 and master.dbo.vertical_array(convert(varchar(20),insert_date,108),'':'',3) = ''00'' then 1 else 0 end = 1 and '+case 
					when @order_by_node = 1 then 'Primary_node_Latency_ms' 
					when @order_by_node = 2 then 'Secondary_node1_Latency_ms' 
					when @order_by_node = 3 then 'Secondary_node2_Latency_ms' 
					when @order_by_node = 4 then 'Secondary_node3_Latency_ms' 
					end +' >= '+cast((@filter * 1000) as varchar(10))
end+'
order by '+case @order_by
when 'date' then 'insert_date' 
when 'latency' then case 
when @order_by_node = 0 then 'Primary_node_Latency_ms + isnull(Secondary_node1_Latency_ms,0) + isnull(Secondary_node2_Latency_ms,0) + isnull(Secondary_node3_Latency_ms,0)'
when @order_by_node = 1 then 'Primary_node_Latency_ms'
when @order_by_node = 2 then 'isnull(Secondary_node1_Latency_ms,0)'
when @order_by_node = 3 then 'isnull(Secondary_node2_Latency_ms,0)'
when @order_by_node = 4 then 'isnull(Secondary_node3_Latency_ms,0)'
end end +' '+
case @desc when 1 then 'desc' else 'asc' end

print(@sql)
exec sp_executesql @sql

end

go
USE [msdb]
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16), @loginame nvarchar(100)
select @loginame = name 
from sys.sql_logins
where sid = 0x01

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AG_Latency_monitor', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@loginame, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [data_collection]    Script Date: 5/23/2023 11:02:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'data_collection', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @table table (replica_id_rank int, database_id int, replica_server_name varchar(255), role_desc varchar(100), last_commit_time datetime)

insert into @table
select DENSE_RANK() over(order by ars.role, ar.replica_server_name) replica_id_rank, dbrs.database_id, ar.replica_server_name, ars.role_desc, dbrs.last_commit_time
from  master.sys.dm_hadr_database_replica_states dbrs inner join sys.dm_hadr_availability_replica_states ars
on dbrs.replica_id = ars.replica_id
inner join sys.availability_replicas ar
on dbrs.replica_id = ar.replica_id
order by replica_id_rank

insert into msdb.dbo.Latency_log_AG_v
(database_name, database_id, Primary_node_Latency_ms, Primary_node_Latency, Secondary_node1_Latency_ms, Secondary_node1_Latency, Secondary_node2_Latency_ms, Secondary_node2_Latency, Secondary_node3_Latency_ms, Secondary_node3_Latency)
select 
db.name, b.*
from (
select 
database_id, 
case when datediff(ms,[1],[1]) < 0 then 0 else datediff(ms,[1],[1]) end Primary_node_Latency_ms,
case when datediff(ms,[1],[1]) < 0 then master.dbo.duration(''ms'',0) else master.dbo.duration(''ms'',datediff(ms,[1],[1])) end Primary_node_Latency,
case when datediff(ms,[2],[1]) < 0 then 0 else datediff(ms,[2],[1]) end Secondary_node1_Latency_ms,
case when datediff(ms,[2],[1]) < 0 then master.dbo.duration(''ms'',0) else master.dbo.duration(''ms'',datediff(ms,[2],[1])) end Secondary_node1_Latency,
case when datediff(ms,[3],[1]) < 0 then 0 else datediff(ms,[3],[1]) end Secondary_node2_Latency_ms,
case when datediff(ms,[3],[1]) < 0 then master.dbo.duration(''ms'',0) else master.dbo.duration(''ms'',datediff(ms,[3],[1])) end Secondary_node2_Latency,
case when datediff(ms,[4],[1]) < 0 then 0 else datediff(ms,[4],[1]) end Secondary_node3_Latency_ms,
case when datediff(ms,[4],[1]) < 0 then master.dbo.duration(''ms'',0) else master.dbo.duration(''ms'',datediff(ms,[4],[1])) end Secondary_node3_Latency
from (select replica_id_rank, database_id, last_commit_time from @table) a
pivot (
max(last_commit_time) for replica_id_rank in ([1],[2],[3],[4]))p)b
inner join sys.databases db
on b.database_id = db.database_id
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sch_every_10_secs', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230511, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'55db6abe-afaa-48a8-a870-6172cf9c5052'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [Clear_Latency_History]    Script Date: 5/23/2023 10:58:55 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 5/23/2023 10:58:55 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16), @loginame nvarchar(100)
select @loginame = name 
from sys.sql_logins
where sid = 0x01

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Clear_Latency_History', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@loginame, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [clear_step]    Script Date: 5/23/2023 10:58:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'clear_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'delete 
FROM [msdb].[dbo].[Latency_log_AG_v]
where convert(varchar(10),[insert_date],120) < convert(varchar(10),getdate() - 7,120)  ', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every_day_onetime', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230523, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'c0a367da-9071-472c-a821-9f5c33b051e4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


