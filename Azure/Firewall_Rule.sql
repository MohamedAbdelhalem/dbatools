--how to configure a specific database to be allowed with 0.0.0.0 or one IP
--okay first sys.firewall_rules is for all instance
select * from sys.firewall_rules
order by create_date desc
--try to use this view sys.database_firewall_rules
select * from sys.database_firewall_rules

--okay lets check the server firewall rule and drop all rules except the current
--so we will search on the rule by query my IP by using the below two methods
select client_net_address from sys.dm_exec_connections where session_id = @@spid
--or
select connectionproperty('client_net_address')
--then lets search on the rule
select * 
from sys.firewall_rules
where start_ip_address = connectionproperty('client_net_address')
--then lets drop all except main
select 'exec [sp_delete_firewall_rule] N'+''''+name+''''
from sys.firewall_rules
where id != 1
and start_ip_address != connectionproperty('client_net_address')
--exec [sp_delete_firewall_rule] N'ClientIp-2024-4-27_13-35-56'
--exec [sp_delete_firewall_rule] N'ClientIPAddress_2024-05-09_02:58:59'
--exec [sp_delete_firewall_rule] N'ClientIPAddress_2024-5-15_15-2-43'
--exec [sp_delete_firewall_rule] N'ClientIPAddress_2024-5-9_18-4-35'

--then alter the current rule and give it all IP range
select 'exec [sp_set_firewall_rule] @name = N'+''''+name+''''+', @start_ip_address = ''0.0.0.0'', @end_ip_address =''255.255.255.255'''
from sys.firewall_rules
where start_ip_address = connectionproperty('client_net_address')

--exec [sp_set_firewall_rule] @name = N'ClientIPAddress_2024-07-27_12:17:01', @start_ip_address = '0.0.0.0', @end_ip_address ='255.255.255.255'

select *
from sys.firewall_rules

