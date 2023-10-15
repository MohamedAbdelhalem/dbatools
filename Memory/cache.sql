SELECT name, master.dbo.numbersize(pages_kb,'k'), 0 
FROM sys.dm_os_memory_cache_counters
WHERE name IN ('Object Plans', 'SQL Plans', 'Bound Trees', 'Extended Stored Procedures', 'Temporary Tables & Table Variables')
