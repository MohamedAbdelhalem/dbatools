use master
go
declare @spid int = 212
select sp.value current_sql_text
from sys.sysprocesses p 
cross apply sys.dm_exec_sql_text(p.sql_handle)s
cross apply master.dbo.Separator(substring(s.text, p.stmt_start/2+1, (p.stmt_end/2+1) - (p.stmt_start/2+1) + 1), char(10))sp
where spid = @spid
order by sp.id

--dbcc traceon (7412,-1)

select session_id, maxdop_n, physical_operator_name, row_count, estimate_row_count, /*xx,*/ PCT, time_to_complete, master.dbo.duration('s',datediff(s,start_time,getdate())) duration
--, command, sub_command, table_name, column_name, fn_name, index_name
from (
select r.session_id, count(*) maxdop_n, 
physical_operator_name, r.sql_handle,r.statement_start_offset,r.statement_end_offset,start_time,
master.dbo.format(sum(p.row_count) / (count(*) + .00001), -1) row_count, 
master.dbo.format(sum(estimate_row_count) / (count(*) + 0.00001), -1) estimate_row_count, 
sum(estimate_row_count) / (count(*) + .00001) xx,
cast(cast(sum(p.row_count) / (count(*) + .00001) as float)/cast((sum(estimate_row_count) / (count(*) + .00001)) as float) * 100.0 as numeric(10,2)) PCT,
master.[dbo].[time_to_complete](cast(sum(p.row_count) as float), cast(sum(estimate_row_count) as float), start_time) time_to_complete
from sys.dm_exec_query_profiles p inner join sys.dm_exec_requests r
on p.session_id = r.session_id
where r.session_id = @spid
and physical_operator_name in ('Table Scan','Clustered Index Seek','Clustered Index Scan','Index Scan','Clustered Index Update','Compute Scalar','Sort','Index Insert')
group by r.session_id,physical_operator_name, r.start_time, r.sql_handle,r.statement_start_offset,r.statement_end_offset,start_time)a
--cross apply @InputBuffer ib
--cross apply master.[dbo].[text_analysis] (ib.text) ta
cross apply sys.dm_exec_sql_text(sql_handle) s
--cross apply master.[dbo].[text_analysis] (substring(s.text, statement_start_offset/2+1,statement_end_offset/2+1)) ta
order by session_id, xx


--exec master.dbo.database_size @with_system=1,@databases='tempdb',@datafile='data'
--exec master.dbo.database_size @report=3,@volumes='I,D'


--select * from sys.dm_exec_query_profiles
