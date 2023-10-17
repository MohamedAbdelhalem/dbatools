SELECT [name], [type], [entries_count], [entries_in_use_count]
      FROM sys.dm_os_memory_cache_counters
      WHERE [type] = N'CACHESTORE_TEMPTABLES' 

