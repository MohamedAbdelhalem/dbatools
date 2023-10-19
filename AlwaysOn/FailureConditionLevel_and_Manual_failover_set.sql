declare 
@ag_name					varchar(255), 
@failure_condition_level	int,
@role						int,
@replica_server_name		varchar(1000),
@sql						varchar(1000)

declare ag_cursor cursor fast_forward
for
select name, failure_condition_level , role
from sys.dm_hadr_availability_replica_states rs inner join sys.availability_groups_cluster agc
on rs.group_id = agc.group_id
where is_local = 1

declare replica_cursor cursor fast_forward
for
select distinct replica_server_name
from sys.availability_replicas
where failover_mode_desc = 'AUTOMATIC'
--AUTOMATIC
--MANUAL

open ag_cursor
fetch next from ag_cursor into @ag_name, @failure_condition_level, @role
while @@FETCH_STATUS = 0
begin

if @role = 1
begin

set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] SET (FAILURE_CONDITION_LEVEL = '+cast(case @failure_condition_level when 1 then 3 when 3 then 1 end as varchar(10))+')'
exec(@sql)
print(@sql)

		open replica_cursor 
		fetch next from replica_cursor into @replica_server_name
		while @@FETCH_STATUS = 0
		begin
			if @role = 1
			begin
				set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_name+'] MODIFY REPLICA ON '+''''+@replica_server_name+''''+' WITH (FAILOVER_MODE = MANUAL)'
				exec(@sql)
				print(@sql)
			end
		fetch next from replica_cursor into @replica_server_name
		end
		close replica_cursor
end
fetch next from ag_cursor into @ag_name, @failure_condition_level, @role
end
close ag_cursor 
deallocate ag_cursor 
deallocate replica_cursor

