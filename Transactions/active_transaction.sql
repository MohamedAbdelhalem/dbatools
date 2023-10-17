--select transaction_id, name, transaction_begin_time, master.dbo.duration('s',datediff(s,transaction_begin_time,getdate())) transaction_duration,
--case transaction_type
--when 1 then 'Read/write transaction'
--when 2 then 'Read-only transaction'
--when 3 then 'System transaction'
--when 4 then 'Distributed transaction'
--end transaction_type,
--case transaction_state
--when 0 then 'The transaction has not been completely initialized yet.'
--when 1 then 'The transaction has been initialized but has not started.'
--when 2 then 'The transaction is active.'
--when 3 then 'The transaction has ended. This is used for read-only transactions.'
--when 4 then 'The commit process has been initiated on the distributed transaction. This is for distributed transactions only. The distributed transaction is still active but further processing cannot take place.'
--when 5 then 'The transaction is in a prepared state and waiting resolution.'
--when 6 then 'The transaction has been committed.'
--when 7 then 'The transaction is being rolled back.'
--when 8 then 'The transaction has been rolled back.'
--end transaction_state,
--case dtc_state
--when 1 then 'ACTIVE'
--when 2 then 'PREPARED'
--when 3 then 'COMMITTED'
--when 4 then 'ABORTED'
--when 5 then 'RECOVERED'
--end dtc_state,
--dtc_isolation_level
--from sys.dm_tran_active_transactions
--order by transaction_type desc, transaction_begin_time 

select dbt.transaction_id, session_id, tat.name transaction_name, ssql.text, substring(ssql.text, stmt_start/2+1, stmt_end/2+1) affected_sql_exec,
db_name(database_id) database_name,
master.dbo.format(database_transaction_log_record_count,-1) transaction_log_record_count,
master.dbo.format(database_transaction_replicate_record_count,-1) transaction_replicate_record_count,
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
--where database_id = db_id()
--order by transaction_duration desc, database_transaction_type desc
order by session_id desc, database_transaction_log_bytes_used desc, database_transaction_type desc


