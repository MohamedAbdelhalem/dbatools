--select s.text, * 
--from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
--on p.session_id = r.session_id
--cross apply sys.dm_exec_sql_text(r.sql_handle)s
--where p.session_id != @@spid
--go
use master
go
select 
session_id, start_time,
physical_operator_name,
actual_read_row_count,
estimated_read_row_count,
[maxdop],
CAST((cast(replace(actual_read_row_count,',','') as float) + .00001) * (100.0 + .00001) / (cast(replace(estimated_read_row_count,',','') as float) + .00001)  AS numeric(10,5)) 
[percent_complete_%], 
master.[dbo].[time_to_complete](cast(replace(actual_read_row_count,',','') as float), cast(replace(estimated_read_row_count,',','') as float), start_time) time_to_complete
from (
select 
p.session_id,
physical_operator_name + ' (maxdop='+CAST(COUNT(thread_id) AS VARCHAR(4)) +')' AS physical_operator_name,
COUNT(thread_id)  [maxdop],
master.dbo.Format(isnull(sum(p.row_count),'0'),-1) row_count,
master.dbo.Format(isnull(sum(actual_read_row_count),'0'),-1) actual_read_row_count,
master.dbo.Format(sum(estimate_row_count),-1) estimated_read_row_count, r.start_time
from sys.dm_exec_query_profiles p left outer join sys.dm_exec_requests r
on p.session_id = r.session_id
group by p.session_id, physical_operator_name, r.start_time)a
where session_id = 80
and (physical_operator_name like 'Clustered Index Scan%' 
or physical_operator_name like 'Clustered Index Insert%'
or physical_operator_name like 'Index Seek%'
or physical_operator_name like 'Index Insert%'
or physical_operator_name like 'Table Scan%'
or physical_operator_name like 'Index Scan%'
)

go
select r.session_id, count(*), 
physical_operator_name, 
master.dbo.format(sum(p.row_count), -1) row_count, 
master.dbo.format(sum(estimate_row_count), -1) estimate_row_count, sum(estimate_row_count) xx,
cast(cast(sum(p.row_count) as float)/cast(sum(estimate_row_count) as float) * 100.0 as numeric(10,2)) PCT,
master.[dbo].[time_to_complete](cast(sum(p.row_count) as float), cast(sum(estimate_row_count) as float), start_time) time_to_complete,
master.[dbo].[duration]('s', datediff(s, r.start_time, getdate())) duration
from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
on p.session_id = r.session_id
where r.session_id != @@SPID
and physical_operator_name in ('Clustered Index Scan','Clustered Index Update','Compute Scalar')
group by r.session_id,physical_operator_name, r.start_time
order by session_id, xx
--set statistics profile off
dbcc tracestatus

--847,689,000


--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 
--WITH XMLNAMESPACES   
--(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')  
--SELECT  
--     query_plan AS CompleteQueryPlan, 
--     n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText, 
--     n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel, 
--     n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost, 
--     n.query('.') AS ParallelSubTreeXML,  
--     ecp.usecounts, 
--     ecp.size_in_bytes 
--FROM sys.dm_exec_cached_plans AS ecp 
--CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp 
--CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
--WHERE  n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1 