--select * from sys.dm_os_waiting_tasks

select *, 
(cast(waiting_tasks_count as float) /SUM(waiting_tasks_count) over()) * 100.0 [waiting_tasks Pct%],
(cast(wait_time_ms as float) /SUM(wait_time_ms) over()) * 100.0 [wait_time Pct%]
from sys.dm_os_wait_stats
where wait_type not in ('SLEEP_TASK',
'HADR_CLUSAPI_CALL',
'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
'HADR_LOGCAPTURE_WAIT',
'HADR_NOTIFICATION_DEQUEUE',
'HADR_TIMER_TASK',
'HADR_WORK_QUEUE'
)
order by waiting_tasks_count desc

