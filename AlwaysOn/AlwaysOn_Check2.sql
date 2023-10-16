select 
connectionproperty('local_net_address') Server_IP, 
isnull(SERVERPROPERTY('InstanceName'),'MSSQLSERVER') instance_name,
SERVERPROPERTY('ServerName') Server_Name,
group_name, Node_no, location, 
case 
when Node_no != 'Node 01' and location = 'PDC' and role_desc = 'PRIMARY' then 'Failover - Secondary' 
when Node_no != 'Node 01' and location = 'SDC' and role_desc = 'PRIMARY' then 'Failover - DR' 
else 'N/A' end Need_action, 
replica_server_name, role_desc, operational_state_desc, connected_state_desc, recovery_health_desc, 
synchronization_health_desc, join_state_desc, last_connect_error_description, last_connect_error_timestamp
from (
select group_name, 
case 
when group_name = 'T24_XIO' then  -- 2 DC 1,2 - 4 Nodes (4,5,4,5)
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 4 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 5 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 4 then 'Node 03' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 5 then 'Node 04' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 4 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 5 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 4 then 'Node 03' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 5 then 'Node 04' 
			end
	end
	when group_name = 'ENJ_API_AG' then  -- 2 DC 1,2 - 4 Nodes (3,4,3,4)
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 3 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 4 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 3 then 'Node 03' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 4 then 'Node 04' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 3 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 4 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 3 then 'Node 03' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 4 then 'Node 04' 
			end
	end
when group_name = 'CRM_AG' then  -- 2 DC 1,2 - 3 Nodes (1,2,1)
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 2 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 03' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 2 then 'Node 02' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 1 then 'Node 03' 
			end
	end
when group_name in ('testskelta','APG_HAG','RMB_KONY_AG','DH_AG','BAB_NET_AG','ims_abic','iCorp_AG','EFAT_AG') then  -- 2 DC 1,2 - 2 Nodes (1,1) 
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 02' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 1 then 'Node 02' 
			end
	end
when group_name in ('KonyAG') then  -- 2 DC 1,2 - 2 Nodes (3,3) 
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 3 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 3 then 'Node 02' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 1 then 'Node 02' 
			end
	end
when group_name in ('APTRA_AG') then  -- 2 DC 1,2 - 2 Nodes (1,3)
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 3 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 02' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 3 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 2 and right(rcs.replica_server_name,1) = 1 then 'Node 02' 
			end
	end
when group_name in ('AG_Kony') then  -- 1 DC 1 - 4 Nodes (1,2)
	case 
		when charindex('\',rcs.replica_server_name) > 0 then
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(substring(rcs.replica_server_name,1,charindex('\',rcs.replica_server_name)-1),1) = 2 then 'Node 02' 
			end
		else
			case 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 1 then 'Node 01' 
				when substring(rcs.replica_server_name, 2,1) = 1 and right(rcs.replica_server_name,1) = 2 then 'Node 02' 
			end
	end
end 
Node_no,  
case substring(rcs.replica_server_name, 2,1) when 1 then 'PDC' else 'SDC' end location,  
rcs.replica_server_name, role_desc, rs.operational_state_desc, connected_state_desc, recovery_health_desc, synchronization_health_desc, join_state_desc, last_connect_error_description, last_connect_error_timestamp
from sys.dm_hadr_availability_replica_cluster_states rcs inner join sys.dm_hadr_availability_replica_states rs
on rcs.replica_id = rs.replica_id
inner join sys.dm_hadr_availability_replica_cluster_nodes rcn
on rcs.replica_server_name = rcn.replica_server_name
--where is_local = 1
)a

