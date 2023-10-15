use master
go
declare 
@xEvent_name  nvarchar(255) = 'execution_plan_collector',
@only_figures int = 0,
@x_event_path varchar(1000),
@sql		  varchar(max)

set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER DROP TARGET package0.event_file'
exec(@sql)

set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER ADD TARGET package0.event_file(SET filename = N'+''''+@xEvent_name+''''+')'
exec(@sql)

set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER STATE=START'
exec(@sql)

select @x_event_path = reverse(substring(reverse(filename),charindex('\',reverse(filename)), len(reverse(filename))))+xEvent_name+'*'+'.xel'
from (
select s.name xEvent_name, CAST( t.target_data AS XML ).value('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') fileName
from sys.dm_xe_sessions s inner join sys.dm_xe_session_targets t 
on s.address = t.event_session_address
where t.target_name = 'event_file')a
where xEvent_name = @xEvent_name

select @x_event_path = ISNULL(@x_event_path,'I:\SQLSERVER\DATA\MSSQL12.MSSQLSERVER\MSSQL\Log\execution_plan_collector*.xel')

waitfor delay '00:00:01'

set @sql = 'ALTER EVENT SESSION ['+@xEvent_name+'] ON SERVER STATE = STOP'
exec(@sql)
go

use tempdb 
go

declare @x_event_path varchar(1000)
select  @x_event_path = ISNULL(@x_event_path,'I:\SQLSERVER\DATA\MSSQL12.MSSQLSERVER\MSSQL\Log\execution_plan_collector*.xel')

--if object_id('#x_event') is not null
--begin
--drop table #x_event
--end

select *
into #x_event
from (
select --XMLvalue,
dateadd(hour,3,cast(n.value('(/event/@timestamp)[1]', 'varchar(35)') as datetime))	execution_time,
n.value('(action[@name="database_name"]/value)[1]', 'varchar(255)')					database_name,
n.value('(data[@name="object_type"]/text)[1]', 'varchar(100)')						object_type_desc,
n.value('(data[@name="cpu_time"]/value)[1]', 'bigint')								cpu_time,
n.value('(action[@name="session_id"]/value)[1]', 'bigint')							session_id,
cast(n.value('(data[@name="duration"]/value)[1]', 'bigint')/1000.0 as numeric(10,3))duration_sec,
n.value('(action[@name="sql_text"]/value)[1]', 'varchar(max)')						sql_text,
n.query('/event/data[@name="showplan_xml"]/value').query('/value/*')				ExecutionPlan_Graph,
n.value('(data[@name="estimated_rows"]/value)[1]', 'varchar(255)')					estimated_rows,
n.value('(data[@name="estimated_cost"]/value)[1]', 'varchar(255)')					estimated_cost,
n.value('(data[@name="requested_memory_kb"]/value)[1]', 'varchar(255)')				requested_memory_kb,
n.value('(data[@name="used_memory_kb"]/value)[1]', 'varchar(255)')					used_memory_kb,
n.value('(data[@name="granted_memory_kb"]/value)[1]', 'varchar(255)')				granted_memory_kb,
n.value('(action[@name="username"]/value)[1]', 'varchar(255)')						username,
n.value('(action[@name="client_hostname"]/value)[1]', 'varchar(255)')				client_hostname,
n.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)')				client_app_name,
n.value('(action[@name="last_error"]/value)[1]', 'int')								last_error,
n.query('/event/data[@name="showplan_xml"]/value')									ExecutionPlan_XML
from (
select top 500 cast(event_data as XML) xmlvalue
from sys.fn_xe_file_target_read_file(@x_event_path, null, null, null))a
cross apply a.XMLvalue.nodes('event') as q(n))b

select master.dbo.duration('ms',datediff(ms, min(execution_time), MAX(execution_time))) collection_window 
from #x_event

--get the fetched data
select x.execution_time,x.database_name,cpu_time,session_id,duration_sec,username,client_hostname, sql_text,x.ExecutionPlan_Graph, bind_variables, parameter_values 
from #x_event x
cross apply master.[dbo].[fn_executionPlan_params](x.ExecutionPlan_XML) ex
where sql_text like '%Token%' 
--and session_id = 564 
order by session_id, execution_time


--sql text with declare parameters from xml execution plan
select 
execution_time, database_name, cpu_time, session_id, duration_sec, username, client_hostname,
case param_no 
when 1 then 'declare '+substring(sql_text, 2, charindex('))',sql_text)-1) +' = ' + [@P0]
when 2 then 'declare '+master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',1) +' = ' + [@P0] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',2) +' = ' + [@P1] 
when 3 then 'declare '+master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',1) +' = ' + [@P0] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',2) +' = ' + [@P1] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',3) +' = ' + [@P2] 
when 4 then 'declare '+master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',1) +' = ' + [@P0] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',2) +' = ' + [@P1] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',3) +' = ' + [@P2] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',4) +' = ' + [@P3] 
when 5 then 'declare '+master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',1) +' = ' + [@P0] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',2) +' = ' + [@P1] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',3) +' = ' + [@P2] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',4) +' = ' + [@P3] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',5) +' = ' + [@P4] 
when 6 then 'declare '+master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',1) +' = ' + [@P0] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',2) +' = ' + [@P1] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',3) +' = ' + [@P2] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',4) +' = ' + [@P3] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',5) +' = ' + [@P4] +', '+ master.dbo.vertical_array(substring(sql_text, 2, charindex('))',sql_text)-1),',',6) +' = ' + [@P5] 
else NULL end declare_parameter, 
substring(sql_text, charindex('))',sql_text)+2, len(sql_text)) sql_text
from (
select *,
IIF([@P0] is NULL,0,1)+IIF([@P1] is NULL,0,1)+IIF([@P2] is NULL,0,1)+IIF([@P3] is NULL,0,1)+IIF([@P4] is NULL,0,1)+IIF([@P5] is NULL,0,1)+IIF([@P6] is NULL,0,1) param_no
from (
select top 100 percent x.execution_time,x.database_name,cpu_time,session_id,duration_sec,username,client_hostname, sql_text, bind_variables, parameter_values 
from #x_event x
cross apply master.[dbo].[fn_executionPlan_params](x.ExecutionPlan_XML) ex
--where sql_text like '%TOKEN%' 
--and session_id = 564 
order by session_id, execution_time)a
pivot (
max(parameter_values) for bind_variables in ([@P0],[@P1],[@P2],[@P3],[@P4],[@P5],[@P6]))p)b
order by session_id, execution_time
