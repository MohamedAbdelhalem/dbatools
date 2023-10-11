select 
row_number() over(order by cast(cast([Total CPU Time (ms)] as float) / cast([Nr of Executions] as float) as numeric(10,3)) desc) [#], 
master.dbo.format(cast(cast([Total CPU Time (ms)] as float) / cast([Nr of Executions] as float) as numeric(10,3)),5) avg_CPU_Time,
cast(pct_worker_time as numeric(10,3)) pct_worker_time, 
case when sql_text like '%F_OS_TOKEN%' or sql_text like '%F_OS_XML_CACHE%' then NULL else 0 end flag, sql_text, 
master.dbo.format([Nr of Executions],-1) [Nr of Executions], 
master.dbo.format([Total CPU Time (ms)],-1) [Total CPU Time (ms)], 
master.dbo.format([total_worker_time],-1) [total_worker_time], 
master.dbo.format([Last CPU Time (ms)],-1) [Last CPU Time (ms)], 
--plan_size,
--last_rows,
--last_logical_reads,
--total_rows,
--last_dop,
[Last Execution], [Query Plan]
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
select top 20
s.text as sql_text,
--master.dbo.numbersize(cp.size_in_bytes,'b') plan_size,
qs.execution_count  [Nr of Executions],
qs.total_worker_time/1000.0 [Total CPU Time (ms)],
total_worker_time, 
qs.last_worker_time/1000.0 [Last CPU Time (ms)],
qs.last_execution_time [Last Execution],
--qs.last_rows,
--qs.last_logical_reads,
--qs.total_rows,
--qs.last_dop,
qp.query_plan [Query Plan]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
--inner join sys.dm_exec_cached_plans cp
--on qs.plan_handle = cp.plan_handle
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
--and s.text like '%F_RECORD_LOCK%'
order by qs.total_worker_time desc)a)b
order by [#]

