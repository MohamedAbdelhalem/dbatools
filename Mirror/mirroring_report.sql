select (select COUNT(*) from sys.databases where database_id > 4) total_user_databases,
sum(db_mirror_count) over() overall_sync, db_mirror_count, 
case mirroring_safety_level_desc when 'FULL' then 'High Safety' when 'OFF' then 'High Performance' end mirroring_safety_level_desc,
case mirroring_safety_level_desc when 'FULL' then 'synchronous' when 'OFF' then 'asynchronous' else mirroring_safety_level_desc end type, 
case when sum(db_mirror_count) over() = db_mirror_count then 'okay' else null end mirror_status,
case when sum(db_mirror_count) over() = db_mirror_count and (select COUNT(*) from sys.databases where database_id > 4) >  db_mirror_count then cast((select COUNT(*) from sys.databases where database_id > 4) - db_mirror_count as varchar(10))+' database/s is/are missing' 
else 'all dbs in mirror' end overall_status
from (
select COUNT(*) db_mirror_count, mirroring_safety_level_desc 
from sys.database_mirroring
where mirroring_guid is not null
group by mirroring_safety_level_desc)a



