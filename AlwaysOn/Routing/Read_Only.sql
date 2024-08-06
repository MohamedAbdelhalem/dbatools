declare 
@load_balncing      bit = 1,
@balance_sync_type    varchar(100) = 'Async',
@allowConn        varchar(100) = 'Yes', --'AppIntent' = 'READ_ONLY', 'Yes' = 'ALL'
@port          varchar(10),
@sql          varchar(max),
@loop          int = 0,
@loop2          int = 0,
@replicas        int,
@ag_name        varchar(255),
@replica_server      varchar(255),
@READ_ONLY_ROUTING_LIST varchar(max),
@1 varchar(255), 
@2 varchar(255), 
@3 varchar(255), 
@4 varchar(255), 
@5 varchar(255), 
@6 varchar(255), 
@7 varchar(255), 
@8 varchar(255), 
@9 varchar(255)
 
declare ag_cursor cursor fast_forward
for
select 
ag_name, [1],[2],[3],[4],[5],[6],[7],[8],[9]
from (
select top 100 percent
row_number() over(partition by ag_name order by ag_name, is_local desc, synchronization_state_desc, replica_server_name) id,
ag_name, replica_server_name 
--role_desc, synchronization_state_desc, is_local, 
from (
select ag.name ag_name, rcs.replica_server_name, synchronization_state_desc, dbrs.is_local, role_desc, connected_state_desc, rs.synchronization_health_desc 
from sys.dm_hadr_database_replica_states dbrs inner join sys.availability_groups ag
on dbrs.group_id = ag.group_id
inner join sys.dm_hadr_availability_replica_states  rs
on dbrs.replica_id = rs.replica_id
inner join sys.dm_hadr_availability_replica_cluster_states rcs
on rcs.replica_id = rs.replica_id
group by ag.name, synchronization_state_desc, dbrs.is_local, role_desc, connected_state_desc, rs.synchronization_health_desc, rcs.replica_server_name)a
where connected_state_desc = 'CONNECTED'
and synchronization_health_desc = 'HEALTHY'
order by ag_name, is_local desc, synchronization_state_desc)b
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
isnull(    @1,'')+
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
isnull(    @1,'')+
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
select @replica_server = value 
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,''),',')
where id = @loop
 
set @READ_ONLY_ROUTING_LIST = null
select @READ_ONLY_ROUTING_LIST = ISNULL(@READ_ONLY_ROUTING_LIST+',','') + ''''+value+''''
from master.dbo.Separator(
isnull(    @1,'')+
isnull(','+@2,'')+
isnull(','+@3,'')+
isnull(','+@4,'')+
isnull(','+@5,'')+
isnull(','+@6,'')+
isnull(','+@7,'')+
isnull(','+@8,'')+
isnull(','+@9,''),',')
where id != @loop
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('+case @load_balncing when 1 then '(' else '' end+@READ_ONLY_ROUTING_LIST+')'+case @load_balncing when 1 then ')' else '' end+'));'
print(@sql)
end
 
set @loop = 0
 
fetch next from ag_cursor into @ag_name, @1,@2,@3,@4,@5,@6,@7,@8,@9
end 
close ag_cursor
deallocate ag_cursor
