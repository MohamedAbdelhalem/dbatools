declare @server_location table (server_id int identity(1,1), ag_name varchar(255), server_name varchar(255), role_desc varchar(100), location_desc varchar(100)) 
declare @DCLocation table (role_desc varchar(100), location_desc varchar(100))
declare 
@load_balncing    bit = 0,  --values (0,1) 1 = yes, 0 = no load balancing
@balance_sync_type varchar(100) = 'Report',
@allowConn        varchar(100) = 'Yes', --'AppIntent' = 'READ_ONLY', 'Yes' = 'ALL'
@port             varchar(10),
@sql              varchar(max),
@loop             int = 0,
@dc_role          varchar(100),
@replicas         int,
@ag_name          varchar(255),
@replica_server   varchar(255),
@read_only_routing_list varchar(max),
@1                varchar(255), 
@2                varchar(255), 
@3                varchar(255), 
@4                varchar(255), 
@5                varchar(255), 
@6                varchar(255), 
@7                varchar(255), 
@8                varchar(255), 
@9                varchar(255)
 
--write down here the location for each server
--PDC means Primary data center
--PDC means Secondary data center
--copy and past the result of this query with the right data center locations
select case 
when row_number() over(order by group_name) = 1 then 'insert into @server_location values ('+''''+group_name+''''+', '+''''+replica_server_name+''''+', ''PRIMARY'',''PDC'')'
else 'insert into @server_location values ('+''''+group_name+''''+', '+''''+replica_server_name+''''+', ''SECONDARY'',''PDC'')'
end
from sys.dm_hadr_availability_replica_cluster_nodes
 
--Here
 
 
--
 
insert into @DCLocation
select role_desc, location_desc
from @server_location
where role_desc = 'PRIMARY'
union 
select role_desc, location_desc
from @server_location
where location_desc not in (select location_desc
from @server_location
where role_desc = 'PRIMARY')
 
declare ag_cursor cursor fast_forward
for
select 
ag_name, [1],[2],[3],[4],[5],[6],[7],[8],[9]
from (
select top 100 percent
row_number() over(partition by a.ag_name order by a.ag_name, is_local desc, synchronization_state_desc, replica_server_name) id,
a.ag_name, replica_server_name 
from (
select ag.name ag_name, rcs.replica_server_name, synchronization_state_desc, dbrs.is_local, role_desc, connected_state_desc, rs.synchronization_health_desc 
from sys.dm_hadr_database_replica_states dbrs inner join sys.availability_groups ag
on dbrs.group_id = ag.group_id
inner join sys.dm_hadr_availability_replica_states  rs
on dbrs.replica_id = rs.replica_id
inner join sys.dm_hadr_availability_replica_cluster_states rcs
on rcs.replica_id = rs.replica_id
group by ag.name, synchronization_state_desc, dbrs.is_local, role_desc, connected_state_desc, rs.synchronization_health_desc, rcs.replica_server_name)a
inner join @server_location sl
on a.replica_server_name = sl.server_name
where connected_state_desc = 'CONNECTED'
and synchronization_health_desc = 'HEALTHY'
order by a.ag_name, sl.server_id)b
pivot
(max(replica_server_name) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9]))p
select @port = ls.port 
from sys.dm_tcp_listener_states ls inner join sys.availability_group_listener_ip_addresses ipa
on ls.ip_address = ipa.ip_address
 
open ag_cursor
fetch next from ag_cursor into @ag_name, @1,@2,@3,@4,@5,@6,@7,@8,@9
while @@FETCH_STATUS = 0
begin
select @replicas =
case when @1 is not null then 1 else 0 end +
case when @2 is not null then 1 else 0 end +
case when @3 is not null then 1 else 0 end +
case when @4 is not null then 1 else 0 end +
case when @5 is not null then 1 else 0 end +
case when @6 is not null then 1 else 0 end +
case when @7 is not null then 1 else 0 end +
case when @8 is not null then 1 else 0 end +
case when @9 is not null then 1 else 0 end
while @loop < @replicas
begin
set @loop += 1
select @replica_server = value 
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,''),',')
where id = @loop
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = '+case @allowConn when 'AppIntent' then 'READ_ONLY' when 'Yes' then 'ALL' end+'));'
print(@sql)
end
set @loop = 0
while @loop < @replicas
begin
set @loop += 1
select @replica_server = value 
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,''),',')
where id = @loop
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N''TCP://'+case when charindex('\',@replica_server) > 0 then substring(@replica_server,1,charindex('\',@replica_server)-1) else @replica_server end+':'+@port+'''));'
print(@sql)
end
set @loop = 0
while @loop < @replicas
begin
set @loop += 1
 
select @dc_role = dc.role_desc 
from @server_location sl inner join @DCLocation dc 
on sl.location_desc = dc.location_desc
where server_id = @loop
 
select @replica_server = value 
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,''),',')
where id = @loop
set @read_only_routing_list = null
 
select @read_only_routing_list = ISNULL(@read_only_routing_list+',','') + case 
when @balance_sync_type = 'report' and @load_balncing = 1 and load_predicate_id > 0 and load_predicate_id = 1 then '(' 
else '' end+''''+value+''''+case 
when @balance_sync_type = 'report' and @load_balncing = 1 and load_predicate_id > 0 and load_predicate_id = max(load_predicate_id) over() then ')'
else '' end
from (
select loc_order, value, load_predicate, case when load_predicate = 0 then 0 else row_number() over(partition by load_predicate order by loc_order) end load_predicate_id
from (
select
loc_order, value, case when location_desc = FIRST_VALUE(location_desc) over(order by loc_order) and count(*) over(partition by location_desc) > 1 then 1 else 0 end load_predicate 
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,'')
,',') s inner join (select sl.*, row_number() over(order by case 
when @balance_sync_type = 'report' and dc.location_desc = 'PDC' and @dc_role = 'PRIMARY' then 0
when @balance_sync_type = 'report' and dc.location_desc = 'SDC' and @dc_role = 'PRIMARY' then 1
when @balance_sync_type = 'report' and dc.location_desc = 'PDC' and @dc_role = 'SECONDARY' then 1
when @balance_sync_type = 'report' and dc.location_desc = 'SDC' and @dc_role = 'SECONDARY' then 0
end desc)loc_order 
from @server_location sl inner join @DCLocation dc
on sl.location_desc = dc.location_desc) lo 
on s.value = lo.server_name
and id != @loop)a)b
order by loc_order
 
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('+@READ_ONLY_ROUTING_LIST+')));'
print(@sql)
end
set @loop = 0
fetch next from ag_cursor into @ag_name, @1,@2,@3,@4,@5,@6,@7,@8,@9
end 
close ag_cursor
deallocate ag_cursor
