select dbt.transaction_id, session_id, tat.name transaction_name,event_info, ssql.text, substring(ssql.text, stmt_start/2+1, (stmt_end/2+1) - (stmt_start/2+1) + 1) affected_sql_exec,
db_name(database_id) database_name,
master.dbo.format(database_transaction_log_record_count,-1) transaction_log_record_count,
--master.dbo.format(database_transaction_replicate_record_count,-1) transaction_replicate_record_count,
master.dbo.numbersize(database_transaction_log_bytes_used,'byte') transaction_log_used,
master.dbo.numbersize(database_transaction_log_bytes_reserved,'byte') UNDO_REDO,--transaction_log_reserved,
master.dbo.numbersize(database_transaction_log_bytes_used + database_transaction_log_bytes_reserved,'byte') transaction_size, 
master.dbo.numbersize(database_transaction_log_bytes_used_system,'byte') transaction_log_used_system,
master.dbo.numbersize(database_transaction_log_bytes_reserved_system,'byte') transaction_log_reserved_system,
master.dbo.duration('s',datediff(s,database_transaction_begin_time,getdate())) transaction_duration,
case database_transaction_type
when 1 then 'Read/write transaction'
when 2 then 'Read-only transaction'
when 3 then 'System transaction'
end database_transaction_type,
case database_transaction_state
when 1 then 'The transaction has not been initialized.'
when 3 then 'The transaction has been initialized but has not generated any log records.'
when 4 then 'The transaction has generated log records.'
when 5 then 'The transaction has been prepared.'
when 10 then 'The transaction has been committed.'
when 11 then 'The transaction has been rolled back.'
when 12 then 'The transaction is being committed. (The log record is being generated, but has not been materialized or persisted.)'
end database_transaction_state,
database_transaction_begin_lsn,
database_transaction_last_lsn,
database_transaction_most_recent_savepoint_lsn,
database_transaction_commit_lsn,
database_transaction_last_rollback_lsn,
database_transaction_next_undo_lsn
from sys.dm_tran_database_transactions dbt left outer join
sys.dm_tran_session_transactions st
on dbt.transaction_id = st.transaction_id
left outer join (select spid, s.text, p.stmt_start, stmt_end from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s)ssql
on st.session_id = ssql.spid
left outer join sys.dm_tran_active_transactions tat
on dbt.transaction_id = tat.transaction_id
cross apply sys.dm_exec_input_buffer(session_id,0)
--where session_id in (180)
--order by transaction_duration desc, database_transaction_type desc
order by database_transaction_log_record_count desc, session_id desc, database_transaction_log_bytes_used desc, database_transaction_type desc

