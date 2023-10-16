declare @table table (replica_id_rank int, database_id int, replica_server_name varchar(255), role_desc varchar(100), last_commit_time datetime)
declare @table2 table (database_name varchar(355), replica_id_rank int, database_id int, replica_server_name varchar(255), role_desc varchar(100), last_commit_time datetime, milliseconds bigint, Data_Lost_duration varchar(50))

insert into @table
select DENSE_RANK() over(order by ars.role, ar.replica_server_name) replica_id_rank, dbrs.database_id, ar.replica_server_name, ars.role_desc, dbrs.last_commit_time
from  master.sys.dm_hadr_database_replica_states dbrs inner join sys.dm_hadr_availability_replica_states ars
on dbrs.replica_id = ars.replica_id
inner join sys.availability_replicas ar
on dbrs.replica_id = ar.replica_id
order by replica_id_rank

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
----where db.name = 'PRODmfaccountsdbBAB'

declare @db_id int
declare db_cursor cursor fast_forward
for
select distinct database_id from @table-- where database_id = 8

open db_cursor
fetch next from db_cursor into @db_id
while @@FETCH_STATUS = 0
begin

--LAG(last_commit_time,replica_id_rank - 1, (replica_id_rank - 1) * -1)
--replica_id_rank will give you based on who is the primary node and to get the last_commit_time and compare it with all secondaries so, 2th parameter of LAG is replica_id_rank - 1 = 0,1,2,3 and 3th parameter is (replica_id_rank - 1) * -1 = 0,-1,-2,-3
insert into @table2
select db.name, b.*, 
datediff(ms, last_commit_time, LAG(last_commit_time,replica_id_rank - 1, (replica_id_rank - 1) * -1) over(order by replica_id_rank)) milliseconds,
master.dbo.duration('ms', datediff(ms, last_commit_time, LAG(last_commit_time,replica_id_rank - 1, (replica_id_rank - 1) * -1) over(order by replica_id_rank))) Data_Lost_duration
from @table b
inner join sys.databases db
on b.database_id = db.database_id
where db.name = db_name(@db_id)

fetch next from db_cursor into @db_id
end
close db_cursor
deallocate db_cursor

select * from @table2
order by database_id, replica_id_rank
