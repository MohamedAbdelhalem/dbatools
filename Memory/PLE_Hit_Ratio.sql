use master
go
select round((hit_ratio / hit_ratio_base) * 100.0, 2) Buffer_Cache_Hit_Ratio
from (
select cast(cntr_value as float) hit_ratio
from sys.dm_os_performance_counters
where cast(counter_name as varchar(100)) = 'Buffer cache hit ratio'
and cast(object_name as varchar(100)) like '%Buffer Manager%')a
cross apply (
select cast(cntr_value as float) hit_ratio_base
from sys.dm_os_performance_counters
where cast(counter_name as varchar(100)) = 'Buffer cache hit ratio base'
and cast(object_name as varchar(100)) like '%Buffer Manager%')b

SELECT ROUND(CAST(A.cntr_value1 AS NUMERIC) /
CAST(B.cntr_value2 AS NUMERIC),3) AS Buffer_Cache_Hit_Ratio
FROM ( SELECT cntr_value AS cntr_value1
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Buffer Manager' AND counter_name = 'Buffer cache hit ratio'
) AS A,
(SELECT cntr_value AS cntr_value2
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Buffer Manager' AND counter_name = 'Buffer cache hit ratio base'
) AS B;

SELECT counter_name as CounterName, (a.cntr_value * 1.0 / b.cntr_value) * 100.0 as BufferCacheHitRatio 
FROM sys.dm_os_performance_counters  a JOIN  (
SELECT cntr_value,OBJECT_NAME 
FROM sys.dm_os_performance_counters 
WHERE   counter_name = 'Buffer cache hit ratio base' AND   OBJECT_NAME LIKE '%Buffer Manager%') b 
ON  a.OBJECT_NAME = b.OBJECT_NAME 
WHERE a.counter_name = 'Buffer cache hit ratio'      AND a.OBJECT_NAME LIKE '%Buffer Manager%'

--dbcc dropcleanbuffers
select cast(cntr_value as float) hit_ratio_base
from sys.dm_os_performance_counters
where cast(counter_name as varchar(100)) = 'Buffer cache hit ratio'
and cast(object_name as varchar(100)) like '%Buffer Manager%'

select cast(cntr_value as float) hit_ratio
from sys.dm_os_performance_counters
where cast(counter_name as varchar(100)) = 'Buffer cache hit ratio'
and cast(object_name as varchar(100)) like '%Buffer Manager%'

--select 
--counter_name, 
--cntr_value PLE_value,
--master.dbo.duration('s',cntr_value) Actual_PLE,
--master.dbo.numberSize(total_physical_memory_kb,'kb') Server_Memory,
--master.dbo.virtical_array(ple,',',1) Data_Cache_Size,
----master.dbo.virtical_array(ple,',',2) Expected_PLE_n,
--master.dbo.virtical_array(ple,',',3) Expected_PLE_h
--from sys.dm_os_performance_counters p cross apply (	select
--													master.dbo.numbersize(cast(value_in_use as int),'mb')+','+ 
--													cast((cast(value_in_use as float)/1024.0/4.0)*300 as varchar(100))+','+
--													master.dbo.duration('s',(cast(value_in_use as float)/1024.0/4.0)*300) ple
--													from sys.configurations 
--													where name = 'max server memory (mb)') ple
--cross apply sys.dm_os_sys_memory
--where cast(counter_name as varchar(100)) like 'Page life%'
--and cast(object_name as varchar(100)) like '%Buffer Manager%'
----dbcc DropCleanBuffers;

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
--dbcc DropCleanBuffers;



--select * from sys.dm_db_index_operational_stats (5, object_id(''), 1, null, 'detailed') 

