USE [master]
go
if exists (select * from sys.databases where name = 'AdventureWorksDW2016')
begin
alter database [AdventureWorksDW2016] set single_user with rollback immediate
end
go
RESTORE DATABASE [AdventureWorksDW2016] 
FROM  DISK = N'C:\share\AdventureWorksDW2016.bak' WITH  FILE = 1,  
MOVE N'AdventureWorksDW2016_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016_Data.mdf',  
MOVE N'AdventureWorksDW2016_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016_Log.ldf',  
NOUNLOAD,  replace, STATS = 5
go

alter database AdventureWorksDW2016 add filegroup fg01
alter database AdventureWorksDW2016 add filegroup fg02
alter database AdventureWorksDW2016 add filegroup fg03
alter database AdventureWorksDW2016 add filegroup fg04
alter database AdventureWorksDW2016 add filegroup fg05
alter database AdventureWorksDW2016 add filegroup fg06
alter database AdventureWorksDW2016 add filegroup fg07
alter database AdventureWorksDW2016 add filegroup fg08
alter database AdventureWorksDW2016 add filegroup fg09
alter database AdventureWorksDW2016 add filegroup fg10
alter database AdventureWorksDW2016 add filegroup fg11
alter database AdventureWorksDW2016 add filegroup fg12
go
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_01', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_01.ndf', size=170MB, filegrowth=16MB) to filegroup fg01
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_02', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_02.ndf', size=170MB, filegrowth=16MB) to filegroup fg02
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_03', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_03.ndf', size=170MB, filegrowth=16MB) to filegroup fg03
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_04', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_04.ndf', size=170MB, filegrowth=16MB) to filegroup fg04
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_05', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_05.ndf', size=170MB, filegrowth=16MB) to filegroup fg05
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_06', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_06.ndf', size=170MB, filegrowth=16MB) to filegroup fg06
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_07', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_07.ndf', size=170MB, filegrowth=16MB) to filegroup fg07
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_08', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_08.ndf', size=170MB, filegrowth=16MB) to filegroup fg08
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_09', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_09.ndf', size=170MB, filegrowth=16MB) to filegroup fg09
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_10', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_10.ndf', size=170MB, filegrowth=16MB) to filegroup fg10
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_11', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_11.ndf', size=170MB, filegrowth=16MB) to filegroup fg11
alter database AdventureWorksDW2016 add file (name='AdventureWorksDW2016_Data_12', filename='C:\DataFiles\AdventureWorksDW2016\AdventureWorksDW2016_Data_12.ndf', size=170MB, filegrowth=16MB) to filegroup fg12
go
use AdventureWorksDW2016
go
CREATE PARTITION FUNCTION [PARTITION_F_SALES_ORDER_ID_RIGHT](INT)
AS
RANGE RIGHT FOR VALUES (
1,2,3,4,5,6,7,8,9,10,11
)
GO
CREATE PARTITION SCHEME [PARTITION_S_SALES_ORDER_ID]
AS PARTITION [PARTITION_F_SALES_ORDER_ID_RIGHT]
TO
(
[FG01],[FG02],[FG03],[FG04],[FG05],[FG06],[FG07],[FG08],[FG09],[FG10],[FG11],[FG12]
)
GO
CREATE TABLE [dbo].[FactProductInventory_Data01](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductKey] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[MovementDate] [date] NOT NULL,
	[UnitCost] [money] NOT NULL,
	[UnitsIn] [int] NOT NULL,
	[UnitsOut] [int] NOT NULL,
	[UnitsBalance] [int] NOT NULL,
 CONSTRAINT [PK_FactProductInventory_01] PRIMARY KEY CLUSTERED 
(
[ProductKey], [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PARTITION_S_SALES_ORDER_ID] ([ProductKey])
) ON [PARTITION_S_SALES_ORDER_ID] ([ProductKey])
GO
insert into [dbo].[FactProductInventory_Data01]
select 
[ProductKey],
[DateKey],
[MovementDate],
[UnitCost],
[UnitsIn],
[UnitsOut],
[UnitsBalance]
from [dbo].[FactProductInventory]
go
--change database to full recovery
use master
go
ALTER DATABASE [AdventureWorksDW2016] SET RECOVERY FULL  

--end database setup
GO
--Take a regular full backup in case you want to go before this step

BACKUP DATABASE [AdventureWorksDW2016] 
TO DISK = N'C:\share\AdventureWorksDW2016_all_full_backup.bak' WITH NOFORMAT, INIT,  
NAME = N'AdventureWorksDW2016-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--look at all data files 
select name, state_desc, physical_name, m.is_read_only
from sys.master_files m
where database_id = db_id('AdventureWorksDW2016')

