  SELECT 
     sqlserver_start_time,
     master.dbo.numbersize(committed_kb,'kb') [committed],
     master.dbo.numbersize(committed_target_kb,'kb') committed_target           
   FROM sys.dm_os_sys_info;

   select 
   master.dbo.numbersize(total_physical_memory_kb,'kb') total_physical_memory, 
   master.dbo.numbersize(available_physical_memory_kb,'kb') available_physical_memory, 
   master.dbo.numbersize(total_page_file_kb,'kb') total_page_file, 
   master.dbo.numbersize(available_page_file_kb,'kb') available_page_file, 
   master.dbo.numbersize(system_cache_kb,'kb') system_cache, 
   master.dbo.numbersize(kernel_paged_pool_kb,'kb') kernel_paged_pool, 
   master.dbo.numbersize(kernel_nonpaged_pool_kb,'kb') kernel_nonpaged_pool, 
   system_memory_state_desc
   from sys.dm_os_sys_memory

select *, master.dbo.duration(cntr_value)  [Page life expectancy]
from sys.dm_os_performance_counters
where counter_name like '%life%'

select
master.dbo.numbersize(physical_memory_in_use_kb,'kb') Phy_Memory_usedby_Sqlserver,
master.dbo.numbersize(locked_page_allocations_kb,'kb')Locked_pages_used_Sqlserver,
master.dbo.numbersize(virtual_address_space_committed_kb,'kb')Total_Memory_UsedBySQLServer,
process_physical_memory_low,
process_virtual_memory_low
from sys.dm_os_process_memory

select isnull(db_name(database_id),'ResourceDB') database_name, count(*) number_of_clean_pages, master.dbo.numberSize(count(*)*8,'k') size_of_clean_pages
from sys.dm_os_buffer_descriptors
where is_modified = 0
group by database_id
order by number_of_clean_pages desc 

--DBCC DROPCLEANBUFFERS

declare 
@total_memory_clerks  varchar(50),
@size_of_clean_pages  varchar(50),
@buffer_memory_clerks varchar(50)

select @size_of_clean_pages =  master.dbo.numberSize(count(*)*8,'k') 
from sys.dm_os_buffer_descriptors
where is_modified = 0

SELECT @buffer_memory_clerks = master.dbo.numberSize(sum(pages_kb),'kb') 
FROM sys.dm_os_memory_clerks
where name ='Default'

SELECT @total_memory_clerks = master.dbo.numberSize(sum(pages_kb),'kb') 
FROM sys.dm_os_memory_clerks

select 
@total_memory_clerks total_memory_clerks,
@buffer_memory_clerks total_nodes_buffers,
@size_of_clean_pages size_of_clean_pages




--dbcc DropCleanBuffers