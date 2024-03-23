SELECT TOP 50
    qs.creation_time as [Cached Time]
    ,qs.last_execution_time as [Last Exec Time]
    ,SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
    ((
        CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2)+1) as SQL
    ,qp.query_plan as [Query Plan]
    ,qs.execution_count as [Exec Cnt]
,CONVERT(DECIMAL(10,5),
IIF(datediff(second,qs.creation_time,qs.last_execution_time) = 0, NULL, 1.0 * qs.execution_count /datediff(second,qs.creation_time, qs.last_execution_time))
) as [Exec Per Second]
    ,(qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count as [Avg IO]
    ,(qs.total_worker_time / qs.execution_count / 1000) as [Avg CPU(ms)]
    ,qs.total_logical_reads as [Total Reads]
    ,qs.last_logical_reads as [Last Reads]
    ,qs.total_logical_writes as [Total Writes]
    ,qs.last_logical_writes as [Last Writes]
    ,qs.total_worker_time / 1000 as [Total Worker Time]
	,qs.last_worker_time / 1000 as [Last Worker Time]
    ,qs.total_elapsed_time / 1000 as [Total Elapsed Time]
    ,qs.last_elapsed_time / 1000 as [Last Elapsed Time]
    ,qs.total_rows as [Total Rows]
    ,qs.last_rows as [Last Rows]
    ,qs.total_rows / qs.execution_count as [Avg Rows]
    ,qs.total_physical_reads as [Total Physical Reads]
    ,qs.last_physical_reads as [Last Physical Reads]
    ,qs.total_physical_reads / qs.execution_count as [Avg Physical Reads]
    ,qs.total_grant_kb as [Total Grant KB]
    ,qs.last_grant_kb as [Last Grant KB]
    ,(qs.total_grant_kb / qs.execution_count) as [Avg Grant KB]
    ,qs.total_used_grant_kb as [Total Used Grant KB]
    ,qs.last_used_grant_kb as [Last Used Grant KB]
    ,(qs.total_used_grant_kb / qs.execution_count) as [Avg Used Grant KB]
    ,qs.total_ideal_grant_kb as [Total Ideal Grant KB]
    ,qs.last_ideal_grant_kb as [Last Ideal Grant KB]
    ,(qs.total_ideal_grant_kb / qs.execution_count) as [Avg Ideal Grant KB]
    ,qs.total_columnstore_segment_reads as [Total CSI Segments Read]
    ,qs.last_columnstore_segment_reads as [Last CSI Segments Read]
    ,(qs.total_columnstore_segment_reads / qs.execution_count) as [AVG CSI Segments Read]
    ,qs.max_dop as [Max DOP]
    ,qs.total_spills as [Total Spills]
    ,qs.last_spills as [Last Spills]
    ,(qs.total_spills / qs.execution_count) as [Avg Spills]
FROM sys.dm_exec_query_stats qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY [Avg IO] DESC
OPTION (RECOMPILE, MAXDOP 1);

