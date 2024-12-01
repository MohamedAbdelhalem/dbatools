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

--if you have to fix the data page with option Repair_allow_data_loss this means that the repair will drop a row or rows, page or pages, or the entire table
--so the primary fix here is to restore the last backups
--means the data on disk is corrupted, may it because:
--1- may one of the servers had a logical consistency-bases I/O error, which indicated that a data page could not be decrypted due to a missing DEK(Database Encryption Key).
--2- may be because of a clustered index corruption where the page header was overwritten with zeros, likely due to a bad disk cache.
--3- may be because of a checksum error. this can occur when the data on the page does not match the expected checksum value, including when the data has been altered or corrupted. 
--   For instance, if a page is supposed to contain a specific value but instead contains all zeros, this would be a clear sign of corruption.
--4- may be because of hardware failures, such as faulty disks or memory. for example, if a disk controller malfunctions, it might write incorrect data to the disk, 
--   This type of corruption is often detected during routine consistency checks.
--5- may be because inadequate transaction logging can cause torn pages, where only part of a page is written to disk. 
--   This can happen if the system crashes or loses power during a write operation
--
-- Microsoft recommends restoring from a good backup first because when you restore the full backup (assuming the full backup is clean or free of corruption) and then apply all transaction logs up to the tail log backup, 
-- you ensure that all transactions are redone. This process guarantees clean pages and helps mitigate any corruption.
