select --case when hostname in (
master.dbo.duration('s',case when datediff(s,last_batch,getdate()) < 0 then 0 else datediff(s,last_batch,getdate()) end) duration ,last_batch,
* 
from (
select  
spid,open_tran,
case 
when spid   in (select blocked from sys.sysprocesses) then 0
when status = 'suspended' and blocked > 0 then 1 
when status = 'suspended' and blocked = 0 then 2 
when status = 'Runnable' then 3
when status = 'Running'	 then 4		
when status = '
' and open_tran > 0 then 9 
when status = 'Sleeping' then 10 
else 5 end flag_status,
percent_complete, [db_name], loginame, status, command, cpu, lastwaittype, blocked, last_batch,
--backup_date, backup_time, 
duration, start_time, text, sql_text, waittime, client_net_address, hostname, program_name, convert(xml,query_plan) query_plan
from (
select distinct spid, p.open_tran,  percent_complete, db_name(p.dbid) [db_name], loginame,p.status, lastwaittype,r.start_time,
r.command,last_batch,
--master.dbo.date_yyyymmddhhmiss(
convert(varchar(10), convert(datetime, left(case 
when r.command like 'restore%' then 
substring(reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)), 1, charindex('.',reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)))-1) end, 8), 111), 120)
backup_date, 
right(case 
when r.command like 'restore%' then 
substring(reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)), 1, charindex('.',reverse(substring(reverse(s.text), 1, charindex('_',reverse(s.text))-1)))-1) end, 6) 
backup_time, cpu,
master.dbo.duration('s',datediff(s,r.start_time,getdate())) duration,
s.text, substring(s.text,(p.stmt_start/2)+1,((p.stmt_end/2)-(p.stmt_start/2))+2) sql_text,-- sp.id,  --sp.value code, 
waittime, blocked, client_net_address, hostname, program_name, 
pan.*
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
inner join sys.dm_exec_connections c 
on p.spid = c.session_id
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
left outer join (select r.session_id, convert(nvarchar(max),p.query_plan) query_plan from sys.dm_exec_requests r cross apply sys.dm_exec_query_plan(r.plan_handle)p)pan
on r.session_id = pan.session_id
where p.spid != @@spid
)a)v
where spid = 1942 --(select spid from sys.sysprocesses where status = 'sleeping' and spid > 50)
and db_name = 'T24prod'
and loginame= 't24prod'
and datediff(s,last_batch,getdate()) >= (5 * 60)
order by v.last_batch 


select spid, open_tran, last_batch , master.dbo.duration('s',datediff(s,last_batch,getdate())) 
from sys.sysprocesses
where status = 'sleeping'
and spid = 1942
order by datediff(s,last_batch,getdate()) desc
