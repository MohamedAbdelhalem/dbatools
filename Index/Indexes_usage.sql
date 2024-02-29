use master
go
declare @table table (
[database_name] varchar(500), table_name varchar(500), index_id int, index_name varchar(500),
user_seeks int, user_scans int, user_lookups int, user_updates int, 
last_user_seek datetime, last_user_scan datetime, last_user_lookup datetime, last_user_update datetime, 
system_seeks int, system_scans int, system_lookups int, system_updates int, 
last_system_seek datetime, last_system_scan datetime, last_system_lookup datetime, last_system_update datetime)

insert into @table
exec sp_MSForEachDB 'use [?]
select 
db_name(ss.database_id), 
''[''+schema_name(t.schema_id)+''].[''+t.name+'']'' table_name, ss.index_id, i.name index_name,  
ss.user_seeks, ss.user_scans, ss.user_lookups, ss.user_updates, 
ss.last_user_seek, ss.last_user_scan, ss.last_user_lookup, ss.last_user_update, 
ss.system_seeks, ss.system_scans, ss.system_lookups, ss.system_updates, 
ss.last_system_seek, ss.last_system_scan, ss.last_system_lookup, ss.last_system_update
from sys.dm_db_index_usage_stats ss inner join sys.indexes i
on i.object_id = ss.object_id
and i.index_id = ss.index_id
inner join sys.tables t
on ss.object_id = t.object_id
order by table_name, ss.index_id'

select 
db.name database_name, table_name, index_id, index_name, 
user_seeks, user_scans, user_lookups, user_updates, 
last_user_seek, last_user_scan, last_user_lookup, 
last_user_update, system_seeks, system_scans, system_lookups, system_updates, 
last_system_seek, last_system_scan, last_system_lookup, last_system_update
from sys.databases db left outer join @table t
on db.name = t.database_name
where db.database_id > 4
order by db.name, table_name, index_id

