select * from sys.endpoints

select ep.endpoint_id, ep.name, ep.state_desc, sp.class_desc, sp.grantee_principal_id, spr.name, l.sysadmin, 
sp.permission_name, sp.state_desc, ep.protocol_desc,
sp.state_desc+' '+[permission_name]+' ON '+class_desc+'::['+ep.name+'] TO [' collate Latin1_General_CI_AS+spr.name+']' permission_script
from sys.endpoints ep left outer join sys.server_permissions sp 
on sp.major_id = ep.endpoint_id
left outer join sys.server_principals spr
on sp.grantee_principal_id = spr.principal_id
left outer join sys.syslogins l
on spr.name = l.name
where ep.endpoint_id > 5

EXEC xp_readerrorlog 1, 1, N'hadrag';

SELECT * FROM sys.dm_hadr_availability_group_states;


SELECT database_name, is_failover_ready 
FROM sys.dm_hadr_database_replica_cluster_states 
WHERE replica_id IN (SELECT replica_id FROM sys.dm_hadr_availability_replica_states);

ALTER AVAILABILITY GROUP [AG] FORCE_FAILOVER_ALLOW_DATA_LOSS;

ALTER DATABASE [Test] SET HADR RESUME;

