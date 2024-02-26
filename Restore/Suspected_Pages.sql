use master
go
declare 
@database varchar(500) = 'AdventureWorks2017',
@full_bak varchar(max) = 'C:\AdventureWorks\AdventureWorks2017_2024_02_01__19_00_00.bak', 
@tail_bak varchar(max) = 'C:\AdventureWorks\AdventureWorks2017_TailLog.BAK'

declare @suspected_pages varchar(max)
select @suspected_pages = ISNULL(@suspected_pages+',','') + CAST(file_id as varchar(10))+':'+CAST(page_id as varchar(50)) 
from msdb.dbo.suspect_pages
where database_id = DB_ID(@database)

--select @suspected_pages
--1:1178,1:1400,1:1401,1:1405,1:5990,1:5991,1:5992,1:6546

RESTORE DATABASE AdventureWorks2017 
PAGE = @suspected_pages 
FROM DISK = @full_bak
WITH NORECOVERY;

BACKUP LOG AdventureWorks2017 
TO DISK = @tail_bak

RESTORE LOG AdventureWorks2017 
FROM DISK = @tail_bak
WITH RECOVERY;

