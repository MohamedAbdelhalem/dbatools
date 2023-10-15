use master
go
select 
counter_name, 
cntr_value PLE_value,
master.dbo.duration('s',cntr_value) Actual_PLE,
master.dbo.numberSize(total_physical_memory_kb,'kb') Server_Memory,
master.dbo.virtical_array(ple,',',1) Data_Cache_Size,
master.dbo.virtical_array(ple,',',2) Expected_PLE_n,
master.dbo.virtical_array(ple,',',3) Expected_PLE_h
from sys.dm_os_performance_counters p cross apply (	select value_in_use,
master.dbo.numbersize(cast(case when value_in_use = 2147483647 then pm.physical_memory_in_use_kb/1024.0 else value_in_use end as int),'mb')+','+ 
cast((cast(case when value_in_use = 2147483647 then pm.physical_memory_in_use_kb/1024.0 else value_in_use end as float)/1024.0/4.0)*300 as varchar(100))+','+
master.dbo.duration('s',(cast(case when value_in_use = 2147483647 then pm.physical_memory_in_use_kb/1024.0 else value_in_use end as float)/1024.0/4.0)*300) ple
from sys.configurations c cross apply sys.dm_os_process_memory pm
where name = 'max server memory (mb)') ple
cross apply sys.dm_os_sys_memory
where cast(counter_name as varchar(100)) like 'Page life%'
and cast(object_name as varchar(100)) like '%Buffer Manager%'

--baseline memory before start
-------------------------------------------------------------------------------------------------------------------------------------------------
--counter_name			|	PLE_value	|	Actual_PLE		|	Server_Memory	|	Data_Cache_Size	|	Expected_PLE_n	|	Expected_PLE_h		|
-------------------------------------------------------------------------------------------------------------------------------------------------
--Page life expectancy  |	57837		|	0d 16h:03m:57s	|	640 GB			|	493.16 GB		|	36987.3	0d		|	10h:16m:27s			|
-------------------------------------------------------------------------------------------------------------------------------------------------
