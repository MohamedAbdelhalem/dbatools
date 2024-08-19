Select rs.replica_server_name, r.role_desc,
count(*) over(partition by rs.replica_server_name order by rs.replica_server_name) db_count_per_replica, 
sum(s.is_failover_ready) over(partition by rs.replica_server_name order by rs.replica_server_name), 
case when count(*) over(partition by rs.replica_server_name order by rs.replica_server_name) != 
sum(s.is_failover_ready) over(partition by rs.replica_server_name order by rs.replica_server_name) then 0 else 1 end is_failover_ready, 
s.is_failover_ready  
From sys.dm_hadr_database_replica_cluster_states s 
inner join sys.dm_hadr_availability_replica_states r on s.replica_id = r.replica_id 
inner join sys.dm_hadr_availability_replica_cluster_states rs on rs.replica_id = s.replica_id 

