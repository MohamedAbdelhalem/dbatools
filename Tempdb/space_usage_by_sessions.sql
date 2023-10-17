select 
db_name(database_id) database_name,
count(*) sessions, 
sum(case when session_id <  50 then 1 else 0 end) no_internal_sessions,
sum(case when session_id >= 50 then 1 else 0 end) no_user_sessions,
master.dbo.numbersize(SUM(user_objects_alloc_page_count + internal_objects_alloc_page_count) * 8.0, 'K') allocation_size,
master.dbo.numbersize(SUM(user_objects_dealloc_page_count + internal_objects_dealloc_page_count) * 8.0, 'K') deallocation_size,
master.dbo.numbersize(SUM(user_objects_alloc_page_count) * 8.0, 'K') user_objects_alloc_size,
master.dbo.numbersize(SUM(user_objects_dealloc_page_count) * 8.0, 'K') user_objects_dealloc_size,
master.dbo.numbersize(SUM(internal_objects_alloc_page_count) * 8.0, 'K') internal_objects_alloc_size,
master.dbo.numbersize(SUM(internal_objects_dealloc_page_count) * 8.0, 'K') internal_objects_dealloc_size
from sys.dm_db_task_space_usage
group by database_id

--later on add dm_db_task_space_usage to head_blocker script to know the sleeping sessions that have the bigger tempdb version store
