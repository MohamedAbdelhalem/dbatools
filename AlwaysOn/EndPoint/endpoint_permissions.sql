--grant
select ep.endpoint_id, ep.name, ep.state_desc, sp.class_desc, sp.grantee_principal_id, spr.name, 
sp.permission_name, sp.state_desc, ep.protocol_desc,
sp.state_desc+' '+[permission_name]+' ON '+class_desc+'::['+ep.name+'] TO [' collate Latin1_General_CI_AS+spr.name+']' permission_script
from sys.endpoints ep left outer join sys.server_permissions sp 
on sp.major_id = ep.endpoint_id
left outer join sys.server_principals spr
on sp.grantee_principal_id = spr.principal_id
where ep.endpoint_id > 5
