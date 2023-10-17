select a.id group_id, s.id row_id, session_id,
database_name,
command, status,last_wait_type,
duration, cpu_time,
a.text, s.value readable_sql_text, 
logical_reads, reads, writes,
command_text, login_name,
host_name,
program_name
from (
select top 10 row_number() over(order by req.cpu_time desc)id, ses.session_id,req.status,req.cpu_time,req.logical_reads,req.reads,req.writes, req.last_wait_type,
convert(varchar(20), dateadd(s, req.total_elapsed_time / (1000 * 60), '2000-01-01'),108) 'Elaps M',
s.text,
substring(s.text, (req.statement_start_offset / 2) + 1, ((
case req.statement_end_offset when -1 then DATALENGTH(s.text) else req.statement_end_offset end - req.statement_start_offset) / 2) + 1) sql_text,
db_name(ses.database_id) database_name, s.objectid,
req.command,
COALESCE(QUOTENAME(DB_NAME(ses.database_id)) + N'.' + QUOTENAME(OBJECT_SCHEMA_NAME(s.objectid, ses.database_id)) 
+ N'.' + QUOTENAME(OBJECT_NAME(s.objectid, ses.database_id)), '') AS command_text,
ses.login_name,
ses.host_name,
ses.program_name,
ses.last_request_end_time,
master.dbo.duration('s',datediff(s,req.start_time,getdate())) duration,
ses.login_time,
req.open_transaction_count
from sys.dm_exec_sessions AS ses inner join sys.dm_exec_requests AS req 
on req.session_id = ses.session_id 
cross apply sys.dm_exec_sql_text(req.sql_handle) s
where req.session_id != @@SPID
and s.text not like 'sp_server_diagnostics%'
order by req.cpu_time desc)a
cross apply master.dbo.Separator(a.sql_text, char(10))s
--cross apply master.dbo.Separator(a.text, char(10))s
order by a.id, s.id

