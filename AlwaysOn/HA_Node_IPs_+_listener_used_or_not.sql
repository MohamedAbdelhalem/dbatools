declare @mirror table (output_text varchar(1000))
insert into @mirror
exec xp_cmdshell 'netstat -ano | findstr 5022'

select distinct IPSource HA_Node_IPs
from (
select 
substring(output_text, 1, charindex(':', output_text)-1) IPSource,
ltrim(substring(output_text, charindex(' ', output_text), len(output_text))) IPdestination
from (
select ltrim(substring(ltrim(rtrim(output_text)),charindex(' ',ltrim(rtrim(output_text))), len(ltrim(rtrim(output_text))))) output_text
from @mirror
where output_text like '%ESTABLISHED%')a)b
union 
select distinct
substring(IPdestination, 1, charindex(':', IPdestination)-1) Node_IP2
from (
select 
substring(output_text, 1, charindex(':', output_text)-1) IPSource,
ltrim(substring(output_text, charindex(' ', output_text), len(output_text))) IPdestination
from (
select ltrim(substring(ltrim(rtrim(output_text)),charindex(' ',ltrim(rtrim(output_text))), len(ltrim(rtrim(output_text))))) output_text
from @mirror
where output_text like '%ESTABLISHED%')a)b
order by HA_Node_IPs



go
declare @ag table (number_curr_sessions int, ag_listener_ip varchar(50))
declare @mirror table (output_text varchar(1000), ag_id int)
declare @ip varchar(50), @ag_loop int = 0, @xp varchar(200)
declare lis cursor fast_forward
for
select ip_address
from sys.availability_group_listener_ip_addresses
where state = 1

open lis
fetch next from lis into @ip
while @@FETCH_STATUS = 0
begin

set @xp = 'netstat -ano | findstr '+@ip

insert into @mirror (output_text)
exec xp_cmdshell @xp

set @ag_loop += 1 

update @mirror set ag_id = @ag_loop where ag_id is null

insert into @ag 
select count(*), IPSource HA_Node_IPs
from (
select 
substring(output_text, 1, charindex(':', output_text)-1) IPSource,
ltrim(substring(output_text, charindex(' ', output_text), len(output_text))) IPdestination
from (
select ltrim(substring(ltrim(rtrim(output_text)),charindex(' ',ltrim(rtrim(output_text))), len(ltrim(rtrim(output_text))))) output_text
from @mirror
where output_text like '%ESTABLISHED%'
and ag_id = @ag_loop)a)b
group by IPSource 
order by HA_Node_IPs

fetch next from lis into @ip
end
close lis
deallocate lis

select 
isnull(number_curr_sessions,0) number_curr_sessions, 
case when isnull(number_curr_sessions,0) > 0 then 1 else 0 end App_use_Ag_listener , 
ag.name ag_name, dns_name listener_name, ip_address [listener_ip], port 
from sys.availability_group_listeners l inner join sys.availability_group_listener_ip_addresses li
on l.listener_id = li.listener_id
inner join sys.availability_groups ag
on l.group_id = ag.group_id
left outer join @ag a
on li.ip_address = a.ag_listener_ip
where state = 1
