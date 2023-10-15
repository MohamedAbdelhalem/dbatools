--dbcc traceon (7412,-1)
--dbcc tracestatus
--dbcc traceoff(7412,-1)
-- or capturing the query_thread_profile extended event
go
--SET STATISTICS PROFILE ON
go
select 
p.session_id, --node_id, --physical_operator_name,
--o.name [object_name],
--i.name index_name,
physical_operator_name + ' (maxdop='+CAST(COUNT(thread_id) AS VARCHAR(4)) +')' AS physical_operator_name,
--master.dbo.Format(sum(p.row_count),-1) row_count, 
--master.dbo.Format(sum(estimate_row_count),-1) estimate_row_count,
master.dbo.Format(sum(p.actual_read_row_count),-1) actual_read_row_count,
master.dbo.Format(sum(p.estimated_read_row_count),-1) estimated_read_row_count,
COUNT(thread_id)  [maxdop],
CAST(isnull(sum((actual_read_row_count * 100.0) / (estimated_read_row_count+ .00001)),0)  AS DECIMAL(5,2)) [percent_complete_%],
master.dbo.duration('s',
case when CAST(isnull(sum((actual_read_row_count * 100.0) / (estimated_read_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimated_read_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimated_read_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) time_to_complete,
master.dbo.duration('s', datediff(s, r.start_time, getdate())) duration_start_time, 
cast((cast(sum(p.row_count) as float)/sum(estimate_row_count)/count(*)) * 100 as decimal(5,2)) percent_complete_Index,
master.dbo.duration('ms',
case when CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
cast((100.0 / (round(CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) 
time_to_complete_Index,

master.dbo.duration('s', (sum(last_row_time)-sum(first_row_time))/1000) duration, 
--master.dbo.duration('s', sum(cpu_time_ms)/1000) cpu_time,
CAST(SUM(elapsed_time_ms) * 100. /(SUM(SUM(elapsed_time_ms)) OVER() + .00001) AS DECIMAL(5,2)) [total_elapsed_time_%],
CAST(SUM(cpu_time_ms) * 100. /(SUM(SUM(cpu_time_ms)) OVER() + .00001) AS DECIMAL(5,2)) [total_cpu_%],
--p.parallel,
CAST((sum(logical_read_count)		* 100. / (sum(sum(logical_read_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_logical_read_%],
CAST((sum(physical_read_count)		* 100. / (sum(sum(physical_read_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_physical_read_%],
CAST((sum(lob_logical_read_count)	* 100. / (sum(sum(lob_logical_read_count))	OVER() + .00001)) AS DECIMAL(5,2)) [lob_logical_read_%],
CAST((sum(lob_physical_read_count)	* 100. / (sum(sum(lob_physical_read_count))	OVER() + .00001)) AS DECIMAL(5,2)) [lob_physical_read_%],
CAST((sum(write_page_count)			* 100. / (sum(sum(write_page_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_write_%]
from sys.dm_exec_query_profiles p
inner join sys.dm_exec_requests r
on p.session_id = r.session_id
cross apply sys.dm_exec_sql_text(r.sql_handle)s
left join sys.objects o
on o.object_id = p.object_id
left join sys.indexes i
on i.object_id = p.object_id
and i.index_id = p.index_id
where p.session_id = 110
GROUP BY p.node_id, p.session_id, p.physical_operator_name, o.name, i.name, r.start_time
order by node_id

--select * from sys.dm_exec_query_profiles where session_id = 146

----
--declare @operation varchar(20) = 'table'
--select session_id, last_wait_type, 
--cast(((cast(
--(select count(*) from dbo.Separator(s.text, @operation)) -
--(select count(*) from dbo.Separator(substring(s.text,r.statement_start_offset/2+1,r.statement_start_offset/2+1) ,@operation)) as float) - 1 / 
--(select count(*) from dbo.Separator(s.text, @operation))) * 100.00) as decimal(5,2)) percent_complete,
--a.*
--from sys.dm_exec_requests r 
--cross apply sys.dm_exec_sql_text(r.sql_handle)s
--cross apply master.dbo.text_analysis(substring(s.text, r.statement_start_offset/2, r.statement_end_offset/2+1)) a
--where session_id = 146


