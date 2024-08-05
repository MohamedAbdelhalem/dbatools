--create table replicas (replica_server_name varchar(255), ag_name varchar(355), sync_desc varchar(100), role_desc varchar(100))
--insert into replicas values ('DBAASAG3', 'ERPAGLIST', 'synchronizing', 'SECONDARY')
--insert into replicas values ('DBAASAG1', 'ERPAGLIST', 'synchronized',  'PRIMARY')
--insert into replicas values ('DBAASAG2', 'ERPAGLIST', 'synchronized',  'SECONDARY')
--insert into replicas values ('DBAASAG3', 'SAPAG', 'synchronizing', 'SECONDARY')
--insert into replicas values ('DBAASAG1', 'SAPAG', 'synchronized',  'PRIMARY')
--insert into replicas values ('DBAASAG2', 'SAPAG', 'synchronizing', 'SECONDARY')

--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG1' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG2' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG3' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));


--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG1' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://DBAASAG1:1433'));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG2' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://DBAASAG2:1433'));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG3' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://DBAASAG3:1433'));

--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG1' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('DBAASAG2','DBAASAG3'))));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG2' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('DBAASAG1','DBAASAG2'))));
--ALTER AVAILABILITY GROUP SAPAG MODIFY REPLICA ON N'DBAASAG3' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('DBAASAG1','DBAASAG2'))))

declare 
@load_balncing			bit = 1,
@sql					varchar(max),
@loop					int = 0,
@loop2					int = 0,
@replicas				int,
@ag_name				varchar(255),
@replica_server			varchar(255),
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
select ag_name, [1],[2],[3],[4],[5],[6],[7],[8],[9]
from (
select top 100 percent
row_number() over(partition by ag_name order by ag_name, role_state, sync_state, replica_server_name) id,
replica_server_name, ag_name
from (
select
replica_server_name, ag_name, 
case role_desc when 'PRIMARY' then 1 else 2 end role_state, 
case sync_desc when 'synchronized' then 1 when 'synchronizing' then 2 end sync_state
from replicas)a
order by ag_name, role_state, sync_state, replica_server_name)b
pivot (
max(replica_server_name) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9]))p

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

set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));'
print(@sql)
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N''TCP://'+@replica_server+':1433''));'
print(@sql)
set @READ_ONLY_ROUTING_LIST = null
select @READ_ONLY_ROUTING_LIST = ISNULL(@READ_ONLY_ROUTING_LIST+',','') + ''''+value+''''
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
where id != @loop
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON N'+''''+@replica_server+''''+' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('+case @load_balncing when 1 then '(' else '' end+@READ_ONLY_ROUTING_LIST+')'+case @load_balncing when 1 then ')' else '' end+'));'
print(@sql)
end
set @loop = 0
fetch next from ag_cursor into @ag_name, @1,@2,@3,@4,@5,@6,@7,@8,@9
end 
close ag_cursor
deallocate ag_cursor