--select * FROM sys.traces 
--SELECT SUBSTRING(path, 0,
--   LEN(path)-CHARINDEX('\', REVERSE(path))+1) + '\Log.trc'  
--FROM sys.traces   
--WHERE is_default = 1;  

--SELECT   
--     o.name,   
--     o.OBJECT_ID,  
--     o.create_date, 
--     gt.NTUserName,  
--     gt.HostName,  
--     gt.SPID,  
--     gt.DatabaseName,  
--     gt.TEXTData 
----FROM sys.fn_trace_gettable( 'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\log_38.trc', DEFAULT ) AS gt  
--FROM sys.fn_trace_gettable( 'E:\SYSDB\MSSQL12.MSSQLSERVER\MSSQL\Log\log_57.trc', DEFAULT ) AS gt  
--JOIN tempdb.sys.objects AS o   
--     ON gt.ObjectID = o.OBJECT_ID  
--WHERE gt.DatabaseID = 2 
--  AND gt.EventClass = 46 -- (Object:Created Event from sys.trace_events)  
--  AND o.create_date >= DATEADD(ms, -100, gt.StartTime)   
--  AND o.create_date <= DATEADD(ms, 100, gt.StartTime)
--386.54705664


--
select * from sys.dm_tran_aborted_transactions
select sum(1) from sys.dm_tran_version_store

--select * from sys.fn_dblog(859612000000792700001,null)

--ALTER DATABASE SSISDB SET DELAYED_DURABILITY = { DISABLED | ALLOWED | FORCED }  
--select * from sys.fn_dblog(null,null)
--USE [SSISDB]   DBCC SHRINKFILE (N'log' , 100)


select count(*), lastwaittype, status
from sys.sysprocesses
where status != 'sleeping'
and lastwaittype not in (
        -- These wait types are almost 100% never a problem and so they are
        -- filtered out to avoid them skewing the results. Click on the URL
        -- for more information.
        N'BROKER_EVENTHANDLER', -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
        N'BROKER_RECEIVE_WAITFOR', -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
        N'BROKER_TASK_STOP', -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
        N'BROKER_TO_FLUSH', -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
        N'BROKER_TRANSMITTER', -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
        N'CHECKPOINT_QUEUE', -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
        N'CHKPT', -- https://www.sqlskills.com/help/waits/CHKPT
        N'CLR_AUTO_EVENT', -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
        N'CLR_MANUAL_EVENT', -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
        N'CLR_SEMAPHORE', -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE
        -- Maybe comment this out if you have parallelism issues
--        N'CXCONSUMER', -- https://www.sqlskills.com/help/waits/CXCONSUMER
        -- Maybe comment these four out if you have mirroring issues
        N'DBMIRROR_DBM_EVENT', -- https://www.sqlskills.com/help/waits/DBMIRROR_DBM_EVENT
        N'DBMIRROR_EVENTS_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_EVENTS_QUEUE
        N'DBMIRROR_WORKER_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_WORKER_QUEUE
        N'DBMIRRORING_CMD', -- https://www.sqlskills.com/help/waits/DBMIRRORING_CMD
        N'DIRTY_PAGE_POLL', -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
        N'DISPATCHER_QUEUE_SEMAPHORE', -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
        N'EXECSYNC', -- https://www.sqlskills.com/help/waits/EXECSYNC
        N'FSAGENT', -- https://www.sqlskills.com/help/waits/FSAGENT
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
        N'FT_IFTSHC_MUTEX', -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX
       -- Maybe comment these six out if you have AG issues
        N'HADR_CLUSAPI_CALL', -- https://www.sqlskills.com/help/waits/HADR_CLUSAPI_CALL
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETI', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
        N'HADR_LOGCAPTURE_WAIT', -- https://www.sqlskills.com/help/waits/HADR_LOGCAPTURE_WAIT
        N'HADR_NOTIFICATION_DEQUEUE', -- https://www.sqlskills.com/help/waits/HADR_NOTIFICATION_DEQUEUE
        N'HADR_TIMER_TASK', -- https://www.sqlskills.com/help/waits/HADR_TIMER_TASK
        N'HADR_WORK_QUEUE', -- https://www.sqlskills.com/help/waits/HADR_WORK_QUEUE 
        N'KSOURCE_WAKEUP', -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
        N'LAZYWRITER_SLEEP', -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
        N'LOGMGR_QUEUE', -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
        N'MEMORY_ALLOCATION_EXT', -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
        N'ONDEMAND_TASK_QUEUE', -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
        N'PARALLEL_REDO_DRAIN_WORKER', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
        N'PARALLEL_REDO_LOG_CACHE', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
        N'PARALLEL_REDO_TRAN_LIST', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
        N'PARALLEL_REDO_WORKER_SYNC', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
        N'PARALLEL_REDO_WORKER_WAIT_WORK', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
        N'PREEMPTIVE_OS_FLUSHFILEBUFFERS', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_OS_FLUSHFILEBUFFERS
        N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
        N'PVS_PREALLOCATE', -- https://www.sqlskills.com/help/waits/PVS_PREALLOCATE
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK', -- https://www.sqlskills.com/help/waits/PWAIT_EXTENSIBILITY_CLEANUP_TASK
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
        N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
        N'QDS_SHUTDOWN_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
        N'REDO_THREAD_PENDING_WORK', -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
        N'REQUEST_FOR_DEADLOCK_SEARCH', -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
        N'RESOURCE_QUEUE', -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
        N'SERVER_IDLE_CHECK', -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
        N'SLEEP_BPOOL_FLUSH', -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
        N'SLEEP_DBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
        N'SLEEP_DCOMSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
        N'SLEEP_MASTERDBREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
        N'SLEEP_MASTERMDREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
        N'SLEEP_MASTERUPGRADED', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
        N'SLEEP_MSDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
        N'SLEEP_SYSTEMTASK', -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
        N'SLEEP_TASK', -- https://www.sqlskills.com/help/waits/SLEEP_TASK
        N'SLEEP_TEMPDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
        N'SNI_HTTP_ACCEPT', -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
        N'SOS_WORK_DISPATCHER', -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
        N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
        N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
        N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
        N'VDI_CLIENT_OTHER', -- https://www.sqlskills.com/help/waits/VDI_CLIENT_OTHER
        N'WAIT_FOR_RESULTS', -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
        N'WAITFOR', -- https://www.sqlskills.com/help/waits/WAITFOR
        N'WAITFOR_TASKSHUTDOWN', -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
        N'WAIT_XTP_RECOVERY', -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
        N'WAIT_XTP_HOST_WAIT', -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
        N'WAIT_XTP_CKPT_CLOSE', -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
        N'XE_DISPATCHER_JOIN', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
        N'XE_DISPATCHER_WAIT', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
        N'XE_TIMER_EVENT' -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
        )
group by lastwaittype, status
order by count(*) desc

select mf.type_desc, mf.name, mf.physical_name, db.log_reuse_wait_desc,  master.dbo.numberSize(size *8.0,'kb') file_size,
master.dbo.numbersize(fileproperty(mf.name, 'spaceused') * 8.0, 'kb') used_space,
cast(((fileproperty(mf.name, 'spaceused') * 8.0) / (size *8.0)) * 100.0 as numeric(10,2)) [used space %]
from sys.databases db inner join sys.master_files mf
on db.database_id = mf.database_id
where db.database_id = db_id() 
and mf.type = 1


select count(*) sessions,
db_name(database_id) database_name,
master.dbo.format(sum(database_transaction_log_record_count),-1) transaction_log_record_count,
master.dbo.format(sum(database_transaction_replicate_record_count),-1) transaction_replicate_record_count,
master.dbo.numbersize(sum(database_transaction_log_bytes_used),'byte') transaction_log_used,
master.dbo.numbersize(sum(database_transaction_log_bytes_reserved),'byte') UNDO_REDO,--transaction_log_reserved ,
master.dbo.numbersize(sum(database_transaction_log_bytes_used + database_transaction_log_bytes_reserved),'byte') transaction_size, 
master.dbo.numbersize(sum(database_transaction_log_bytes_used_system),'byte') transaction_log_used_system,
master.dbo.numbersize(sum(database_transaction_log_bytes_reserved_system),'byte') transaction_log_reserved_system,
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
end database_transaction_state
from sys.dm_tran_database_transactions dbt left outer join
sys.dm_tran_session_transactions st
on dbt.transaction_id = st.transaction_id
--where database_id = db_id('VRPCrmIntegration')
group by database_id, database_transaction_type, database_transaction_state
order by sum(database_transaction_log_record_count) desc, database_name

select * from sys.sysprocesses
where spid = 3

