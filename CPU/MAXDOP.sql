select 
Soft_NUMA, CPU_Per_NUMA, (select value Current_MAXDOP from sys.configurations where name = 'max degree of parallelism') Current_MAXDOP,
Correct_MAXDOP
from (
select distinct 
count(*) over() Soft_NUMA, COUNT(*) CPU_Per_NUMA,
case 
when count(*) over() = 1 and COUNT(*) <= 8  then 0
when count(*) over() = 1 and COUNT(*) >= 8  then 8
when count(*) over() > 1 and COUNT(*) <= 16 then COUNT(*)
when count(*) over() > 1 and COUNT(*) >= 16 then case when (cast(COUNT(*) as float) / 2) >= 16 then 16 else (cast(COUNT(*) as float) / 2) end
end Correct_MAXDOP
from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE'
group by parent_node_id) as max_dop_val


--select * from sys.dm_os_schedulers
--where status ='VISIBLE ONLINE'
