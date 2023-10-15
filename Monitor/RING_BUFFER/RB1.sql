SELECT  
CONVERT (varchar(30), GETDATE(), 121) as runtime, 
DATEADD (ms, a.[Record Time] - sys.ms_ticks, GETDATE()) AS Notification_time,    
a.* , 
sys.ms_ticks AS [Current Time]  
FROM   (SELECT x.value('(//Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [ProcessUtilization],    
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle %],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/UserModeTime) [1]', 'bigint') AS [UserModeTime],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime) [1]', 'bigint') AS [KernelModeTime],    
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/PageFaults) [1]', 'bigint') AS [PageFaults],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/WorkingSetDelta) [1]', 'bigint')/1024 AS [WorkingSetDelta],   
x.value('(//Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization) [1]', 'bigint') AS [MemoryUtilization (%workingset)],   
x.value('(//Record/@time)[1]', 'bigint') AS [Record Time]  FROM (SELECT CAST (record as xml) FROM sys.dm_os_ring_buffers    
WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR') AS R(x)) a  CROSS JOIN sys.dm_os_sys_info sys ORDER BY DATEADD (ms, a.[Record Time] - sys.ms_ticks, GETDATE())

SELECT  StartTime   =   DATEADD(MILLISECOND, sqlserver_start_time_ms_ticks - ms_ticks, GETDATE()), cast(ms_ticks as bigint)
  FROM  sys.dm_os_sys_info;




go
declare @ts_now bigint
select @ts_now = cpu_ticks / (cpu_ticks/ms_ticks) from sys.dm_os_sys_info;
select record_id,
dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime,
SQLProcessUtilization,
SystemIdle,
100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization
from (
select
record.value('(./Record/@id)[1]', 'int') as record_id,
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as SQLProcessUtilization,
timestamp
from (
select timestamp, convert(xml, record) as record
from sys.dm_os_ring_buffers
where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
and record like '%%') as x
) as y
order by record_id desc
