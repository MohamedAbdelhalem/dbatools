declare @ips varchar(max)
set @ips = '10.10.10.10
10.10.10.10_2
10.10.10.10,1444
10.10.10.10,1444_2
172.0.1.120
172.0.1.120_2
172.0.1.120,1521
172.0.1.120,1521_2'

--all the above @ips just 2 IPs 10.10.10.10,1444 and 172.0.1.120,1521
  
select '('+''''+Ip_address_with_port+''''+')'+case when COUNT(*) over() = rowid then '' else ',' end
from (
select ROW_NUMBER() over(order by Ip_address_with_port) rowid, Ip_address_with_port
from (
select top 100 percent ROW_NUMBER() over(partition by case when charindex(',',value) > 0 then SUBSTRING(value, 1, CHARINDEX(',',value)-1) else value end order by 
case when charindex(',',value) > 0 then SUBSTRING(value, 1, CHARINDEX(',',value)-1) else value end, value desc) id,
case when charindex(',',value) > 0 then SUBSTRING(value, 1, CHARINDEX(',',value)-1) else value end IP_address,
value Ip_address_with_port
from (
select count(*) c, replace(case when charindex('_',value) > 0 then SUBSTRING(value, 1, CHARINDEX('_',value)-1) else value end,0x0D00,'') value
from master.dbo.Separator(@ips,char(10))
group by replace(case when charindex('_',value) > 0 then SUBSTRING(value, 1, CHARINDEX('_',value)-1) else value end,0x0D00,''))a
order by IP_address, value desc)b
where id = 1)c

