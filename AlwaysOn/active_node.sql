select ag.name [availability_group], role, role_desc, avgs.primary_replica
from sys.dm_hadr_availability_replica_states avrs inner join sys.availability_groups ag
on avrs.group_id = ag.group_id
inner join sys.dm_hadr_availability_group_states avgs
on avgs.group_id = ag.group_id
where is_local = 1
