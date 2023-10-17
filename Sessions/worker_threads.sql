select * from sys.dm_os_workers
select * from sys.dm_os_threads
select * from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE'

select max_workers_count, current_workers, cast(cast(current_workers as float) / cast(max_workers_count as float) * 100.0 as numeric(10,2)) pct
from (
select max_workers_count, ( SELECT count(*) current_workers
FROM sys.dm_os_workers
where state = 'SUSPENDED') current_workers
from sys.dm_os_sys_info) a

select max_workers_count, current_workers, cast(cast(current_workers as float) / cast(max_workers_count as float) * 100.0 as numeric(10,2)) pct
from (
select max_workers_count, ( SELECT count(*) current_workers
FROM sys.dm_os_workers) current_workers
from sys.dm_os_sys_info) a

select max_workers_count, current_workers, cast(cast(current_workers as float) / cast(max_workers_count as float) * 100.0 as numeric(10,2)) pct from (select max_workers_count, (SELECT count(*) current_workers FROM sys.dm_os_workers where state = 'SUSPENDED') current_workers from sys.dm_os_sys_info) a

SELECT STATE
	,last_wait_type
	,count(*) AS NumWorkers
FROM sys.dm_os_workers
where last_wait_type not in (
'MISCELLANEOUS',
        N'BROKER_EVENTHANDLER',
        N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',
        N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',
        N'CHECKPOINT_QUEUE',
        N'CHKPT',
        N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',
        N'CLR_SEMAPHORE',
        -- Maybe comment this out if you have parallelism issues
        N'CXCONSUMER',
        -- Maybe comment these four out if you have mirroring issues
        N'DBMIRROR_DBM_EVENT',
        N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',
        N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',
        N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',
        N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT',
        N'FT_IFTSHC_MUTEX',
       -- Maybe comment these six out if you have AG issues
        N'HADR_CLUSAPI_CALL',
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',
        N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',
        N'HADR_WORK_QUEUE',
---------------------------------------------
        N'KSOURCE_WAKEUP',
        N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',
        N'MEMORY_ALLOCATION_EXT',
        N'ONDEMAND_TASK_QUEUE',
        N'PARALLEL_REDO_DRAIN_WORKER',
        N'PARALLEL_REDO_LOG_CACHE',
        N'PARALLEL_REDO_TRAN_LIST',
        N'PARALLEL_REDO_WORKER_SYNC',
        N'PARALLEL_REDO_WORKER_WAIT_WORK',
        N'PREEMPTIVE_OS_FLUSHFILEBUFFERS',
        N'PREEMPTIVE_XE_GETTARGETSTATE',
        N'PVS_PREALLOCATE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'QDS_SHUTDOWN_QUEUE',
        N'REDO_THREAD_PENDING_WORK',
        N'REQUEST_FOR_DEADLOCK_SEARCH',
        N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',
        N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',
        N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',
        N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',
        N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',
        N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',
        N'SNI_HTTP_ACCEPT',
        N'SOS_WORK_DISPATCHER',
        N'SP_SERVER_DIAGNOSTICS_SLEEP',
        N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',
        N'VDI_CLIENT_OTHER',
        N'WAIT_FOR_RESULTS',
        N'WAITFOR',
        N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_RECOVERY',
        N'WAIT_XTP_HOST_WAIT',
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',
        N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',
        N'XE_TIMER_EVENT'
		)
GROUP BY STATE
	,last_wait_type
ORDER BY case state when 'SUSPENDED' then 1 when 'RUNNABLE' then 2 when 'RUNNING' then 3 end, count(*) DESC

SELECT * FROM sys.dm_exec_input_buffer (66,1);

SELECT 
	 STATE
	,last_wait_type
	,count(*) AS NumWorkers
FROM sys.dm_os_workers
where last_wait_type != 'MISCELLANEOUS'
GROUP BY STATE
	,last_wait_type
ORDER BY count(*) DESC

--how work can achieve the runnable task
declare @task_estimated_time_sec float = (80 /1000.0)
SELECT 
	 STATE
	,count(*) AS NumWorkers
	--,master.dbo.duration('ms', 1 * 4.0) Expected_every_worker_waits_to_run_then_yield
	--,master.dbo.duration('ms',count(*) * 4.0) Actual_every_worker_waits_to_run_then_yield
	--,master.dbo.duration('ms',(@task_estimated_time_sec * 1000)* case when ((1-1) * 4.0) = 0 then 1 else ((1-1) * 4.0) end) Expected_every_worker_waits_to_run_then_yield_ffff
	--,master.dbo.duration('ms',(@task_estimated_time_sec * 1000)* case when ((count(*)-1) * 4.0) = 0 then 1 else ((count(*)-1) * 4.0) end) actual_every_worker_waits_to_run_then_yield_ffff
	,master.dbo.duration('ms',(((@task_estimated_time_sec * 1000) / 4.0) * 4.0) + ((1-1) * 4) * ((@task_estimated_time_sec * 1000) / 4.0) ) expected
	,master.dbo.duration('ms',(((@task_estimated_time_sec * 1000) / 4.0) * 4.0) + ((count(*)-1) * 4) * ((@task_estimated_time_sec * 1000) / 4.0) ) actual
FROM sys.dm_os_workers
where state = 'RUNNABLE'
GROUP BY STATE
ORDER BY count(*) DESC



select (1*1000.0) * (2) * 4

SELECT 
	last_wait_type
	,count(*) AS NumWorkers
FROM sys.dm_os_workers
GROUP BY
	last_wait_type
ORDER BY count(*) DESC


select  * from sys.dm_exec_requests

select * from sys.dm_os_workers 
select * from sys.dm_os_waiting_tasks
select * from sys.dm_io_pending_io_requests
--0x00000089EFB87BC8	network	94642806	1	0x00007FFAECDCBB00	0x00000089EFB87BC8	0x00000089FF5F0040	0x0000000000001404	0	NULL

select * from sys.dm_io_pending_io_requests

select * from sys.dm_os_worker_local_storage
select * from sys.dm_os_workers


select count(*), worker_address 
from sys.dm_os_workers
group by worker_address
having count(*) > 1



SELECT count(*) AS NumWorkers
FROM sys.dm_os_workers
