--select * from master.sys.dm_hadr_database_replica_states

select ars.role, drs.database_id, drs.replica_id, drs.last_commit_time, getdate(), 
case when datediff(MS,drs.last_commit_time, getdate()) < 0 then '00:00:00.000' else substring(convert(varchar(40), dateadd(MS, datediff(MS,drs.last_commit_time, getdate()), '2000-01-01'),121),12,20) end duration
--into #tmpdbr_database_replica_states_primary_LCT 
from  master.sys.dm_hadr_database_replica_states as drs 
left join master.sys.dm_hadr_availability_replica_states ars on drs.replica_id = ars.replica_id 
--where ars.role = 1

--SELECT   *
--FROM   ::fn_listextendedproperty(NULL, NULL, NULL, NULL, NULL, NULL, NULL)