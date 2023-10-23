SELECT master.dbo.NumberSize(sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(19,3))),'b') size_AdHoc_plans
FROM sys.dm_exec_cached_plans
