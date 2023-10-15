alter database CC_StatementArchive_PRD modify file (name ='CC_StatementArchive_PRD', filegrowth=0KB)
alter database AccountStatementPRD modify file (name ='AccountStatementPRD', filegrowth=0KB)
alter database AccountStatementPRD modify file (name ='part201501_stg', filegrowth=0KB)

use master
go
alter database AccountStatementPRD set partner off
GO
alter database AccountStatementPRD add file (name ='AccountStatementPRD_2', filename = 'I:\Data\AccountStatementPRD_stg_2.ndf', size = 1024MB, filegrowth=1024MB) To Filegroup [PRIMARY]
alter database AccountStatementPRD add file (name ='part201501_stg_2', filename = 'I:\Data\part201501_stg_2.ndf', size = 1024MB, filegrowth=1024MB) To Filegroup [part201501]
GO
BACKUP LOG AccountStatementPRD 
TO  DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1ENTDBSQPWV4\AccountStatementPRD\Log\D1ENTDBSQPWV4_AccountStatementPRD_Log_20220906_111111_add_file.trn' WITH NOFORMAT, NOINIT,  
NAME = N'AccountStatementPRD-Log Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 1
GO
ALTER DATABASE AccountStatementPRD SET PARTNER = 'TCP://D2ENTDBSQPWV4.albilad.com:5022'


RESTORE LOG AccountStatementPRD FROM 
DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1ENTDBSQPWV4\AccountStatementPRD\Log\D1ENTDBSQPWV4_AccountStatementPRD_Log_20220906_111111_add_file.trn'
WITH 
Move N'AccountStatementPRD_2' TO N'I:\Data\AccountStatementPRD_stg_2.ndf',
Move N'part201501_stg_2' TO N'I:\Data\part201501_stg_2.ndf',
NORECOVERY, NOUNLOAD, STATS = 10
GO