--step 0 Change the file growth to 0 but it is an optional step
---------------------------------------------------------------
--ALTER DATABASE AdventureWorksDW2016 MODIFY FILE (NAME='AdventureWorksDW2016_Data_05', FILEGROWTH=0KB)
	
--step 1 change the filegroup from read-write to read-only
--Unfortunately, you must close all sessions
----------------------------------------------------------
ALTER DATABASE AdventureWorksDW2016 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
ALTER DATABASE AdventureWorksDW2016 MODIFY FILEGROUP FG05 READONLY; 
ALTER DATABASE AdventureWorksDW2016 SET MULTI_USER;

--look again at all data files 
select name, state_desc, physical_name, m.is_read_only
from sys.master_files m
where database_id = db_id('AdventureWorksDW2016')

--step 2 take backup from the file/s you need to migrate it/them
--in my case, I just moved file 5 = AdventureWorksDW2016_Data_05
------------------------------------------------------------------
BACKUP DATABASE [AdventureWorksDW2016] 
FILE = 'AdventureWorksDW2016_Data_05'
TO DISK = N'C:\share\AdventureWorksDW2016_only_file_05_backup.bak' with INIT
------------------------------------------------------------------------------------
--the end of the preparation

--step 3 Take the file in an offline state 
------------------------------------------
ALTER DATABASE AdventureWorksDW2016 MODIFY FILE (NAME='AdventureWorksDW2016_Data_05', OFFLINE);

--step 4 restore the file to another path
--------------------------------------------
RESTORE DATABASE [AdventureWorksDW2016] 
FILE = 'AdventureWorksDW2016_Data_05'
FROM DISK = N'C:\share\AdventureWorksDW2016_only_file_05_backup.bak'
WITH FILE = 1,  
MOVE N'AdventureWorksDW2016_Data_05' TO N'C:\DataFiles\AdventureWorksDW2016\NEW\AdventureWorksDW2016_Data_05.ndf',
RECOVERY

--look again at all data files 
select name, state_desc, physical_name, m.is_read_only, growth
from sys.master_files m
where database_id = db_id('AdventureWorksDW2016')

--step 5 the last step returns the filegroup to the READ-Write state
-----------------------------------------------------------------------------
ALTER DATABASE AdventureWorksDW2016 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
ALTER DATABASE AdventureWorksDW2016 MODIFY FILEGROUP FG05 READWRITE; 
--again it's an optional step
--ALTER DATABASE AdventureWorksDW2016 MODIFY FILE (NAME='AdventureWorksDW2016_Data_05', FILEGROWTH=16MB)
ALTER DATABASE AdventureWorksDW2016 SET MULTI_USER;

--in another session
--use [AdventureWorksDW2016]
 
--declare 
--@gid			int,
--@ProductKey_min	int,
--@ProductKey_max	int,
--@DateKey_min	int,
--@DateKey_max	int
 
--declare insert_cursor cursor fast_forward
--for
--select gid, ProductKey_min,  ProductKey_max, DateKey_min, DateKey_max
--from (
--select gid, min([ProductKey]) ProductKey_min,  max([ProductKey]) ProductKey_max, min([DateKey]) DateKey_min, max([DateKey]) DateKey_max
--from (
--select master.dbo.gbulk(row_number() over(order by [ProductKey], [DateKey]), 500) gid, [ProductKey], [DateKey]
--from AdventureWorksDW2016.[dbo].[FactProductInventory] WITH (NOLOCK)
--)a
--group by gid)b
--where ProductKey_min = ProductKey_max
--and ProductKey_min != 4
--order by gid

--open insert_cursor
--fetch next from insert_cursor into @gid, @ProductKey_min, @ProductKey_max, @DateKey_min, @DateKey_max
--while @@fetch_status = 0
--begin
 
--Insert into [dbo].[FactProductInventory_Data01]
--([ProductKey],[DateKey],[MovementDate],[UnitCost],[UnitsIn],[UnitsOut],[UnitsBalance]
--)
--select 
--[ProductKey],[DateKey],[MovementDate],[UnitCost],[UnitsIn],[UnitsOut],[UnitsBalance]
--from AdventureWorksDW2016.[dbo].[FactProductInventory] 
--where [ProductKey] between @ProductKey_min and @ProductKey_max
--and [DateKey]  between @DateKey_min and @DateKey_max

--waitfor delay '00:00:02'

--fetch next from insert_cursor into @gid, @ProductKey_min, @ProductKey_max, @DateKey_min, @DateKey_max
--end
--close insert_cursor
--deallocate insert_cursor
 

