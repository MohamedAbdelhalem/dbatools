select 
session_id, ep.is_admin_endpoint, l.ip_address listener_address, c.client_net_address, c.local_net_address, 
l.port, net_transport, c.endpoint_id, ep.name, encrypt_option, auth_scheme, p.program_name, p.hostname
from sys.dm_exec_connections c inner join sys.sysprocesses p
on c.session_id = p.spid
inner join sys.endpoints ep
on c.endpoint_id = ep.endpoint_id
left outer join sys.dm_tcp_listener_states l
on l.ip_address = c.local_net_address
and l.port = c.local_tcp_port
