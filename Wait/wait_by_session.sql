select 
wait_type,
waiting_tasks_count, cast(cast(waiting_tasks_count as float) / cast(sum(waiting_tasks_count) over() as float) * 100.0 as numeric(10,2)) [waiting_tasks_count%], 
wait_time_ms, cast(cast(wait_time_ms as float) / cast(sum(wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [wait_time_ms%], 
max_wait_time_ms, cast(cast(max_wait_time_ms as float) / cast(sum(max_wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [max_wait_time_ms%], 
signal_wait_time_ms, cast(cast(signal_wait_time_ms as float) / cast(sum(signal_wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [signal_wait_time_ms%]
from sys.dm_exec_session_wait_stats 
where session_id = 726
and wait_type not in ('SLEEP_TASK')
order by waiting_tasks_count desc