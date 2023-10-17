--how work can achieve the runnable task
declare @task_estimated_time_sec float = (1 /1000.0)
SELECT 
	 STATE
	,count(*) AS NumWorkers
	,master.dbo.duration('ms',(((@task_estimated_time_sec * 1000) / 4.0) * 4.0) + ((1-1) * 4) * ((@task_estimated_time_sec * 1000) / 4.0) ) expected
	,master.dbo.duration('ms',(((@task_estimated_time_sec * 1000) / 4.0) * 4.0) + ((count(*)-1) * 4) * ((@task_estimated_time_sec * 1000) / 4.0) ) actual_waiting_time,
	ceiling((((@task_estimated_time_sec * 1000) / 4.0) * 4.0) + ((count(*)-1) * 4) * ((@task_estimated_time_sec * 1000) / 4.0) / 4.0) yield_switch_n
FROM sys.dm_os_workers
where state = 'RUNNABLE'
GROUP BY STATE
ORDER BY count(*) DESC