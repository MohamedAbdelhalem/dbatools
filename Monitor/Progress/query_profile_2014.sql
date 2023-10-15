--dbcc traceon (7412,-1)
--dbcc tracestatus
--dbcc traceoff(7412,-1)
-- or capturing the query_thread_profile extended event
go
--SET STATISTICS PROFILE Off
select 
session_id,
physical_operator_name,
master.dbo.duration('s',datediff(s,start_time, getdate())) duration,
actual_read_row_count,
estimated_read_row_count,
[maxdop],
CAST(cast(replace(actual_read_row_count,',','') as float) * 100.0 / (isnull(cast(replace(estimated_read_row_count,',','') as float), .00001) + .00001)  AS DECIMAL(5,2)) 
[percent_complete_%],
time_to_complete
from (
select 
p.session_id,
physical_operator_name + ' (maxdop='+CAST(COUNT(thread_id) AS VARCHAR(4)) +')' AS physical_operator_name,
r.start_time,
COUNT(thread_id)  [maxdop],
master.dbo.Format(isnull(sum(actual_read_row_count),'0'),-1) actual_read_row_count,
master.dbo.Format(sum(estimate_row_count),-1) estimated_read_row_count,
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
from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
on p.session_id = r.session_id
where	physical_operator_name like 'Index Scan%'
or		physical_operator_name like 'Table Scan%'
or		physical_operator_name like 'Clustered Index Seek%'
or		physical_operator_name like 'Clustered Index Scan%'
group by p.session_id, physical_operator_name, r.start_time
)a

--115,313,000
go
--select 
--p.session_id, --node_id, --physical_operator_name,
------o.name [object_name],
------i.name index_name,
--physical_operator_name + ' (maxdop='+CAST(COUNT(thread_id) AS VARCHAR(4)) +')' AS physical_operator_name,
------master.dbo.Format(sum(p.row_count),-1) row_count, 
------master.dbo.Format(sum(estimate_row_count),-1) estimate_row_count,
--master.dbo.Format(sum(p.actual_read_row_count),-1) actual_read_row_count,
--master.dbo.Format(sum(p.estimate_row_count),-1) estimated_read_row_count,
--COUNT(thread_id)  [maxdop],
--CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),'0')  AS DECIMAL(5,2)) 

--[percent_complete_%]--,
--master.dbo.duration('s',
--case when CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
--cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--< 0 then 0 else
--cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--end end
--) time_to_complete,
--master.dbo.duration('s', datediff(s, r.start_time, getdate())) duration_start_time, 
--cast((cast(sum(p.row_count) as float)/sum(estimate_row_count)/count(*)) * 100 as decimal(5,2)) percent_complete_Index,
--master.dbo.duration('ms',
--case when CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
--cast((100.0 / (round(CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--< 0 then 0 else
--cast((100.0 / (round(CAST(isnull(sum((p.row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--end end
--) 
--time_to_complete_Index,
--master.dbo.duration('s', (sum(last_row_time)-sum(first_row_time))/1000) duration
----master.dbo.duration('s', sum(cpu_time_ms)/1000) cpu_time,
--CAST(SUM(elapsed_time_ms) * 100. /(SUM(SUM(elapsed_time_ms)) OVER() + .00001) AS DECIMAL(5,2)) [total_elapsed_time_%],
--CAST(SUM(cpu_time_ms) * 100. /(SUM(SUM(cpu_time_ms)) OVER() + .00001) AS DECIMAL(5,2)) [total_cpu_%],
----p.parallel,
--CAST((sum(logical_read_count)		* 100. / (sum(sum(logical_read_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_logical_read_%],
--CAST((sum(physical_read_count)		* 100. / (sum(sum(physical_read_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_physical_read_%],
--CAST((sum(lob_logical_read_count)	* 100. / (sum(sum(lob_logical_read_count))	OVER() + .00001)) AS DECIMAL(5,2)) [lob_logical_read_%],
--CAST((sum(lob_physical_read_count)	* 100. / (sum(sum(lob_physical_read_count))	OVER() + .00001)) AS DECIMAL(5,2)) [lob_physical_read_%],
--CAST((sum(write_page_count)			* 100. / (sum(sum(write_page_count))		OVER() + .00001)) AS DECIMAL(5,2)) [total_write_%]
--from sys.dm_exec_query_profiles p
--inner join sys.dm_exec_requests r
--on p.session_id = r.session_id
--cross apply sys.dm_exec_sql_text(r.sql_handle)s
----left join sys.objects o
----on o.object_id = p.object_id
--left join sys.indexes i
--on i.object_id = p.object_id
--and i.index_id = p.index_id
----where (p.session_id = 109 and physical_operator_name like '%%')
----or (p.session_id = 107 and physical_operator_name like '%%')
--GROUP BY p.node_id, p.session_id, p.physical_operator_name, --o.name, i.name, 
--r.start_time
--order by p.session_id

--select * from sys.system_internals_allocation_units

--select * from sys.dm_exec_query_profiles
--select * from 
----Clustered Index Scan (maxdop=1)
--select qp.session_id, physical_operator_name +' ('+cast(count(*) as varchar(10))+')' physical_operator_name,
--master.dbo.format(max(actual_read_row_count),-1) actual_read_row_count, 
--master.dbo.format(max(estimate_row_count),-1) actual_read_row_count,
--CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS DECIMAL(5,2)) 
--[percent_complete_%],
--master.dbo.duration('s',
--case when CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float) = 0 then 0 else case when 
--cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--< 0 then 0 else
--cast((100.0 / (round(CAST(isnull(sum((actual_read_row_count * 100.0) / (estimate_row_count+ .00001)),0)  AS float),5) + .00001)) 
--* 
--datediff(s, r.start_time, getdate()) as int)
---
--datediff(s, r.start_time, getdate())
--end end
--) time_to_complete
--from sys.dm_exec_query_profiles qp inner join sys.dm_exec_requests r 
--on qp.session_id = r.session_id 
--where qp.session_id = 396
--and physical_operator_name like 'Clustered Index Scan%'
--group by physical_operator_name, r.start_time
----
--declare @operation varchar(20) = 'index'
--select session_id, last_wait_type, 
--cast(((cast(
--(select count(*) from dbo.Separator(s.text, @operation)) -
--(select count(*) from dbo.Separator(substring(s.text,r.statement_start_offset/2+1,r.statement_start_offset/2+1) ,@operation)) as float) - 1 / 
--(select count(*) from dbo.Separator(s.text, @operation))) * 100.00) as decimal(5,2)) percent_complete,
--a.*
--from sys.dm_exec_requests r 
--cross apply sys.dm_exec_sql_text(r.sql_handle)s
--cross apply master.dbo.text_analysis(substring(s.text, r.statement_start_offset/2+1, r.statement_end_offset/2+1)) a
--where session_id in (107,109)


----select * from master.dbo.text_analysis('ALTER TABLE dbo.F_BAB_H_WU_RECON_TXNS ADD WU_SETTLE_DATE AS dbo.F_BAB_H_WU_RECON_TXNS_c11 (XMLRECORD) PERSISTED; ')
