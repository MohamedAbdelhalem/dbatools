begin transaction 
set transaction isolation level repeatable read

select count(*)--SalesOrderID
from [Sales].[SalesOrderHeader] with (rowlock)
where OrderDate between
'2011-05-31 00:00:00.000' and
'2012-05-31 00:00:00.000'

select count(*) from sys.dm_tran_locks where request_session_id = @@spid
select * from sys.dm_tran_locks where request_session_id = @@spid
select master.dbo.numbersize(sum(pages_kb),'k') pages_size from sys.dm_os_memory_clerks where type = 'OBJECTSTORE_LOCK_MANAGER' and name != 'Lock Manager : DAC Node'

--select name, lock_escalation_desc 
--from sys.tables 
--where object_id = object_id('[Sales].[SalesOrderHeader]')
commit
