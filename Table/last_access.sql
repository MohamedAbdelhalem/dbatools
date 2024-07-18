select database_name, table_name, 
max(convert(datetime,substring(last_access, 1, charindex('_', last_access)-1),120)) last_access,
substring(last_access, charindex('_', last_access)+1, len(last_access)) description
from (
select db_name(database_id) database_name, '['+schema_name(t.schema_id)+'].['+t.name+']' table_name, (
	select max(last_access) 
	from (
		values 
			(last_user_seek),
			(last_user_scan),
			(last_user_lookup),
			(last_user_update)
		 ) as g(last_access)) last_access
from (
select u.database_id, u.object_id, 
convert(varchar(50),last_user_seek,120)  +'_last_user_seek'   last_user_seek,
convert(varchar(50),last_user_scan,120)  +'_last_user_scan'   last_user_scan,
convert(varchar(50),last_user_lookup,120)+'_last_user_lookup' last_user_lookup,
convert(varchar(50),last_user_update,120)+'_last_user_insert_update_delete' last_user_update 
from sys.dm_db_index_usage_stats u 
where u.database_id = db_id()) u
inner join sys.indexes i
on u.object_id = i.object_id
inner join sys.tables t
on u.object_id = t.object_id)a
group by database_name, table_name,
substring(last_access, charindex('_', last_access)+1, len(last_access)) 

--If the description, last_user_insert_update_delete, has the same last access as the last_user_seek:
----Afterward, it was noted that users were deleting or updating records using predicates (WHERE condition).

--If description last_user_insert_update_delete alone 
--Then:
----1. 99% of it consisted of insert statements.
----2. 1% of it was updated or deleted without any predicates (WHERE condition), which is a rare case.
