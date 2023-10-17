select  distinct
p.spid, 
case 
--when p.spid in (select blocked from sys.sysprocesses) then 0
when p.status = 'suspended' and r.blocking_session_id > 0	then 1 
when p.status = 'suspended' and r.blocking_session_id = 0	then 2 
when p.status = 'Runnable'									then 3
when p.status = 'Running'									then 4		
when p.status = 'Sleeping' and p.open_tran = 1	then 9 
when p.status = 'Sleeping' and p.open_tran = 0	then 10 
else 5 end flag_status,p.open_tran,  percent_complete, db_name(p.dbid) [db_name], p.loginame,p.status, r.last_wait_type, r.blocking_session_id,
--datediff(s,r.start_time,getdate()) duration, 
master.dbo.duration('s',datediff(s,r.start_time,getdate())) duration, 
r.start_time, r.command,
p.cpu,--ex.*,
s.text, substring(s.text,(r.statement_start_offset/2)+1,((r.statement_end_offset/2)-(r.statement_start_offset/2))+2) sql_text,
datediff(s,r.start_time,getdate()) duration_sec,
wait_time, client_net_address, p.hostname, program_name--, cast(pan.query_plan as xml) query_plan 
from sys.sysprocesses p 
left outer join sys.dm_exec_connections c 
on p.spid = c.session_id
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
cross apply sys.dm_exec_sql_text(r.sql_handle)s
left outer join (select r.session_id, convert(nvarchar(max),p.query_plan) query_plan from sys.dm_exec_requests r cross apply sys.dm_exec_query_plan(r.plan_handle)p)pan
on r.session_id = pan.session_id
--left outer join (select blocked from sys.sysprocesses) bl
--on r.session_id = bl.blocked
--cross apply master.dbo.fn_executionPlan_Pvalues(r.session_id) ex
--where p.spid != @@spid
and loginame not in ('ALBILAD\svc_sqlT24','NT AUTHORITY\SYSTEM','ALBILAD\SVC_sqlagent')
--and hostname in ('D2T24APUXPWV1') 
--and datediff(s,r.start_time,getdate()) > 4
--and hostname = 'D1T24APUXPWV3'
--and p.spid in (626)
--and text like '%API%'
--and p.status = 'sleeping'
--order by duration_sec desc
order by flag_status, blocking_session_id, p.cpu desc,  r.last_wait_type


--(@P0 nvarchar(4000))SELECT RECID FROM "JV_FBNK_LIMIT" WHERE RECID IN ( SELECT LTRIM(RTRIM(REPLACE(value, CHAR(13) + CHAR(10), ''))) FROM STRING_SPLIT('10001641.0020000.01, 10001641.0020000.01.10001641, 10001641.0020000.01.10063311, 10001641.0028500.01, 10001641.0028500.01.10001641, 10001641.0028500.01.10063311, 10001641.0028509.01, 10001641.0028509.01.10001641, 10001641.0028509.01.10063311, 10001641.0028511.01, 10001641.0028511.01.10001641, 10001641.0028700.01, 10001641.0028700.01.10001641, 10001641.0028702.01, 10001641.0028702.01.10001641, 10001641.0028704.01, 10001641.0028704.01.10001641, 10001641.0028706.01, 10001641.0028706.01.10001641', ',')) and ("TARGET" <  CONVERT( FLOAT, @P0) OR ("TARGET" IS NULL OR "TARGET" = '')) ORDER BY RECID        

--select s.*
--from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,CHAR(10))s
--where object_id = object_id('JV_FBNK_LIMIT')
--and s.value like '%"TARGET"%'
--order by s.id

--select t.request_session_id,* from sys.dm_tran_locks t
--order by t.request_session_id

--master.dbo.database_size @with_system=1,@databases='tempdb',@datafile='data'
