--parameters
declare 
@automartic			int = 0

--variables
declare 
@total_cpus			int, 
@avg_NUMA_nodes		int, 
@cpu_per_NUMA_node	int,
@loop				int = 0,
@data				float = 1
declare @cpuMasking table (cpuid int, cpumask decimal(38))

if @automartic = 1
begin
select 
@total_cpus = total_cpus, 
@avg_NUMA_nodes = avg_NUMA_nodes, 
@cpu_per_NUMA_node = total_cpus / avg_NUMA_nodes 
from (
select cpus total_cpus,(
	select avg(numa_nodes)
	from (
		select min(cpus)cpus, numa_nodes
			from (	values 
					(cpus/ 2.0,2),
					(cpus/ 3.0,3),
					(cpus/ 4.0,4),
					(cpus/ 5.0,5),
					(cpus/ 6.0,6),
					(cpus/ 7.0,7),
					(cpus/ 8.0,8),
					(cpus/ 9.0,9),
					(cpus/ 10.0,10),
					(cpus/ 11.0,11),
					(cpus/ 12.0,12)
				) as g(cpus,numa_nodes) 
			where cpus - cast(cpus as int) = 0 
			group by numa_nodes
		)a  where cpus > 1) avg_NUMA_nodes
from (
select count(*) cpus
from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE')a)b

end
else
begin

select @total_cpus = (select count(*) from sys.dm_os_schedulers where status = 'VISIBLE ONLINE'), 
@avg_NUMA_nodes = 3

set @cpu_per_NUMA_node = @total_cpus / @avg_NUMA_nodes 

end

while @loop < @total_cpus
begin

if @loop > 0
begin
set @data = @data * 2
end

insert into @cpuMasking
select @loop, cast(case @loop when 0 then 1 else @data end as decimal(38))

set @loop += 1
end

select gid Soft_NUMA_node, @avg_NUMA_nodes NUMA_nodes, @cpu_per_NUMA_node cpu_per_NUMA_node,
sum(cpumask) cpuMaskDecimal, 
case 
when len(sum(cpumask)) in (1,2) then convert(varbinary(max),cast(sum(cpumask) as tinyint))
when len(sum(cpumask)) in (3,4) then convert(varbinary(max),cast(sum(cpumask) as smallint))
when len(sum(cpumask)) in (5,6,7,8,9,10) then convert(varbinary(max),cast(sum(cpumask) as int))
when len(sum(cpumask)) in (11,12,13,14,15,16,17,18) then convert(varbinary(max),cast(sum(cpumask) as bigint))
when len(sum(cpumask)) in (19) then convert(varbinary(max),cast(sum(cpumask) as decimal(19)))
when len(sum(cpumask)) in (20) then convert(varbinary(max),cast(sum(cpumask) as decimal(20)))
when len(sum(cpumask)) in (21) then convert(varbinary(max),cast(sum(cpumask) as decimal(21)))
when len(sum(cpumask)) in (22) then convert(varbinary(max),cast(sum(cpumask) as decimal(22)))
when len(sum(cpumask)) in (23) then convert(varbinary(max),cast(sum(cpumask) as decimal(23)))
when len(sum(cpumask)) in (24) then convert(varbinary(max),cast(sum(cpumask) as decimal(24)))
when len(sum(cpumask)) in (25) then convert(varbinary(max),cast(sum(cpumask) as decimal(25)))
when len(sum(cpumask)) in (26) then convert(varbinary(max),cast(sum(cpumask) as decimal(26)))
when len(sum(cpumask)) in (27) then convert(varbinary(max),cast(sum(cpumask) as decimal(27)))
when len(sum(cpumask)) in (28) then convert(varbinary(max),cast(sum(cpumask) as decimal(28)))
when len(sum(cpumask)) in (29) then convert(varbinary(max),cast(sum(cpumask) as decimal(29)))
when len(sum(cpumask)) in (30) then convert(varbinary(max),cast(sum(cpumask) as decimal(30)))
when len(sum(cpumask)) in (31) then convert(varbinary(max),cast(sum(cpumask) as decimal(31)))
when len(sum(cpumask)) in (32) then convert(varbinary(max),cast(sum(cpumask) as decimal(32)))
when len(sum(cpumask)) in (33) then convert(varbinary(max),cast(sum(cpumask) as decimal(33)))
when len(sum(cpumask)) in (34) then convert(varbinary(max),cast(sum(cpumask) as decimal(34)))
when len(sum(cpumask)) in (35) then convert(varbinary(max),cast(sum(cpumask) as decimal(35)))
when len(sum(cpumask)) in (36) then convert(varbinary(max),cast(sum(cpumask) as decimal(36)))
when len(sum(cpumask)) in (37) then convert(varbinary(max),cast(sum(cpumask) as decimal(37)))
when len(sum(cpumask)) in (38) then convert(varbinary(max),cast(sum(cpumask) as decimal(38)))
end cpuMaskHex
from (
select 
master.dbo.gBulk(row_number() over(order by cpuid),@cpu_per_NUMA_node) gid,
cpuid, cpumask
from @cpuMasking)a
group by gid
order by gid

