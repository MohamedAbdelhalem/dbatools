BACKUP DATABASE [test] TO  DISK = N'S:\Backup\test.bak' WITH NOFORMAT, NOINIT,  NAME = N'test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP log [test] TO  DISK = N'S:\Backup\test.bak' WITH NOFORMAT, NOINIT,  NAME = N'test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
CREATE ENDPOINT mirror_endpoint STATE=STARTED AS TCP (LISTENER_PORT=5022) FOR DATABASE_MIRRORING (ROLE=ALL);  
GO  
ALTER server Role [sysadmin] add member [ALBILAD\gMSA_SS_DBAPRD$]
GO
--useless if you have the service account on the sysadmin server role
GRANT CONNECT ON ENDPOINT::mirror_endpoint TO [ALBILAD\gMSA_SS_DBAPRD$];  
GO
--create availability group one node
CREATE AVAILABILITY GROUP AG_Test_01   
FOR   
DATABASE Test
REPLICA ON   
'D1RACDBSQPWV1\DC1PRODTST' WITH   
(
ENDPOINT_URL = 'TCP://D1RACDBSQPWV1.albilad.com:5022',
AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,  
FAILOVER_MODE = MANUAL  
)
GO

ALTER AVAILABILITY GROUP [AG_Test_01]
ADD LISTENER N'VPRACDNS_P004' (
WITH IP
((N'10.5.2.95', N'255.255.255.0')
)
, PORT=1433);
GO
