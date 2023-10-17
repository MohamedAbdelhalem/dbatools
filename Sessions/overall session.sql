select * from (
select --s.*, 
--ltrim(rtrim(master.dbo.vertical_array(s.value,'.',3))), ltrim(rtrim(master.dbo.vertical_array(sql_text,'.',3))),
spid,open_tran,
case 
--when spid   in (select blocked from sys.sysprocesses) then 0
--when status = 'suspended' and blocked > 0 then 1 
--when status = 'suspended' and blocked = 0 then 2 
when status = 'Runnable' then 3
when status = 'Running'	 then 4		
when status = 'Sleeping' and open_tran = 1 then 9 
when status = 'Sleeping' then 10 
else 5 end flag_status,
percent_complete, [db_name], loginame, status, command, cpu, lastwaittype, blocked, 
backup_date, backup_time, 
duration, start_time, text, sql_text, waittime, client_net_address, hostname, program_name, convert(xml,query_plan) query_plan
from (
select distinct spid, p.open_tran,  percent_complete, db_name(p.dbid) [db_name], loginame,p.status, lastwaittype,r.start_time,
r.command,
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

--and loginame like 'c902990%'

--and text not like '%sp_server_diagnostics%'
)a
where [db_name] not in ('msdb')
--and loginame not in ('ALBILAD\WinMengine','ALBILAD\SVC_SQLMonitor')
--and text not like '%FBNK_BAB_VISA_CRD_ISSUE%'
--and text like '%F_OS_TOKEN%'
--and hostname in ('D1T24APDWPWV1', 'D2T24APUXPWV1')
--cross apply master.dbo.Separator(a.text, char(10))s
--cross apply master.dbo.Separator(a.sql_text, char(10))s
--and status != 'sleeping'
--and spid in (196)
--where db_name = 'BAB_MIS_Archive'
)v
--where spid in (180,147,52)
where text Like '%FBNK_BAB_VISA_CRD_ISSUE%'
--where loginame = 'T24Login'                        
--where sql_text like '%V_REFBNK_RE_C014%'
--where spid = 212
order by --s.id,
flag_status,blocked, CPU desc, sql_text,db_name,spid
--kill 196
--kill 1751
--kill 1724
--select * from sys.sysprocesses where spid = 42
--kill 351
--kill 2351
--kill 1887
--kill 1383
--kill 1988

--KILL 313
--KILL 286
--KILL 314
--KILL 315
--KILL 318
--KILL 287
--KILL 288

