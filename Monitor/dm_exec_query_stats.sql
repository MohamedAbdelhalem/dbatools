select s.text, substring(s.text, statement_start_offset/2+1, statement_end_offset/2+1) current_text, sp.value, qs.* 
from sys.dm_exec_query_stats qs 
cross apply sys.dm_exec_sql_text(qs.sql_handle)s
cross apply master.dbo.Separator(s.text, char(10))sp
where s.text like '%truncate%'
and creation_time > '2022-07-03'
order by qs.sql_handle, sp.id, creation_time
