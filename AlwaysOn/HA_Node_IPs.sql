declare @mirror_port varchar(10)
select @mirror_port = port 
from sys.tcp_endpoints
where type = 4 


declare @xp_mirror varchar(1000) = 'netstat -ano | findstr '+@mirror_port
declare @mirror table (output_text varchar(1000))
insert into @mirror
exec xp_cmdshell @xp_mirror

select 
hadr_node_ip, is_local, role_desc, node_name, case when left(node_name,2) = 'D1' then 'PDC' else 'SDC' end Location,
case when is_local = 1 and role_desc = 'PRIMARY' then 'Normal no action required' else '' end service
from (
select 
hadr_node_ip, d.is_local, role_desc, case d.is_local when 1 then (
select case when charindex('\',name) > 0 then substring(name,1,charindex('\',name)-1) else name end name 
from sys.servers 
where server_id = 0) else rcs.replica_server_name end node_name
from (
select 
hadr_node_ip, case when hadr_node_ip = CONNECTIONPROPERTY('local_net_address') then 1 else 0 end is_local
from (
select distinct IPSource hadr_node_ip
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
where output_text like '%ESTABLISHED%')a)b)c)d
left outer join sys.dm_hadr_availability_replica_states rs
on d.is_local = rs.is_local
left outer join sys.dm_hadr_availability_replica_cluster_states rcs
on rs.replica_id = rcs.replica_id
)e
order by hadr_node_ip



go
declare @ag table (number_current_sessions int, database_connections_used_IP varchar(50))
declare @mirror table (output_text varchar(1000), ag_id int)
declare @ip varchar(50), @ag_loop int = 0, @xp varchar(200)
declare lis cursor fast_forward
for
select ip_address
from sys.availability_group_listener_ip_addresses
where state = 1
union 
select cast(CONNECTIONPROPERTY('local_net_address') as varchar(50))

--xp_cmdshell 'netstat -ano | findstr 10.36.0.74'

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

select number_current_sessions, database_connections_used_IP, case 
when CONNECTIONPROPERTY('local_net_address') = database_connections_used_IP then 'node_ip' else 'listener ip' end ip_type
from @ag a

select 
isnull(number_current_sessions,0) number_current_sessions, 
case when isnull(number_current_sessions,0) > 0 then 1 else 0 end App_use_Ag_listener , 
ag.name ag_name, dns_name listener_name, ip_address [listener_ip], port 
from sys.availability_group_listeners l inner join sys.availability_group_listener_ip_addresses li
on l.listener_id = li.listener_id
inner join sys.availability_groups ag
on l.group_id = ag.group_id
left outer join @ag a
on li.ip_address = a.database_connections_used_IP
where state = 1

--select * from sys.dm_os_cluster_properties
--select * from sys.dm_hadr_cluster
--exec xp_cmdshell 'powershell.exe get-clusterresource'
--declare @DefaultBackup varchar(100)
--exec xp_instance_regread 'HKEY_LOCAL_MACHINE', N'Cluster\Resources\', @DefaultBackup output
--exec xp_instance_regread 'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory', @DefaultBackup output
--select @DefaultBackup

--EXECUTE master.sys.xp_instance_regenumvalues
--    'HKEY_LOCAL_MACHINE',
--    'Cluster\Resources\2e112bd4-e01e-4824-882b-c9f75a9606ac';

--	EXECUTE master.sys.xp_instance_regenumkeys'HKEY_LOCAL_MACHINE','Cluster\Resources';
