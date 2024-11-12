select replica_id, replica_server_name, ag.name ag_name,[READ_ONLY_ROUTING_LIST],
'ALTER AVAILABILITY GROUP ['+ag.name+'] MODIFY REPLICA ON N'+''''+replica_server_name+''''+' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST='+[READ_ONLY_ROUTING_LIST]+'));' [READ_ONLY_ROUTING_EXIST],
'ALTER AVAILABILITY GROUP ['+ag.name+'] MODIFY REPLICA ON N'+''''+replica_server_name+''''+' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=NONE));' [REMOVE_EXIST_READ_ONLY_ROUTING]
from (
select replica_id, replica_server_name, group_id, '(' +
isnull([1],    '') + isnull(','+[2],'') + isnull(','+[3],'') + isnull(','+[4],'') + 
isnull(','+[5],'') + isnull(','+[6],'') + isnull(','+[7],'') + isnull(','+[8],'') + isnull(','+[9],'') + 
isnull(','+[10],'') + isnull(','+[11],'') + isnull(','+[12],'') + isnull(','+[13],'') + ')' [READ_ONLY_ROUTING_LIST]
from (
select replica_id, replica_server_name, routing_priority, group_id,
case when [2] is not null then '(' else '' end + 
isnull(''''+[1]+'''',    '') + isnull(','+''''+[2]+'''','') + isnull(','+''''+[3]+'''','') + isnull(','+''''+[4]+'''','') + 
isnull(','+''''+[5]+'''','') + isnull(','+''''+[6]+'''','') + isnull(','+''''+[7]+'''','') + isnull(','+''''+[8]+'''','') + isnull(','+''''+[9]+'''','') + 
isnull(','+''''+[10]+'''','') + isnull(','+''''+[11]+'''','') + isnull(','+''''+[12],'') + isnull(','+''''+[13]+'''','') + case when [2] is not null then ')' else '' end [READ_ONLY_ROUTING_LIST]
from (
select 
dense_rank()over(order by ar1.replica_server_name) replica_id, 
ar1.replica_server_name, ar1.group_id,
row_number()over(partition by ar1.replica_server_name,ro.routing_priority order by ar1.replica_server_name, ro.routing_priority) id, 
ro.routing_priority, ar2.replica_server_name [READ_ONLY_ROUTING_LIST]
from sys.availability_read_only_routing_lists ro 
inner join sys.availability_replicas ar1
on ro.replica_id = ar1.replica_id
inner join sys.availability_replicas ar2
on ro.read_only_replica_id = ar2.replica_id
)a
pivot(
max([READ_ONLY_ROUTING_LIST]) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13]))p1
)b
pivot(
max([READ_ONLY_ROUTING_LIST]) for routing_priority in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13]))p2
)c 
inner join sys.availability_groups ag
on c.group_id = ag.group_id
order by replica_id
