select * 
from sys.dm_os_wait_stats
where wait_type = 'Resource_Semaphore'

select *
from (
select 
wait_type, 
waiting_tasks_count, 
wait_time_ms, signal_wait_time_ms "Runnable_wait_time", 
wait_time_ms- signal_wait_time_ms "Resource_wait_time (Suspended)",
cast((cast(waiting_tasks_count as float) / cast(SUM(waiting_tasks_count) over() as float)) * 100.0 as numeric(10,2))wait_percent
from sys.dm_os_wait_stats)a
where waiting_tasks_count > 0 
order by wait_percent desc

SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%signal (cpu) waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2))
AS [%resource waits] FROM sys.dm_os_wait_stats OPTION (RECOMPILE);


