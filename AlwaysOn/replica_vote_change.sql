declare 
@set_vote_on_pdc	int = 1,
--1 primary site
--2 Secondary site
--3 all primary and Secondary sites
@action				int = 1,
--1 = print
--2 = execute
--3 = print + execute
@is_auto			int = 0
--1 = using your pattern
--0 = manual as it's added below on the @replicas table

set nocount on
--Manual entry AG replicas----------------------------------------
declare @replicas table (replica_server_name varchar(255), nodeWeight varchar(5))
insert into @replicas values 
('SQLSERVERprdwv100',1),
('productionSQLwv199',1),
('productionSQLDRwv12441',0),
('SQLDRwv2545',0),
('colleSQLPwv745',1)
-- for the above part you can use it if you have servers names without pattern or name convention,
--e.g. 
--node 1 = SQLSERVERprdwv100   (primary DC)
--node 2 = productionSQLwv199   (primary DC)
--node 3 = productionSQLDRwv12441  (secondary DC)
--node 4 = SQLDRwv2545  (secondary DC)
--node 5 = colleSQLPwv745 (primary DC)
----------------------------------------------------------------------
declare @replica_server_name varchar(255), @nodeWeight varchar(5), @powershell varchar(max)

if @is_auto = 1
begin
	delete from @replicas
	insert @replicas
	select replica_server_name , case											--put your logic here, for me i'm cutting out from the server the first 2 digits
	when @set_vote_on_pdc = 1 and LEFT(replica_server_name,2) = 'D1' then 1		--D1 = data center 1 (primary)
	when @set_vote_on_pdc = 2 and LEFT(replica_server_name,2) = 'D2' then 1		--D2 = data center 2 disaster recovery site
	when @set_vote_on_pdc = 3 then 1											--and here if you need to set vote on all replicas like you have only 3 nodes and using node majority odd numbers 3, 5 , or 7 nodes :-) too much
	else 0 end nodeWeight
	from sys.dm_hadr_availability_replica_cluster_states
	order by nodeWeight desc 
end

declare replicas_vote cursor fast_forward
for
select replica_server_name, nodeWeight
from @replicas
order by nodeWeight desc 

open replicas_vote
fetch next from replicas_vote into @replica_server_name, @nodeWeight
while @@FETCH_STATUS = 0
begin
if @action = 1
begin
	set @powershell = 'xp_cmdshell ''powershell.exe -Command "& {(get-ClusterNode '+@replica_server_name+').NodeWeight='+@NodeWeight+'}"'''
	print(@powershell)
end
else
if @action = 1
begin
	exec(@powershell)
end
else
if @action = 1
begin
	set @powershell = 'xp_cmdshell ''powershell.exe -Command "& {(get-ClusterNode '+@replica_server_name+').NodeWeight='+@NodeWeight+'}"'''
	exec(@powershell)
	print(@powershell)
end

fetch next from replicas_vote into @replica_server_name, @nodeWeight
end
close replicas_vote 
deallocate replicas_vote 
set nocount off
