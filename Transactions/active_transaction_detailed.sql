select dbt.transaction_id, session_id, tat.name transaction_name, ssql.text, 
substring(ssql.text, stmt_start/2+1, (stmt_end/2+1)-(stmt_start/2+1)) affected_sql_exec,
db_name(database_id) database_name,
master.dbo.format(database_transaction_log_record_count,-1) transaction_log_record_count,
master.dbo.numbersize(database_transaction_log_bytes_used,'byte') transaction_log_used,
master.dbo.numbersize(database_transaction_log_bytes_reserved,'byte') UNDO_REDO,--transaction_log_reserved,
master.dbo.numbersize(database_transaction_log_bytes_used + database_transaction_log_bytes_reserved,'byte') transaction_size, 
master.dbo.format(database_transaction_replicate_record_count,-1) transaction_replicate_record_count,
master.dbo.numbersize(database_transaction_log_bytes_used_system,'byte') transaction_log_used_system,
master.dbo.numbersize(database_transaction_log_bytes_reserved_system,'byte') transaction_log_reserved_system,
master.dbo.duration('s',datediff(s,database_transaction_begin_time,getdate())) transaction_duration,
case database_transaction_type
when 1 then 'Read/write transaction'
when 2 then 'Read-only transaction'
when 3 then 'System transaction'
when 4 then 'Distributed'	 
else 'Unknown - ' + convert(varchar(20), transaction_type)
end database_transaction_type,
isnull(tat.transaction_state,-1) transaction_state,
case tat.transaction_state
when 0 then 'Uninitialized' 
when 1 then 'Not Yet Started' 
when 2 then 'Active' 
when 3 then 'Ended (Read-Only)' 
when 4 then 'Committing' 
when 5 then 'Prepared' 
when 6 then 'Committed' 
when 7 then 'Rolling Back' 
when 8 then 'Rolled Back' 
else 'db not instance level' + isnull(convert(varchar(20), transaction_state),'') 
end as Instance_tran_State, 
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
--where st.session_id = 1942
--where database_id = db_id()
--order by transaction_duration desc, database_transaction_type desc
--order by session_id desc, database_transaction_log_bytes_used desc, database_transaction_type desc
order by transaction_state desc, database_transaction_log_bytes_used + database_transaction_log_bytes_reserved desc

