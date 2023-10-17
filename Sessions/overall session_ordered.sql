select * from (
select --s.*, 
--ltrim(rtrim(master.dbo.vertical_array(s.value,'.',3))), ltrim(rtrim(master.dbo.vertical_array(sql_text,'.',3))),
spid,open_tran,
case 
when spid   in (select blocked from sys.sysprocesses) then 0
when status = 'suspended' and blocked > 0 then 1 
when status = 'suspended' and blocked = 0 then 2 
when status = 'Runnable' then 3
when status = 'Running'	 then 4		
when status = 'Sleeping' and open_tran = 1 then 9 
when status = 'Sleeping' then 10 
else 5 end flag_status,
percent_complete, [db_name], loginame, status, command, cpu, lastwaittype, blocked, 
backup_date, backup_time, 
duration, start_time, text, sql_text, waittime, client_net_address, hostname, program_name, convert(xml,query_plan) query_plan
from (
select distinct spid, p.open_tran,  percent_complete, db_name(p.dbid) [db_name], loginame,p.status, lastwaittype,r.start_time, last_batch,
r.command,
--master.dbo.date_yyyymmddhhmiss(
convert(varchar(10), convert(datetime, left(case 
when r.command like 'restore%' then 
substring(reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)), 1, charindex('.',reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)))-1) end, 8), 111), 120)
backup_date, 
right(case 
when r.command like 'restore%' then 
substring(reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)), 1, charindex('.',reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)))-1) end, 6) 
backup_time, cpu,
master.dbo.duration('s',datediff(s,isnull(r.start_time,p.last_batch),getdate())) duration,
s.text, substring(s.text,(p.stmt_start/2)+1,((p.stmt_end/2)-(p.stmt_start/2))+2) sql_text,-- sp.id,  --sp.value code, 
waittime, blocked, client_net_address, hostname, program_name, 
pan.*
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
inner join sys.dm_exec_connections c 
on p.spid = c.session_id
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
left outer join (select r.session_id, convert(nvarchar(max),p.query_plan) query_plan from sys.dm_exec_requests r cross apply sys.dm_exec_query_plan(r.plan_handle)p)pan
on r.session_id = pan.session_id
where p.spid != @@spid
--and loginame like 'ALBILAD%'
--and p.spid in (2262)
--and text not like '%sp_server_diagnostics%'
)a
where [db_name] not in ('msdb')
and loginame not in ('ALBILAD\WinMengine','ALBILAD\SVC_SQLMonitor')
and text not like '%SP_SERVER_DIAGNOSTICS_SLEEP%'
--and text like '%F_OS_TOKEN%'
--and hostname in ('D1T24APDWPWV1', 'D2T24APUXPWV1')
--cross apply master.dbo.Separator(a.text, char(10))s
--cross apply master.dbo.Separator(a.sql_text, char(10))s
--and status != 'sleeping'
--and spid in (60)
--where db_name = 'BAB_MIS_Archive'
)v
order by --s.id,
flag_status,blocked, CPU desc, sql_text,db_name,spid
--kill 1340
--if (select COUNT(*) from from sys.dm_tran_database_transactions dbt left outer join
--sys.dm_tran_session_transactions st
--on dbt.transaction_id = st.transaction_id
--left outer join (select spid, s.text, p.stmt_start, stmt_end from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s)ssql
--on st.session_id = ssql.spid
--left outer join sys.dm_tran_active_transactions tat
--on dbt.transaction_id = tat.transaction_id
--where session_id in (select spid FROM sys.sysprocesses WHERE spid in (select blocked from sys.sysprocesses where blocked > 0) and status = 'sleeping' and open_tran = 1)

--select dbt.transaction_id, session_id, last_batch, master.dbo.duration('s',DATEDIFF(s,last_batch,getdate())) duration,
--tat.name transaction_name,event_info, ssql.text, substring(ssql.text, stmt_start/2+1, (stmt_end/2+1) - (stmt_start/2+1) + 1) affected_sql_exec,
--db_name(database_id) database_name,
--master.dbo.format(database_transaction_log_record_count,-1) transaction_log_record_count,
----master.dbo.format(database_transaction_replicate_record_count,-1) transaction_replicate_record_count,
--master.dbo.numbersize(database_transaction_log_bytes_used,'byte') transaction_log_used,
--master.dbo.numbersize(database_transaction_log_bytes_reserved,'byte') UNDO_REDO,--transaction_log_reserved,
--master.dbo.numbersize(database_transaction_log_bytes_used + database_transaction_log_bytes_reserved,'byte') transaction_size, 
--master.dbo.numbersize(database_transaction_log_bytes_used_system,'byte') transaction_log_used_system,
--master.dbo.numbersize(database_transaction_log_bytes_reserved_system,'byte') transaction_log_reserved_system,
--master.dbo.duration('s',datediff(s,database_transaction_begin_time,getdate())) transaction_duration,
--case database_transaction_type
--when 1 then 'Read/write transaction'
--when 2 then 'Read-only transaction'
--when 3 then 'System transaction'
--end database_transaction_type,
--case database_transaction_state
--when 1 then 'The transaction has not been initialized.'
--when 3 then 'The transaction has been initialized but has not generated any log records.'
--when 4 then 'The transaction has generated log records.'
--when 5 then 'The transaction has been prepared.'
--when 10 then 'The transaction has been committed.'
--when 11 then 'The transaction has been rolled back.'
--when 12 then 'The transaction is being committed. (The log record is being generated, but has not been materialized or persisted.)'
--end database_transaction_state,
--database_transaction_begin_lsn,
--database_transaction_last_lsn,
--database_transaction_most_recent_savepoint_lsn,
--database_transaction_commit_lsn,
--database_transaction_last_rollback_lsn,
--database_transaction_next_undo_lsn
--from sys.dm_tran_database_transactions dbt left outer join
--sys.dm_tran_session_transactions st
--on dbt.transaction_id = st.transaction_id
--left outer join (select spid, s.text, p.stmt_start, stmt_end, last_batch from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s)ssql
--on st.session_id = ssql.spid
--left outer join sys.dm_tran_active_transactions tat
--on dbt.transaction_id = tat.transaction_id
--cross apply sys.dm_exec_input_buffer(session_id,0)
--where session_id in (select spid FROM sys.sysprocesses --WHERE spid in (select spid from sys.sysprocesses ) 
--where session_id in (782,1340,453))
----status = 'sleeping' and open_tran = 1)
----order by transaction_duration desc, database_transaction_type desc
--order by database_transaction_log_record_count desc, session_id desc, database_transaction_log_bytes_used desc, database_transaction_type desc


--kill 782
