declare @table table ([object_name] varchar(1000), counter_name varchar(1000), instance_name varchar(1000), current_value varchar(200))

insert into @table
select object_name, counter_name, instance_name, cntr_value
from sys.dm_os_performance_counters
where object_name like '%mirr%'
--and instance_name ='POS_BIB_STMNT_PRD'
and counter_name not like '%/%'
--and counter_name in ('Log Send Queue KB','Redo Queue KB','Transaction Delay')
and cntr_value > 0 
--and instance_name = '_Total'
--and instance_name = 'Proview42'
order by counter_name

select 
object_name, counter_name, instance_name, ltrim(rtrim(current_value)) , case 
when counter_name like '% kb %' then master.dbo.numberSize(current_value,'KB')
when counter_name like '%(ms)%' then master.dbo.duration('s',current_value/1000) 
else 
current_value
end current_value
from @table
order by counter_name

--Log Send Queue KB
--Total number of kilobytes of log that have not yet been sent to the mirror server.
--Redo Queue KB                                                                                                                   
--Total number of kilobytes of hardened log that currently remain to be applied to the mirror database to roll it forward. This is sent to the Principal from the Mirror.
--Log Send Flow Control Time (ms) 
--
--Log Harden Time (ms)
--Milliseconds that log blocks waited to be hardened to disk, in the last second.
--more detailed description
--This measures the delay between the mirror server receiving a chunk of transaction log and it being hardened on the mirror database’s log disk (i.e. the delay before the chunk of transaction log becomes part of the redo queue on the mirror server).
--If this number is higher than normal it means the mirror database’s log disk is more heavily loaded and may be  becoming saturated.