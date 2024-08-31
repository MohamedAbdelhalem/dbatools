;WITH Waits
AS
(
 SELECT 
	wait_type, 
	wait_time_ms, 
	waiting_tasks_count,
	signal_wait_time_ms,
	wait_time_ms - signal_wait_time_ms as resource_wait_time_ms,
	100. * wait_time_ms / SUM(wait_time_ms) OVER() as Pct,
	100. * SUM(wait_time_ms) OVER(ORDER BY wait_time_ms DESC) / NULLIF(SUM(wait_time_ms) OVER(), 0) as RunningPct,
	ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) as RowNum
 FROM sys.dm_os_wait_stats WITH (NOLOCK)
 WHERE wait_type NOT IN (select wait_type from dbo.ExcludedWaits) 
)
SELECT 
	w1.wait_type as [Wait Type],
	w1.waiting_tasks_count as [Wait Count],
	master.dbo.duration('s',CONVERT(DECIMAL(12,3), w1.wait_time_ms / 1000.0)) as [Wait Time],
	CONVERT(DECIMAL(12,1), w1.wait_time_ms / w1.waiting_tasks_count) as [Avg Wait Time],
	master.dbo.duration('ms',CONVERT(DECIMAL(12,3), w1.signal_wait_time_ms)) as [Signal Wait Time],
	--master.dbo.duration('s',CONVERT(DECIMAL(12,3), w1.signal_wait_time_ms / 1000.0)) as [Signal Wait Time],
	CONVERT(DECIMAL(12,1), w1.signal_wait_time_ms /w1.waiting_tasks_count) as [Avg Signal Wait Time],
	master.dbo.duration('ms',CONVERT(DECIMAL(12,3), w1.resource_wait_time_ms)) as [Resource Wait Time],
	--master.dbo.duration('s',CONVERT(DECIMAL(12,3), w1.resource_wait_time_ms / 1000.0)) as [Resource Wait Time],
	CONVERT(DECIMAL(12,1), w1.resource_wait_time_ms /w1.waiting_tasks_count) as [Avg Resource Wait Time],
	CONVERT(DECIMAL(6,3), w1.Pct) as [Percent],
	CONVERT(DECIMAL(6,3), w1.RunningPct) as [Running Percent]
FROM Waits w1
WHERE w1.RunningPct <= 99 
OR w1.RowNum = 1
ORDER BY w1. RunningPct 
OPTION (RECOMPILE, MAXDOP 1);
