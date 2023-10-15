--ALTER EVENT SESSION [index_oper_pc_ttc] ON SERVER STATE = STOP
--go
--ALTER EVENT SESSION [index_oper_pc_ttc] ON SERVER STATE = START
-------------------------------------------
use [T24PROD]
go
declare 
@spid			int = 82,
@table_name		varchar(500) = '[dbo].[F_BAB_L_CTX_DUP_PROCESS]',

@target_rows	float,
@filename		varchar(1000)

select @target_rows = max(rows) from sys.partitions where object_id = object_id(@table_name)

select @filename = reverse(substring(reverse(filename),charindex('\',reverse(filename)), len(reverse(filename))))+xEvent_name+'*'+'.xel'
from (
select s.name xEvent_name, CAST( t.target_data AS XML ).value('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') fileName
from sys.dm_xe_sessions s inner join sys.dm_xe_session_targets t 
on s.address = t.event_session_address
where t.target_name = 'event_file')a
where xEvent_name = 'index_oper_pc_ttc'

select @filename, @target_rows 
--index online operation progress
select 
(max(n.value('(data[@name="rows_inserted"]/value)[1]', 'float')) / @target_rows) * 100.0 percent_complete,  
master.dbo.time_to_complete(max(n.value('(data[@name="rows_inserted"]/value)[1]', 'float')),@target_rows, max(r.start_time)) tme_to_complete
from (
select cast(event_data as XML) xmlvalue
from sys.fn_xe_file_target_read_file(@filename, null, null, null)ss)a
cross apply a.XMLvalue.nodes('event') as q(n) 
cross apply sys.dm_exec_requests r
where r.session_id = 82
go
declare 
@spid			int = 82,
@table_name		varchar(500) = '[dbo].[F_BAB_L_CTX_DUP_PROCESS]',

@target_rows	float,
@filename		varchar(1000)

select @target_rows = max(rows) from sys.partitions where object_id = object_id(@table_name)
select @target_rows 

select @filename = reverse(substring(reverse(filename),charindex('\',reverse(filename)), len(reverse(filename))))+xEvent_name+'*'+'.xel'
from (
select s.name xEvent_name, CAST( t.target_data AS XML ).value('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') fileName
from sys.dm_xe_sessions s inner join sys.dm_xe_session_targets t 
on s.address = t.event_session_address
where t.target_name = 'event_file')a
where xEvent_name = 'index_oper_pc_ttc'
select @filename

--detailed
select --XMLvalue,
n.value('(data[@name="database_id"]/value)[1]', 'int')					database_id,
n.value('(data[@name="build_stage"]/text)[1]', 'varchar(255)')			build_stage,
n.value('(action[@name="session_id"]/value)[1]', 'int')					session_id,
(n.value('(data[@name="rows_inserted"]/value)[1]', 'float') / 84726836.0) * 100.0 percent_complete,  
master.dbo.time_to_complete(n.value('(data[@name="rows_inserted"]/value)[1]', 'float'),84726836.0, r.start_time) tme_to_complete,

n.value('(action[@name="database_name"]/value)[1]', 'varchar(255)')		database_name,
n.value('(data[@name="object_id"]/value)[1]', 'int')					object_id,
n.value('(data[@name="index_id"]/value)[1]', 'int')						index_id,
n.value('(data[@name="rows_inserted"]/value)[1]', 'bigint')				rows_inserted,
n.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)')	client_app_name
from (
select cast(event_data as XML) xmlvalue
from (
select event_data
from (
select row_number() over(order by file_offset) id, count(*) over() idd, event_data
from sys.fn_xe_file_target_read_file('I:\MSSQL13.MSSQLSERVER\MSSQL\Log\index_oper_pc_ttc*.xel', null, null, null))c
where id = idd)b
)a
cross apply a.XMLvalue.nodes('event') as q(n)
cross apply sys.dm_exec_requests r
where r.session_id = 82

select xmlvalue,
n.value('(data[@name="database_id"]/value)[1]', 'int')					database_id,
n.value('(data[@name="build_stage"]/text)[1]', 'varchar(255)')			build_stage,
n.value('(action[@name="session_id"]/value)[1]', 'int')					session_id,
n.value('(action[@name="database_name"]/value)[1]', 'varchar(255)')		database_name,
n.value('(data[@name="object_id"]/value)[1]', 'int')					object_id,
n.value('(data[@name="index_id"]/value)[1]', 'int')						index_id,
n.value('(data[@name="rows_inserted"]/value)[1]', 'bigint')				rows_inserted,
n.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)')	client_app_name
from (
select cast(event_data as xml) XMLvalue
from sys.fn_xe_file_target_read_file('I:\MSSQL13.MSSQLSERVER\MSSQL\Log\index_oper_pc_ttc_0_133347599435320000.xel', null, null, null))a
cross apply a.xmlvalue.nodes('event') as q(n)
