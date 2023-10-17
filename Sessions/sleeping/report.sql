select spid, status, cmd, s.text sql_text, master.dbo.duration('s',(datediff(s,last_batch,getdate()))) duration,hostname,datediff(s,last_batch,getdate()) sec,
'KILL '+CAST(spid as varchar(20))
from sys.sysprocesses  p cross apply sys.dm_exec_sql_text(p.sql_handle)s
where status = 'sleeping' 
and spid > 50
and db_name(p.dbid) = 'T24prod'
and loginame= 't24prod'
and datediff(s,last_batch,getdate()) >= (60 * 60)
order by sec desc

--t24prod.dbo.sp_table_size '','F_os_token'

--kill 3275
