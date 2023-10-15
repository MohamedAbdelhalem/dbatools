use master
go
declare @spid int = 70
select sp.value current_sql_text
from sys.sysprocesses p 
cross apply sys.dm_exec_sql_text(p.sql_handle) s
cross apply master.dbo.Separator(substring(s.text, p.stmt_start/2+1, (p.stmt_end/2+1) - (p.stmt_start/2+1)), char(10)) sp
where spid = @spid
order by sp.id

select session_id, maxdop_n, physical_operator_name, row_count, estimate_row_count,PCT, time_to_complete, 
master.dbo.duration('s',datediff(s,start_time,getdate())) duration
from (
select r.session_id, count(*) maxdop_n, 
physical_operator_name, r.sql_handle,r.statement_start_offset,r.statement_end_offset,ss.start_time,
master.dbo.format(sum(p.row_count) / (count(*) + .00001), -1) row_count, 
master.dbo.format(sum(estimate_row_count) / (count(*) + 0.00001), -1) estimate_row_count, 
sum(estimate_row_count) / (count(*) + .00001) xx,
cast(cast(sum(p.row_count) / (count(*) + .00001) as float)/cast((sum(estimate_row_count) / (count(*) + .00001)) as float) * 100.0 as numeric(10,2)) PCT,
master.[dbo].[time_to_complete](cast(sum(p.row_count) as float), cast(sum(estimate_row_count) as float), ss.start_time) time_to_complete
from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
on p.session_id = r.session_id
cross apply master.dbo.start_step ss
where r.session_id != @@SPID
and physical_operator_name in ('Table Scan','Clustered Index Scan','Clustered Index Update','Compute Scalar','Sort','Index Insert')
group by r.session_id,physical_operator_name, r.sql_handle,r.statement_start_offset,r.statement_end_offset,ss.start_time)a
cross apply sys.dm_exec_sql_text(sql_handle) s
order by session_id, xx

select *, master.dbo.duration('s',sum(datediff(s,start_time,isnull(end_time,getdate()))) over()) overall_time_to_complete 
from (
select row_number() over(order by id) id, table_name, index_name, start_time, end_time, creation_time
from (
select id, master.dbo.vertical_array(obj_name,' ',3) table_name,master.dbo.vertical_array(obj_name,' ',1) index_name,  
start_time, end_time, master.dbo.duration('s',datediff(s,start_time,isnull(end_time,getdate()))) creation_time
from master.dbo.log_duration
where start_time > convert(varchar(10),getdate(),120))a)b
where id between 1 and 19
--where id > 19
--where id > 22
order by id
