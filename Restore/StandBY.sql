use master
go
BACKUP database [AdventureWorksDW2019] 
TO  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go
BACKUP log [AdventureWorksDW2019] 
TO  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go

USE [master]
go
RESTORE DATABASE [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 1,  
MOVE N'AdventureWorksDW2019' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2019sby.mdf',  
MOVE N'AdventureWorksDW2019_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2019sby_log.ldf',  
NORECOVERY,  NOUNLOAD,  STATS = 5
go
RESTORE LOG [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 2,  
STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_AdventureWorksDW2019_SBY.BAK',  
NOUNLOAD,  STATS = 10
go

use [AdventureWorksDW2019]
go
create table mohamed (id int identity(1,1), name varchar(100))
go
insert into mohamed (name) values ('mohamed')
go 10000

select * from [AdventureWorksDW2019].[dbo].[mohamed]
select * from [AdventureWorksDW2019_SBY].[dbo].[mohamed]

use master
go
BACKUP log [AdventureWorksDW2019] 
TO DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorksDW2019-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
go
alter database [AdventureWorksDW2019_SBY] set single_user with rollback immediate 
go
RESTORE LOG [AdventureWorksDW2019_SBY] 
FROM  DISK = N'C:\Export\AdventureWorksDW2019_standby_test.bak' WITH  
FILE = 3,  
STANDBY = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\ROLLBACK_UNDO_AdventureWorksDW2019_SBY2.BAK',  
NOUNLOAD,  STATS = 10
go
alter database [AdventureWorksDW2019_SBY] set multi_user 

select * from [AdventureWorksDW2019].[dbo].[mohamed]
select * from [AdventureWorksDW2019_SBY].[dbo].[mohamed]
