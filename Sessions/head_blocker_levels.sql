;with recusive_sessions (spid, blocking_session_id, level)
as
(
select spid, blocking_session_id, 0 level
from (
select spid, case when spid in (select blocked from sys.sysprocesses) and blocked = 0 then NULL else blocked end blocking_session_id
from sys.sysprocesses)a
where blocking_session_id is null
union all
select sp.spid, sp.blocked, level + 1
from recusive_sessions rs inner join sys.sysprocesses sp
on rs.spid = sp.blocked
)
select isnull(rs.level,10000) level, p.spid, 
case 
when p.status = 'suspended' and blocked > 0  then 1 
when p.status = 'suspended' and blocked = 0  then 2 
when p.status = 'Runnable'					 then 3
when p.status = 'Running'					 then 4		
when p.status = 'Sleeping' and open_tran = 1 then 5 
when p.status = 'Sleeping' and open_tran = 0 then 6 
else 5 end flag_status, percent_complete, DB_NAME(p.dbid), loginame, CPU,p.status,
blocked, waittime, lastwaittype, hostname, client_net_address, cmd, master.dbo.duration('s', datediff(s,start_time,getdate())) duration,
s.text, 
SUBSTRING(s.text, (stmt_start/2)+1, ((stmt_end/2)+1) - ((stmt_start/2)+1) + 1)
--, program_name
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
inner join sys.dm_exec_connections c
on p.spid = c.session_id
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
--left outer join sys.dm_tran_locks tl
--on p.spid = tl.request_session_id
left outer join recusive_sessions rs 
on p.spid = rs.spid
where lastwaittype not in ('SP_SERVER_DIAGNOSTICS_SLEEP')
and loginame not in ('ALBILAD\SVC_SQLMonitor','ALBILAD\gMSA_SS_T24_19$')
and p.spid != @@SPID
--and text Like '%LOCK%'
order by level, flag_status, CPU desc, datediff(s,start_time,getdate()) desc, p.spid
