select  distinct
p.session_id, 
case 
--when p.session_id in (select blocked from sys.sysprocesses) then 0
when p.status = 'suspended' and r.blocking_session_id > 0	then 1 
when p.status = 'suspended' and r.blocking_session_id = 0	then 2 
when p.status = 'Runnable'									then 3
when p.status = 'Running'									then 4		
when p.status = 'Sleeping' and p.open_transaction_count = 1	then 9 
when p.status = 'Sleeping' and p.open_transaction_count = 0	then 10 
else 5 end flag_status,p.open_transaction_count,  percent_complete, db_name(p.database_id) [db_name], p.login_name,p.status, r.last_wait_type, r.blocking_session_id,
master.dbo.duration('s',datediff(s,r.start_time,getdate())) duration, r.start_time, r.command,
p.cpu_time,
s.text, substring(s.text,(r.statement_start_offset/2)+1,((r.statement_end_offset/2)-(r.statement_start_offset/2))+2) sql_text,
wait_time, client_net_address, p.host_name, program_name--, cast(pan.query_plan as xml) query_plan 
from sys.dm_exec_sessions p 
left outer join sys.dm_exec_connections c 
on p.session_id = c.session_id
left outer join sys.dm_exec_requests r
on p.session_id = r.session_id
cross apply sys.dm_exec_sql_text(r.sql_handle)s
left outer join (select r.session_id, convert(nvarchar(max),p.query_plan) query_plan from sys.dm_exec_requests r cross apply sys.dm_exec_query_plan(r.plan_handle)p)pan
on r.session_id = pan.session_id
where p.session_id != @@spid
--and s.text like '%LDFBNK_LD_L002%'
order by flag_status, blocking_session_id desc, p.cpu_time desc,  r.last_wait_type
