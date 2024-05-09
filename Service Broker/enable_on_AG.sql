use master
go
CREATE ENDPOINT [SSBEndpoint] 
STATE = STARTED 
AS TCP  (LISTENER_PORT = 4022, LISTENER_IP = ALL ) 
FOR SERVICE_BROKER (AUTHENTICATION = WINDOWS)
go
GRANT CONNECT ON ENDPOINT::[SSBEndpoint] TO [PUBLIC] 
go
use [AdventureWorks2016]
go
alter database [adventureworks2016] set enable_broker with no_wait
go
ALTER ROUTE AutoCreatedLocal WITH ADDRESS = 'TCP://[server]:4022'  ;

