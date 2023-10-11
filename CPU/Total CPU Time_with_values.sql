select * 
from (
select 
master.dbo.format(cast(cast([Total CPU Time (ms)] as float) / cast([Nr_of_Executions] as float) as numeric(10,3)),5) avg_CPU_Time,
cast(pct_worker_time as numeric(10,3)) pct_worker_time,
case when sql_text like '%F_OS_TOKEN%' or sql_text like '%F_OS_XML_CACHE%' then NULL else 0 end flag, 
sql_text, 
master.dbo.format([Nr_of_Executions],-1) [Nr_of_Executions], 
master.dbo.format([Total CPU Time (ms)],-1) [Total_CPU_Time_ms], 
master.dbo.format([total_worker_time],-1) [total_worker_time], 
master.dbo.format([Last CPU Time (ms)],-1) [Last_CPU_Time_ms], 
master.dbo.duration('ms',cast([Last CPU Time (ms)] as int)) [Last_CPU_Time], 
[Last Execution], 
replace(explan.bind_variables,'@','') bind_variables, explan.parameter_values
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
qp.query_plan [Query Plan]
FROM sys.dm_exec_query_stats qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) s
cross apply sys.dm_exec_query_plan(qs.plan_handle) qp
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
order by qs.total_worker_time desc)a)b
cross apply master.dbo.fn_executionPlan_params([Query Plan]) explan) xq
pivot (
max(parameter_values) for bind_variables in (
[P0],[P1],[P2],[P3],[P4],[P5],[P6],[P7],[P8],[P9],[P10],
[P11],[P12],[P13],[P14],[P15],[P16],[P17],[P18],[P19],[P20],
[P21],[P22],[P23],[P24],[P25],[P26],[P27],[P28],[P29],[P30],
[P31],[P32],[P33],[P34],[P35],[P36],[P37],[P38],[P39],[P40],
[P41],[P42],[P43],[P44],[P45],[P46],[P47],[P48],[P49],[P50],
[P51],[P52],[P53],[P54],[P55],[P56],[P57],[P58],[P59],[P60],
[P61],[P62],[P63],[P64],[P65],[P66],[P67],[P68],[P69],[P70],
[P71],[P72],[P73],[P74],[P75],[P76],[P77],[P78],[P79],[P80],
[P81],[P82],[P83],[P84],[P85],[P86],[P87],[P88],[P89],[P90],
[P91],[P92],[P93],[P94],[P95],[P96],[P97],[P98],[P99],[P100]

))p --max 100 parameters
order by cast(replace([avg_CPU_Time],',','') as float) desc


