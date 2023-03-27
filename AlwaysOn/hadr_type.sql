declare @last_full_backup_job_running datetime, @availability_groups varchar(300)
select @last_full_backup_job_running = max(convert(datetime, convert(varchar(20), run_date, 112),120))
from msdb..sysjobhistory jh inner join msdb..sysjobs j
on j.job_id = jh.job_id
where j.name = 'DatabaseBackup - USER_DATABASES - FULL'


select @availability_groups = name from sys.availability_groups

select *, @@SERVERNAME Server_name, CONNECTIONPROPERTY('local_net_address') Server_IP, @last_full_backup_job_running last_full_Native_backup, @availability_groups availability_groups
from (
select  
case 
row_number() over(order by database_status) 
when 1 then 'hadr_1'
when 2 then 'hadr_2'
when 3 then 'hadr_3'
when 4 then 'hadr_4'
end id, 
database_status+'('+cast(count(*) as varchar(10))+')' database_status_count
from (
select count(*)c,
db.name,
case 
when dbrs.database_id is null		and dbm.mirroring_guid is null		then 'Sandalone' 
when dbrs.database_id is not null	and dbm.mirroring_guid is null		then 'AlwaysOn' 
when dbrs.database_id is null		and dbm.mirroring_guid is not null  then 'Mirroring' 
end database_status
from sys.databases db left outer join
sys.dm_hadr_database_replica_states dbrs
on db.database_id = dbrs.database_id
left outer join
sys.database_mirroring dbm
on db.database_id = dbm.database_id
where db.database_id > 4
group by db.name, dbrs.database_id , dbm.mirroring_guid)a
group by database_status)b 
pivot (
max(database_status_count) for id in ([hadr_1],[hadr_2],[hadr_3],[hadr_4],[hadr_5]))p

