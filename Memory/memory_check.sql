select ID, isnull(database_name, 'Total Buffer Pool (Data Cache)') Database_name, Number_of_Clean_Pages, Size_of_Clean_Pages, Number_of_Dirty_Pages, Size_of_Dirty_Pages
from (
select row_number() over(order by c.database_name) id, c.database_name, number_of_clean_pages, master.dbo.numberSize(size_of_clean_pages,'k') size_of_clean_pages, number_of_dirty_pages, master.dbo.numberSize(size_of_dirty_pages,'k') size_of_dirty_pages
from (
select isnull(db_name(database_id),'ResourceDB') database_name, count(*) number_of_clean_pages, count(*)*8 size_of_clean_pages
from sys.dm_os_buffer_descriptors
where is_modified = 0
group by database_id) c left outer join (
select isnull(db_name(database_id),'ResourceDB') database_name, count(*) number_of_dirty_pages, count(*)*8 size_of_dirty_pages
from sys.dm_os_buffer_descriptors
where is_modified = 1
group by database_id) d
on c.database_name = d.database_name
union
select 0, NULL, sum(number_of_clean_pages), master.dbo.numberSize(sum(size_of_clean_pages),'k'), sum(number_of_dirty_pages), master.dbo.numberSize(sum(size_of_dirty_pages),'k')
from (
select isnull(db_name(database_id),'ResourceDB') database_name, count(*) number_of_clean_pages, count(*)*8 size_of_clean_pages
from sys.dm_os_buffer_descriptors
where is_modified = 0
group by database_id) c left outer join (
select isnull(db_name(database_id),'ResourceDB') database_name, count(*) number_of_dirty_pages, count(*)*8 size_of_dirty_pages
from sys.dm_os_buffer_descriptors
where is_modified = 1
group by database_id) d
on c.database_name = d.database_name) report
order by id



select *, master.dbo.duration('s', cntr_value)  [Page life expectancy]
from sys.dm_os_performance_counters
where counter_name = 'Page life expectancy' 
and object_name = 'SQLServer:Buffer Manager' 

