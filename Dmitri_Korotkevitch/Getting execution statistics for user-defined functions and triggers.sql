SELECT TOP 50
    DB_NAME(fs.database_id) AS [DB]
    ,OBJECT_NAME(fs.object_id, fs.database_id) AS [Function]
  
= 0,
IIF(datediff(second,fs.cached_time, fs.last_execution_time)
    NULL,
    1.0 * fs.execution_count /
,fs.type_desc AS [Type]
,fs.cached_time AS [Cached Time]
,fs.last_execution_time AS [Last Exec Time]
,qp.query_plan AS [Plan]
,fs.execution_count AS [Exec Count]
,CONVERT(DECIMAL(10,5),
                 datediff(second,fs.cached_time,
fs.last_execution_time)
        )
    ) AS [Exec Per Second]
    ,(fs.total_logical_reads + fs.total_logical_writes) /
        fs.execution_count AS [Avg IO]
    ,(fs.total_worker_time / fs.execution_count / 1000) AS [Avg
CPU(ms)]
    ,fs.total_logical_reads AS [Total Reads]
    ,fs.last_logical_reads AS [Last Reads]
    ,fs.total_logical_writes AS [Total Writes]
    ,fs.last_logical_writes AS [Last Writes]
    ,fs.total_worker_time / 1000 AS [Total Worker Time]
    ,fs.last_worker_time / 1000 AS [Last Worker Time]
    ,fs.total_elapsed_time / 1000 AS [Total Elapsed Time]
    ,fs.last_elapsed_time / 1000 AS [Last Elapsed Time]
    ,fs.total_physical_reads AS [Total Physical Reads]
    ,fs.last_physical_reads AS [Last Physical Reads]
    ,fs.total_physical_reads / fs.execution_count AS [Avg Physical
Reads] FROM
    sys.dm_exec_function_stats fs WITH (NOLOCK)
        CROSS APPLY sys.dm_exec_query_plan(fs.plan_handle) qp
ORDER BY
     [Avg IO] DESC
OPTION (RECOMPILE, MAXDOP 1);
SELECT TOP 50
    DB_NAME(ts.database_id) AS [DB]
    ,OBJECT_NAME(ts.object_id, ts.database_id) AS [Function]
    ,ts.type_desc AS [Type]
    ,ts.cached_time AS [Cached Time]
    ,ts.last_execution_time AS [Last Exec Time]
    ,qp.query_plan AS [Plan]
    ,ts.execution_count AS [Exec Count]
    ,CONVERT(DECIMAL(10,5),
= 0,
IIF(datediff(second,ts.cached_time, ts.last_execution_time)
    NULL,

            1.0 * ts.execution_count /
                datediff(second,ts.cached_time,
ts.last_execution_time)
        )
    ) AS [Exec Per Second]
    ,(ts.total_logical_reads + ts.total_logical_writes) /
        ts.execution_count AS [Avg IO]
    ,(ts.total_worker_time / ts.execution_count / 1000) AS [Avg
CPU(ms)]
    ,ts.total_logical_reads AS [Total Reads]
    ,ts.last_logical_reads AS [Last Reads]
    ,ts.total_logical_writes AS [Total Writes]
    ,ts.last_logical_writes AS [Last Writes]
    ,ts.total_worker_time / 1000 AS [Total Worker Time]
    ,ts.last_worker_time / 1000 AS [Last Worker Time]
    ,ts.total_elapsed_time / 1000 AS [Total Elapsed Time]
    ,ts.last_elapsed_time / 1000 AS [Last Elapsed Time]
    ,ts.total_physical_reads AS [Total Physical Reads]
    ,ts.last_physical_reads AS [Last Physical Reads]
    ,ts.total_physical_reads / ts.execution_count AS [Avg Physical
Reads] FROM
    sys.dm_exec_trigger_stats ts WITH (NOLOCK)
        CROSS APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
ORDER BY
     [Avg IO] DESC
OPTION (RECOMPILE, MAXDOP 1);