--SELECT * FROM sys.sysprocesses WHERE spid in (select blocked from sys.sysprocesses where blocked > 0) order by blocked
--SELECT master.dbo.duration('s',DATEDIFF(S,last_batch,GETDATE())) duration, spid, status 
--FROM sys.sysprocesses WHERE spid in (select blocked from sys.sysprocesses where blocked > 0) and open_tran = 1 order by status, DATEDIFF(S,last_batch,GETDATE()) desc 
--db
--select * from sys.
--sp_table_size '','F_OS_TOKEN'
--select * from F_OS_TOKEN
--select * FROM sys.sysprocesses WHERE blocked in (
--SELECT spid, blocked, lastwaittype, open_tran, status, hostname, s.text 
--FROM sys.sysprocesses p
--cross apply sys.dm_exec_sql_text(p.sql_handle)s
--WHERE status = 'sleeping' 
--and open_tran = 1


--'\\10.35.5.204\t24_backup_2023\Logs\2023\August
--select distinct hostname from sys.sysprocesses where status !='sleeping'

--select spid, db_name(p.dbid), s.text, loginame, waittime, lastwaittype, blocked, status, cmd,
--case status 
--when 'suspended' then 0 
--when 'Runnable'  then 1 
--when 'Running'	 then 2 
--when 'Sleeping'  then 5 
--else 4 end flag_status
--from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
--where p.spid != @@spid
--order by flag_status


--, s.id
--SOS_PHYS_PAGE_CACHE             
--select yield_count,* from sys.dm_os_schedulers
--where status = 'VISIBLE ONLINE'
 --CREATE CLUSTERED INDEX IDX_MIS_DRAWINGS ON MIS_DRAWINGS( AS_OF_DATE )  ON ps_date_month( AS_OF_DATE )
--select * from sys.dm_os_workers
--where task_address in (select task_address from sys.dm_exec_requests where session_id = 55)
--select * from sys.dm_io_pending_io_requests

--select count(*) from T24PROD.dbo.[FBNK_BAB_VISA_CRD_ISSUE_HIS_temp_test]
--kill 131
 --CREATE CLUSTERED INDEX IDX_MIS_ACCOUNT ON MIS_ACCOUNT( AS_OF_DATE )  ON [ps_date_daily]([AS_OF_DATE])
--VERSION 2016 onward
--select 
--wait_type,
--waiting_tasks_count, cast(cast(waiting_tasks_count as float) / cast(sum(waiting_tasks_count) over() as float) * 100.0 as numeric(10,2)) [waiting_tasks_count%], 
--wait_time_ms, cast(cast(wait_time_ms as float) / cast(sum(wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [wait_time_ms%], 
--max_wait_time_ms, cast(cast(max_wait_time_ms as float) / cast(sum(max_wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [max_wait_time_ms%], 
--signal_wait_time_ms, cast(cast(signal_wait_time_ms as float) / cast(sum(signal_wait_time_ms) over() as float) * 100.0 as numeric(10,2)) [signal_wait_time_ms%]
--from sys.dm_exec_session_wait_stats 
--where session_id = 110
--and wait_type not in ('SLEEP_TASK')
--order by waiting_tasks_count desc


--SELECT TOP 10 count(1) AS lock_count, request_session_id 
----INTO #holding_locks
--FROM sys.dm_tran_locks 
--GROUP BY request_session_id ORDER BY 1 DESC 

--select * FROM sys.dm_tran_locks 

--dbcc InputBuffer(77)

--select * from sys.dm_os_waiting_tasks --order by session_id
--where session_id = 62 


--DECLARE @init_sum_cpu_time int,
--        @utilizedCpuCount int 
----get CPU count used by SQL Server
--SELECT @utilizedCpuCount = COUNT( * )
--FROM sys.dm_os_schedulers
--WHERE status = 'VISIBLE ONLINE' 
----calculate the CPU usage by queries OVER a 5 sec interval 
--SELECT @init_sum_cpu_time = SUM(cpu_time)
--FROM sys.dm_exec_requests 

--WAITFOR DELAY '00:00:05'
--)SELECT XMLRECORD FROM F_DE_O_HANDOFF_ARC WHERE RECID = @P0
--SELECT CONVERT(DECIMAL(5,
--         2),
--         ((SUM(cpu_time) - @init_sum_cpu_time) / (@utilizedCpuCount * 5000.00)) * 100) AS [CPU FROM Queries AS Percent of Total CPU Capacity]
--FROM sys.dm_exec_requests



--select * from sys.dm_tran_database_transactions
--select master.dbo.format(count(*),-1), resource_type, request_mode, resource_associated_entity_id
--from sys.dm_tran_locks l inner join sys.allocation_units a
--on l.resource_associated_entity_id = a.allocation_unit_id
--where resource_database_id = 13
--and resource_type in ('page')
--group by resource_type, request_mode, resource_associated_entity_id





--select 'kill '+cast(spid as varchar(100))
--from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
--where ltrim(s.text like '%CREATE PROCEDURE [dbo].[GET_ACC_Trx_Lst]%'

--kill 62
--kill 68
--kill 74
--kill 76
--kill 77
--kill 79
--kill 80
--kill 95
--kill 96
--kill 101
--exec sp_rename 'dbo.Get_Acct_Trx_Lst','Get_Acct_Trx_Lst_old_pro'
--go
--exec sp_rename 'dbo.Get_Acct_Trx_Lst_Test_MF','Get_Acct_Trx_Lst'

