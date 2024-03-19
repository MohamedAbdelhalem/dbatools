
--setspn -s MSSQLSvc/PGD-SQL-DB1.pgd.gov.sa PGD\deesrv
--setspn -s MSSQLSvc/PGD-SQL-DB1 PGD\deesrv

--setspn -s MSSQLSvc/PGD-SQL-DB2.pgd.gov.sa PGD\deesrv
--setspn -s MSSQLSvc/PGD-SQL-DB2 PGD\deesrv

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

select 'setspn -s MSSQLSvc/'+name+'.'+@FQDN+' '+@service_account
from sys.servers
where server_id = 0
union
select 'setspn -s MSSQLSvc/'+name+'.'+@FQDN+':'+@port+' '+@service_account
from sys.servers
where server_id = 0
union
select 'setspn -s MSSQLSvc/'+name+'.'+@FQDN+':'+substring(name, charindex('\',name)+1, len(name))+' '+@service_account
from sys.servers
where server_id = 0
and charindex('\',name) > 0
