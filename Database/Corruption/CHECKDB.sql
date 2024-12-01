declare @db_name varchar(300), @sql varchar(max)
declare db_cursor cursor fast_forward
for
select name 
from sys.databases
where state_desc = 'ONLINE'
and database_id > 4

open db_cursor
fetch next from db_cursor into @db_name
while @@FETCH_STATUS = 0
begin

set @sql = 'DBCC CHECKDB('+@db_name+') WITH NO_INFOMSGS, ALL_ERRORMSGS'
print(@sql)
exec(@sql)
fetch next from db_cursor into @db_name
end
close db_cursor
deallocate db_cursor

go

exec sp_readerrorlog 0, 1, 'checkdb'

--if you have to fix the data page with option Repair_allow_data_loss this mean that may the repair will drop a row or rows, page or pages, or the intir table
--so the primary fix here is to restore the last backups
--means the data on disk is corrupted, may it because:
--1- may one of the servers had a logical consistency-bases I/O error, which indicated that a data page could not be decrypted due to a missing DEK(Database Encryption Key).
--2- may because a clustered index corruption where the page header was overwritten with zeros, likely due to a bad disk cache.
--3- may because of checksum error. this can occure when the data on the page does not match the expected checksum value, including that the data has been altered or corrupted. 
--   for instance, if a page is supposed to contain a specifc value but instead contains all zeros, this would be a clear sigh of corruption.
--4- may because of hardware failures, such as faulty disks or memory. for example, if a disk controller malfunctuions, it might write incorrect data to the disk, 
--   this type of corruption is often detected during routine consistency checks.
--5- may because of inadequate transaction logging can cause torn pages, where only part of a page is written to disk. 
--   this can happen of the system crashes or loses power during a write operation
--

