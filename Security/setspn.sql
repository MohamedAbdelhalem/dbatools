declare 
@service_account	varchar(200),
@FQDN				varchar(100),
@port				varchar(10)

select @port = port 
from sys.dm_tcp_listener_states
where ip_address = '0.0.0.0'

select @service_account = case 
when 
service_account like '%@%' and service_account not like '%.%'
then 
substring(service_account, charindex('@',service_account)+1,len(service_account))+'\'+substring(service_account, 1, charindex('@',service_account)-1)
when 
service_account like '%@%' and service_account like '%.%'
then 
substring(substring(service_account, charindex('@',service_account)+1,len(service_account)),1,charindex('.',substring(service_account, charindex('@',service_account)+1,len(service_account)))-1)
+'\'+substring(service_account, 1, charindex('@',service_account)-1)
else
service_account
end
from sys.dm_server_services
where servicename like 'SQL Server (%'

exec xp_regread
@rootkey = 'HKEY_LOCAL_MACHINE',
@key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\',
@value_name = 'Domain',
@value = @FQDN output

select 'setspn -S MSSQLSvc/'+case when charindex('\',name) > 0 then substring(name, 1, charindex('\',name)-1) else name end+'.'+@FQDN+ case when charindex('\',name) > 0 then ':'+substring(name, charindex('\',name)+1, len(name)) else '' end+' '+upper(@service_account)
from sys.servers
where server_id = 0
union
select 'setspn -S MSSQLSvc/'+case when charindex('\',name) > 0 then substring(name, 1, charindex('\',name)-1) else name end+'.'+@FQDN+':'+@port+' '+upper(@service_account)
from sys.servers
where server_id = 0

