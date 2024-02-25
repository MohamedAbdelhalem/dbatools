use master
go
select 
[max worker threads], 
[Current worker thread],
cast(cast([Current worker thread] as float) / cast([max worker threads] as float) * 100.0 as numeric(10,2)) [current WTs %],
cast([max worker threads] as int) - [Current worker thread] [Available worker threads],
100 - cast(cast([Current worker thread] as float) / cast([max worker threads] as float) * 100.0 as numeric(10,2)) [Available WTs %],
[avg work queue count],
[Workers waiting for cpu],
[configuration type], [windows version]
from (
select [Request Waiting For Threads], [Workers Waiting For Cpu], [max worker threads] = case when c.value = 0 then case 
when @@version like '%(x86)%' then case
when cpu_count <= 4 then 256
when cpu_count >  4 then 256 + ((cpu_count - 4) * 8)
end 
when @@version like '%(X64)%' then case
when cpu_count <= 4 then 512 
when cpu_count >  4 then 512 + ((cpu_count - 4) * 16)
end end else c.value end,
cwt.[Current worker thread], 
 wq.[avg work queue count],
case when c.value = 0 then 'auto' else 'manual' end [configuration type], 
wv.win_version + case 
when @@version like '%(x86)%' then ' - 32 bit'
when @@version like '%(X64)%' then ' - 64 bit'
end [windows version]
from sys.dm_os_sys_info info 
cross apply (select value from sys.configurations where name = 'max worker threads') c
cross apply (select case win_version
					when 'Windows NT 6.0' then 'Windows Server 2008'
					when 'Windows NT 6.1' then 'Windows Server 2008 R2'
					when 'Windows NT 6.2' then 'Windows Server 2012'
					when 'Windows NT 6.3' then 'Windows Server 2012 R2'
					else win_version end win_version
			from (
			select 
			ltrim(rtrim(substring(@@version , charindex(' on ',@@version) + len(' on '), charindex('<', @@version) - charindex(' on ',@@version) - len(' on ')))) win_version)a) wv
cross apply (SELECT SUM(active_workers_count) [Current worker thread], 
					SUM(runnable_tasks_count) [Workers Waiting For Cpu], 
					SUM(work_queue_count) [Request Waiting For Threads] 
					FROM sys.dm_os_schedulers WITH (NOLOCK) WHERE [status] = N'VISIBLE ONLINE') cwt
cross apply (SELECT AVG(work_queue_count) [avg work queue count] FROM sys.dm_os_schedulers WITH (NOLOCK) WHERE [status] = N'VISIBLE ONLINE') wq)b
