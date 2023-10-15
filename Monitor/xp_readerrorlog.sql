declare @table table (LogDate datetime, ProcessInfo varchar(100), Text varchar(max))
insert into @table
exec xp_readerrorlog 0
--insert into @table
--exec xp_readerrorlog 1
--insert into @table
--exec xp_readerrorlog 2
--insert into @table
--exec xp_readerrorlog 3
--insert into @table
--exec xp_readerrorlog 4
--insert into @table
--exec xp_readerrorlog 5

select * from @table 
where ProcessInfo not in ('backup','logon')
--and Text like '%35217%'
and Text like 'Error: %'


SELECT 
is_preemptive
,STATE
,last_wait_type
,count(*) AS NumWorkers
FROM sys.dm_os_workers
GROUP BY STATE
,last_wait_type
,is_preemptive
ORDER BY count(*) DESC


SELECT count(*) AS NumWorkers
FROM sys.dm_os_workers


select max_workers_count, current_workers, cast(cast(current_workers as float) / cast(max_workers_count as float) * 100.0 as numeric(10,2)) pct
from (
select max_workers_count, ( SELECT count(*) current_workers
FROM sys.dm_os_workers) current_workers
from sys.dm_os_sys_info) a 

