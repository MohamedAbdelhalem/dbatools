--%Clustered Index Scan state
select qp.session_id, physical_operator_name +' ('+cast(count(*) as varchar(10))+')' physical_operator_name,
master.dbo.format(max(actual_read_row_count),-1) actual_read_row_count, 
master.dbo.format(max(estimate_row_count),-1) actual_read_row_count,
CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS DECIMAL(5,2)) 
[percent complete %],
master.dbo.duration('s',
case when CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) [time to complete]
from sys.dm_exec_query_profiles qp inner join sys.dm_exec_requests r 
on qp.session_id = r.session_id 
--where qp.session_id = 74
and physical_operator_name like '%Clustered Index Scan%'
group by qp.session_id, physical_operator_name, r.start_time
