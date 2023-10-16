declare @table table (replica_id_rank int, database_id int, replica_server_name varchar(255), role_desc varchar(100), last_commit_time datetime)

insert into @table
select DENSE_RANK() over(order by ars.role, ar.replica_server_name) replica_id_rank, dbrs.database_id, ar.replica_server_name, ars.role_desc, dbrs.last_commit_time
from  master.sys.dm_hadr_database_replica_states dbrs inner join sys.dm_hadr_availability_replica_states ars
on dbrs.replica_id = ars.replica_id
inner join sys.availability_replicas ar
on dbrs.replica_id = ar.replica_id
order by replica_id_rank

insert into msdb.dbo.Latency_log_AG_v
(database_name, database_id, Primary_node_Latency_ms, Primary_node_Latency, Secondary_node1_Latency_ms, Secondary_node1_Latency, Secondary_node2_Latency_ms, Secondary_node2_Latency, Secondary_node3_Latency_ms, Secondary_node3_Latency)
select 
db.name, b.*
from (
select 
database_id, 
case when datediff(ms,[1],[1]) < 0 then 0 else datediff(ms,[1],[1]) end Primary_node_Latency_ms,
case when datediff(ms,[1],[1]) < 0 then master.dbo.duration('ms',0) else master.dbo.duration('ms',datediff(ms,[1],[1])) end Primary_node_Latency,
case when datediff(ms,[2],[1]) < 0 then 0 else datediff(ms,[2],[1]) end Secondary_node1_Latency_ms,
case when datediff(ms,[2],[1]) < 0 then master.dbo.duration('ms',0) else master.dbo.duration('ms',datediff(ms,[2],[1])) end Secondary_node1_Latency,
case when datediff(ms,[3],[1]) < 0 then 0 else datediff(ms,[3],[1]) end Secondary_node2_Latency_ms,
case when datediff(ms,[3],[1]) < 0 then master.dbo.duration('ms',0) else master.dbo.duration('ms',datediff(ms,[3],[1])) end Secondary_node2_Latency,
case when datediff(ms,[4],[1]) < 0 then 0 else datediff(ms,[4],[1]) end Secondary_node3_Latency_ms,
case when datediff(ms,[4],[1]) < 0 then master.dbo.duration('ms',0) else master.dbo.duration('ms',datediff(ms,[4],[1])) end Secondary_node3_Latency
from (select replica_id_rank, database_id, last_commit_time from @table) a
pivot (
max(last_commit_time) for replica_id_rank in ([1],[2],[3],[4]))p)b
inner join sys.databases db
on b.database_id = db.database_id

