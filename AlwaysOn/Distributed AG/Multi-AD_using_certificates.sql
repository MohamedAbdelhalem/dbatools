USE master;
GO
--we have 4 nodes DB_replica_1, DB_replica_2, DB_replica_3, and DB_replica_4
--on the Primary node on the primary site = (DB_replica_1)

--DB_replica_1
--create a master key if it does't exist
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'd1wu$952KLsut375';
GO
--Create a new certificate if you don't know the exist one or (replace the exist with this one)
CREATE CERTIFICATE [dag_certificate] WITH SUBJECT = 'DAG Cert';
GO
--backup the certificate to create it in all nodes, but first check if the folder exist on the server (DB_replica_1)
exec xp_cmdshell 'dir cd C:\dag_cer'
--if the folder doesn't exist then create it
exec xp_cmdshell 'mkdir "C:\dag_cer"'
GO
--Backup the certificate on DB_replica_1
BACKUP CERTIFICATE [dag_certificate]
TO FILE = 'C:\dag_cer\dag_certificate.cer'
WITH PRIVATE KEY (
FILE = 'C:\dag_cer\dag_certificate.pvk',
ENCRYPTION BY PASSWORD = 'd1wu$952KLsut375')
GO
--it will be better if you make a new separate login for the handshake authuntication between all nodes
CREATE LOGIN [dag_admin] WITH PASSWORD = 'd1wu$952KLsut375';
GO
CREATE USER [dag_admin] FOR LOGIN [dag_admin];
GO
--here is a very important step, you already have an Endpoint [hadr_endpoint] then alter it to use the new certificate, but don't forget to alter it on DB_replica_2 as will
ALTER ENDPOINT [hadr_endpoint]
FOR DATABASE_MIRRORING (
AUTHENTICATION = CERTIFICATE [dag_certificate] Windows NEGOTIATE)
GO
--grant CONNECT permission to the new user, for this endpoint
GRANT CONNECT ON ENDPOINT::[hadr_endpoint] to [dag_admin];
GO

USE master; 

GO
--DB_replica_2
--create a master key if it does't exist
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'd1wu$952KLsut375';
GO

CREATE LOGIN [dag_admin] WITH PASSWORD = 'd1wu$952KLsut375';
GO
CREATE USER [dag_admin] FOR LOGIN [dag_admin];
GO
--restore the certificate from DB_replica_1
CREATE CERTIFICATE [dag_certificate]
AUTHORIZATION dag_admin
FROM FILE = 'C:\dag_cer\dag_certificate.cer'
WITH PRIVATE KEY (
FILE = 'C:\dag_cer\dag_certificate.pvk',
DECRYPTION BY PASSWORD = 'd1wu$952KLsut375')
GO

--altering the endpoint on DB_replica_2
ALTER ENDPOINT [hadr_endpoint]
FOR DATABASE_MIRRORING (
AUTHENTICATION = CERTIFICATE [dag_certificate] Windows NEGOTIATE)
GO
--grant CONNECT permission to the new user, for this endpoint
GRANT CONNECT ON ENDPOINT::[hadr_endpoint] to [dag_admin];
GO


--on Primary node on the Secondary site
--DB_replica_3
--create a master key if it does't exist
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'd1wu$952KLsut375';
GO

CREATE LOGIN [dag_admin] WITH PASSWORD = 'd1wu$952KLsut375';
GO
CREATE USER [dag_admin] FOR LOGIN [dag_admin];
GO
--restore the certificate from DB_replica_1
CREATE CERTIFICATE [dag_certificate]
AUTHORIZATION dag_admin
FROM FILE = 'C:\dag_cer\dag_certificate.cer'
WITH PRIVATE KEY (
FILE = 'C:\dag_cer\dag_certificate.pvk',
DECRYPTION BY PASSWORD = 'd1wu$952KLsut375')
GO

--altering the endpoint on DB_replica_3
ALTER ENDPOINT [hadr_endpoint]
FOR DATABASE_MIRRORING (
AUTHENTICATION = CERTIFICATE [dag_certificate] Windows NEGOTIATE)
GO
--grant CONNECT permission to the new user, for this endpoint
GRANT CONNECT ON ENDPOINT::[hadr_endpoint] to [dag_admin];
GO
