select physical_operator_name, p.session_id,
CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS DECIMAL(10,2)) 
[percent_complete_%],
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
) time_to_complete
from sys.dm_exec_query_profiles p
inner join sys.dm_exec_requests r
on p.session_id = r.session_id
where p.session_id = 55
--where physical_operator_name = 'Clustered Index Scan'
GROUP BY p.node_id, p.session_id, r.start_time, p.physical_operator_name

select master.dbo.format(sum(actual_read_row_count),-1), master.dbo.format(sum(estimate_row_count),-1),
cast(cast(isnull(sum(actual_read_row_count),0) as float)/cast(sum(estimate_row_count) as float) * 100.0 as numeric(10,2)) pct, 
master.[dbo].[time_to_complete](cast(sum(p.actual_read_row_count) as float), cast(sum(estimate_row_count) as float), start_time) time_to_complete,
physical_operator_name
from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
on p.session_id = r.session_id
where p.session_id = 55
group by physical_operator_name, r.start_time
having sum(estimate_row_count) > 0

