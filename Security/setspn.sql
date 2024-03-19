declare 
@service_account	varchar(200),
@FQDN				varchar(100)

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

select 'setspn -s MSSQLSvc/'+name+'.'+@FQDN+' '+@service_account
from sys.servers
where server_id = 0
union
select 'setspn -s MSSQLSvc/'+name+'.'+@FQDN+':'+substring(name, charindex('\',name)+1, len(name))+' '+@service_account
from sys.servers
where server_id = 0
and charindex('\',name) > 0
