select ar1.replica_server_name IF_Replica_is_Primary, ro.routing_priority, ar2.replica_server_name [READ_ONLY_ROUTING_LIST]
from sys.availability_read_only_routing_lists ro 
inner join sys.availability_replicas ar1
on ro.replica_id = ar1.replica_id
inner join sys.availability_replicas ar2
on ro.read_only_replica_id = ar2.replica_id
order by IF_Replica_is_Primary, routing_priority
