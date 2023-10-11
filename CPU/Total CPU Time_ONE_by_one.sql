select s.*
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
SELECT TOP 20
 s.TEXT AS 'Query',
 qs.execution_count AS 'Nr of Executions',
 qs.total_worker_time/1000 AS 'Total CPU Time (ms)',
 total_worker_time, 
 qs.last_worker_time/1000 AS 'Last CPU Time (ms)',
 qs.last_execution_time AS 'Last Execution',
 qp.query_plan AS 'Query Plan'
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
ORDER BY qs.total_worker_time DESC)a)b
cross apply master.dbo.Separator(b.query,CHAR(10))s
where b.id = 1
order by s.id

select s.*
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
SELECT TOP 20
 s.TEXT AS 'Query',
 qs.execution_count AS 'Nr of Executions',
 qs.total_worker_time/1000 AS 'Total CPU Time (ms)',
 total_worker_time, 
 qs.last_worker_time/1000 AS 'Last CPU Time (ms)',
 qs.last_execution_time AS 'Last Execution',
 qp.query_plan AS 'Query Plan'
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
ORDER BY qs.total_worker_time DESC)a)b
cross apply master.dbo.Separator(b.query,CHAR(10))s
where b.id = 2
order by s.id

select s.*
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
SELECT TOP 20
 s.TEXT AS 'Query',
 qs.execution_count AS 'Nr of Executions',
 qs.total_worker_time/1000 AS 'Total CPU Time (ms)',
 total_worker_time, 
 qs.last_worker_time/1000 AS 'Last CPU Time (ms)',
 qs.last_execution_time AS 'Last Execution',
 qp.query_plan AS 'Query Plan'
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
ORDER BY qs.total_worker_time DESC)a)b
cross apply master.dbo.Separator(b.query,CHAR(10))s
where b.id = 3
order by s.id
