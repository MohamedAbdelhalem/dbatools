declare 
@xEvent_name  nvarchar(255) = 'execution_plan_collector',
@only_figures int = 0,
@x_event_path varchar(1000),
@sql		  varchar(max)

--set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER DROP TARGET package0.event_file'
--exec(@sql)

--set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER ADD TARGET package0.event_file(SET filename = N'+''''+@xEvent_name+''''+')'
--exec(@sql)

--set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER STATE=START'
--exec(@sql)

select @x_event_path = reverse(substring(reverse(filename),charindex('\',reverse(filename)), len(reverse(filename))))+xEvent_name+'*'+'.xel'
from (
select s.name xEvent_name, CAST( t.target_data AS XML ).value('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') fileName
from sys.dm_xe_sessions s inner join sys.dm_xe_session_targets t 
on s.address = t.event_session_address
where t.target_name = 'event_file')a
where xEvent_name = @xEvent_name

select @x_event_path = ISNULL(@x_event_path,'I:\SQLSERVER\DATA\MSSQL12.MSSQLSERVER\MSSQL\Log\execution_plan_collector*.xel')
--select @x_event_path

if @only_figures = 1
begin

select *
from (
select --XMLvalue,
cast(n.value('(/event/@timestamp)[1]', 'varchar(35)') as datetime)		execution_time,
--execution_time,
n.value('(action[@name="database_name"]/value)[1]', 'varchar(255)')		database_name,
n.value('(data[@name="object_type"]/text)[1]', 'varchar(100)')			object_type_desc,
n.value('(data[@name="cpu_time"]/value)[1]', 'bigint')					cpu_time,
n.value('(action[@name="session_id"]/value)[1]', 'bigint')				session_id,
n.value('(data[@name="duration"]/value)[1]', 'varchar(255)')			duration,
n.value('(data[@name="estimated_rows"]/value)[1]', 'varchar(255)')		estimated_rows,
n.value('(data[@name="estimated_cost"]/value)[1]', 'varchar(255)')		estimated_cost,
n.value('(data[@name="requested_memory_kb"]/value)[1]', 'varchar(255)')	requested_memory_kb,
n.value('(data[@name="used_memory_kb"]/value)[1]', 'varchar(255)')		used_memory_kb,
n.value('(data[@name="granted_memory_kb"]/value)[1]', 'varchar(255)')	granted_memory_kb,
n.value('(action[@name="username"]/value)[1]', 'varchar(255)')			username,
n.value('(action[@name="client_hostname"]/value)[1]', 'varchar(255)')	client_hostname,
n.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)')	client_app_name,
n.value('(action[@name="last_error"]/value)[1]', 'int')					last_error
from (
select top 1000 cast(event_data as XML) xmlvalue--, cast(cast(event_data as XML).value('(/event/@timestamp)[1]', 'varchar(35)') as datetime) execution_time
from sys.fn_xe_file_target_read_file(@x_event_path, null, null, null))a
cross apply a.XMLvalue.nodes('event') as q(n))b
--where execution_time > '2023-09-19 13:00:00'
--order by cpu_time desc

end
else
begin

waitfor delay '00:02:00'

select *
from (
select --XMLvalue,
dateadd(hour,3,cast(n.value('(/event/@timestamp)[1]', 'varchar(35)') as datetime)) execution_time,
n.value('(action[@name="database_name"]/value)[1]', 'varchar(255)')		database_name,
n.value('(data[@name="object_type"]/text)[1]', 'varchar(100)')			object_type_desc,
n.value('(data[@name="cpu_time"]/value)[1]', 'bigint')					cpu_time,
n.value('(action[@name="session_id"]/value)[1]', 'bigint')				session_id,
cast(n.value('(data[@name="duration"]/value)[1]', 'bigint')/1000.0 as numeric(10,2))			duration_sec,
n.value('(action[@name="sql_text"]/value)[1]', 'varchar(max)') sql_text,
n.query('/event/data[@name="showplan_xml"]/value').query('/value/*')	ExecutionPlan_Graph,
n.value('(data[@name="estimated_rows"]/value)[1]', 'varchar(255)')		estimated_rows,
n.value('(data[@name="estimated_cost"]/value)[1]', 'varchar(255)')		estimated_cost,
n.value('(data[@name="requested_memory_kb"]/value)[1]', 'varchar(255)')	requested_memory_kb,
n.value('(data[@name="used_memory_kb"]/value)[1]', 'varchar(255)')		used_memory_kb,
n.value('(data[@name="granted_memory_kb"]/value)[1]', 'varchar(255)')	granted_memory_kb,
n.value('(action[@name="username"]/value)[1]', 'varchar(255)')			username,
n.value('(action[@name="client_hostname"]/value)[1]', 'varchar(255)')	client_hostname,
n.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)')	client_app_name,
n.value('(action[@name="last_error"]/value)[1]', 'int')					last_error,
n.query('/event/data[@name="showplan_xml"]/value')						ExecutionPlan_XML
from (
select top 300 cast(event_data as XML) xmlvalue
from sys.fn_xe_file_target_read_file(@x_event_path, null, null, null))a
cross apply a.XMLvalue.nodes('event') as q(n))b
--where duration_sec > 2
--order by cpu_time  desc
end


set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER STATE = STOP'
exec(@sql)
