select max_workers_count, current_workers, cast(cast(current_workers as float) / cast(max_workers_count as float) * 100.0 as numeric(10,2)) pct 
from (
	select max_workers_count, (SELECT count(*) current_workers 
							   FROM sys.dm_os_workers 
							   where state = 'SUSPENDED') current_workers 
	from sys.dm_os_sys_info) a
