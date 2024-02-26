select *
from (
select 
master.dbo.format(cast(cast([Total CPU Time (ms)] as float) / cast([Nr_of_Executions] as float) as numeric(10,3)),5) avg_CPU_Time,
cast(pct_worker_time as numeric(10,3)) pct_worker_time,
sql_text, 
master.dbo.format([Nr_of_Executions],-1) [Nr_of_Executions], 
master.dbo.format([Total CPU Time (ms)],-1) [Total_CPU_Time_ms], 
master.dbo.format([total_worker_time],-1) [total_worker_time], 
master.dbo.format([Last CPU Time (ms)],-1) [Last_CPU_Time_ms], 
master.dbo.duration('ms',cast([Last CPU Time (ms)] as int)) [Last_CPU_Time], 
[Last Execution], cast(query_plan as XML) query_plan,
ex.[1],ex.[2],ex.[3],ex.[4],ex.[5],ex.[6],ex.[7],ex.[8],ex.[9],ex.[10]
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
select top 30
s.text as sql_text,
qs.execution_count  [Nr_of_Executions],
qs.total_worker_time/1000.0 [Total CPU Time (ms)],
total_worker_time, 
qs.last_worker_time/1000.0 [Last CPU Time (ms)],
qs.last_execution_time [Last Execution],
qs.plan_handle
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) s
order by qs.total_worker_time desc)a)b
left outer join (
select *
from (
select ex.id,
qs.plan_handle,cast(qp.query_plan as nvarchar(max)) query_plan,
ex.bind_variables+' = '+ex.parameter_values parameter_values
--, ex.bind_variables+' = '+isnull(ParameterRuntimeValue,'NULL') ParameterRuntimeValue 
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_query_plan(qs.plan_handle) qp
cross apply master.dbo.fn_executionPlan_params(qp.query_plan) ex)e
pivot (
max(parameter_values) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10]))p)ex --max 10 parameters
on b.plan_handle = ex.plan_handle)aa
order by cast(replace([avg_CPU_Time],',','') as float) desc

