use master
go
--full backup with override
BACKUP database [AdventureWorksDW2019] 
TO  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, INIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go
--transaction log backup append
BACKUP log [AdventureWorksDW2019] 
TO  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go
--restore full backup with no recovery
RESTORE DATABASE [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 1,  
MOVE N'AdventureWorksDW2019' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2019sby.mdf',  
MOVE N'AdventureWorksDW2019_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2019sby_log.ldf',  
NORECOVERY,  NOUNLOAD,  STATS = 5
go
--restore transaction log backup with STANDBY
RESTORE LOG [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 2,  
STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_AdventureWorksDW2019_SBY.BAK',  
NOUNLOAD,  STATS = 10
go
--create a table in the original database and populate 10,000 rows
use [AdventureWorksDW2019]
go
create table mohamed (id int identity(1,1), name varchar(100))
go
insert into mohamed (name) values ('mohamed')
go 10000

--query the tables in the two databases (original and standby)
select * from [AdventureWorksDW2019].[dbo].[mohamed]
--table doesn't exist
select * from [AdventureWorksDW2019_SBY].[dbo].[mohamed]

--refresh the new rows by taking a transaction log backup
--1. backup
use master
go
BACKUP log [AdventureWorksDW2019] 
TO DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go
--if you try to restore the above backup it will fail because of the database in use issue.
--alter database in single user with rollback
alter database [AdventureWorksDW2019_SBY] set single_user with rollback immediate 
go
--then do the restoration and it will work smothly 
RESTORE LOG [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 3,  
STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_AdventureWorksDW2019_SBY2.BAK',  
NOUNLOAD,  STATS = 10
go
--ture the database in multi-user again.
alter database [AdventureWorksDW2019_SBY] set multi_user 

--query the tables in the two databases (original and standby). again!
select * from [AdventureWorksDW2019].[dbo].[mohamed]
select * from [AdventureWorksDW2019_SBY].[dbo].[mohamed]
