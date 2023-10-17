select count(*) [sessions], db_name(resource_database_id) [database]
from sys.dm_tran_locks
where resource_type = 'database' and
--resource_database_id = 3 and
request_type = 'LOCK' and
request_status = 'GRANT'
group by resource_database_id 

