select 
Server_Name, instance_name, Node_no, 
case 
when Node_no != 'Node 01' and location = 'PDC' and role_desc = 'PRIMARY' then 'Failover - Secondary' 
when Node_no != 'Node 01' and location = 'SDC' and role_desc = 'PRIMARY' then 'Failover - DR' 
else 'N/A' end Need_action, 
db.user_databases, ag.Databases_under_AG, ag.synchronization_state_desc,
group_name, location, 
role_desc, operational_state_desc, connected_state_desc, recovery_health_desc, 
synchronization_health_desc, last_connect_error_description, last_connect_error_timestamp
from (
select 
SERVERPROPERTY('ServerName') Server_Name,
isnull(SERVERPROPERTY('InstanceName'),'MSSQLSERVER') instance_name,
case 
when group_name = 'T24_XIO' then  -- 2 DC 1,2 - 4 Nodes (4,5,4,5)
 		case 
			when substring(server_name, 2,1) = 1 and right(server_name,1) = 4 then 'Node 01' 
			when substring(server_name, 2,1) = 1 and right(server_name,1) = 5 then 'Node 02' 
			when substring(server_name, 2,1) = 2 and right(server_name,1) = 4 then 'Node 03' 
			when substring(server_name, 2,1) = 2 and right(server_name,1) = 5 then 'Node 04' 
		end
	when group_name = 'ENJ_API_AG' then  -- 2 DC 1,2 - 4 Nodes (3,4,3,4)
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 3 then 'Node 01' 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 4 then 'Node 02' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 3 then 'Node 03' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 4 then 'Node 04' 
			end
when group_name in ('CRM_AG','SVS_AG','crm_shp') then  -- 2 DC 1,2 - 3 Nodes (1,2,1)
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 1 then 'Node 01' 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 2 then 'Node 02' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 1 then 'Node 03' 
			end

when group_name in ('testskelta','APG_HAG','RMB_KONY_AG','BAB_NET_AG','ims_abic','iCorp_AG','EFAT_AG','VPPAMDNS_P002') then  -- 2 DC 1,2 - 2 Nodes (1,1) 
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 1 then 'Node 01' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 1 then 'Node 02' 
			end
when group_name in ('KonyAG','ONEDRV1','DH_AG') then  -- 2 DC 1,2 - 2 Nodes (3,3) 
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 1 then 'Node 01' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 1 then 'Node 02' 
			end
when group_name in ('APTRA_AG') then  -- 2 DC 1,2 - 2 Nodes (1,3)
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 3 then 'Node 01' 
				when substring(server_name, 2,1) = 2 and right(server_name,1) = 1 then 'Node 02' 
			end
when group_name in ('AG_Kony') then  -- 1 DC 1 - 4 Nodes (1,2)
			case 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 1 then 'Node 01' 
				when substring(server_name, 2,1) = 1 and right(server_name,1) = 2 then 'Node 02' 
			end
end 
Node_no,  
group_name, location, 
role_desc, operational_state_desc, connected_state_desc, recovery_health_desc, 
synchronization_health_desc, last_connect_error_description, last_connect_error_timestamp
from (
select 
isnull(SERVERPROPERTY('InstanceName'),'MSSQLSERVER') instance_name,
case 
substring(cast(SERVERPROPERTY('ServerName') as varchar(1000)), 2,1) when 1 then 'PDC' else 'SDC' end location,  
case 
when charindex('\',cast(SERVERPROPERTY('ServerName') as varchar(1000))) > 0 then substring(cast(SERVERPROPERTY('ServerName') as varchar(1000)), 1, charindex('\',cast(SERVERPROPERTY('ServerName') as varchar(1000)))-1) 
else cast(SERVERPROPERTY('ServerName') as varchar(1000)) end Server_Name,
name group_name, replica_id, role_desc, isnull(operational_state_desc,'OFFLINE') operational_state_desc, connected_state_desc, isnull(recovery_health_desc,'OFFLINE')recovery_health_desc, synchronization_health_desc, last_connect_error_number, last_connect_error_description, last_connect_error_timestamp 
from sys.availability_groups g inner join sys.dm_hadr_availability_replica_states rs 
on g.group_id = rs.group_id 
where is_local = 1)a)b 
cross apply (select count(*) Databases_under_AG, synchronization_state_desc from sys.dm_hadr_database_replica_states  where is_local = 1 group by synchronization_state_desc) ag
cross apply (select count(*) user_databases from sys.databases where database_id > 4) db

