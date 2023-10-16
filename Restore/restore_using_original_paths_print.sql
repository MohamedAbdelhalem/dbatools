declare 
@database_name varchar(300) = 'R21_BAB_DEV', 
@db_exist int = 1

declare @table table(
LogicalName varchar(1000), PhysicalName varchar(1000), Type varchar(1000), FileGroupName varchar(1000), Size varchar(1000), MaxSize varchar(1000), FileId varchar(1000), CreateLSN varchar(1000), DropLSN varchar(1000), UniqueId varchar(1000), ReadOnlyLSN varchar(1000), ReadWriteLSN varchar(1000), BackupSizeInBytes varchar(1000), SourceBlockSize varchar(1000), FileGroupId varchar(1000), LogGroupGUID varchar(1000), DifferentialBaseLSN varchar(1000), DifferentialBaseGUID varchar(1000), IsReadOnly varchar(1000), IsPresent varchar(1000), TDEThumbprint varchar(1000), SnapshotUrl varchar(1000))
declare 
@restore varchar(max),
@sql varchar(max), 
@filename varchar(1000) = '\\npci2.d2fs.albilad.com\DBTEMP\T24PROD_UAT_FULL_Before_R21COB_Backup_20220820.bkp' 

set nocount on
set @sql = 'RESTORE filelistonly 
FROM  DISK = N'+''''+@filename+'''' 
--print(@sql)

insert into @table
exec(@sql)

if @database_name = 'default'
begin
	select @database_name = destination_database_name
	from msdb.dbo.restorehistory
	where backup_set_id in (Select max(backup_set_id) from msdb.dbo.restorehistory)
end

set @restore = 'RESTORE DATABASE ['+@database_name+'] 
FROM  DISK = N'+''''+@filename+''''+' WITH  FILE = 1,  
'

if @db_exist = 1
begin
select @restore = @restore+'MOVE N'+''''+LogicalName+''''+' TO N'+''''+Physical_Name+''''+',
'
from @table bak inner join sys.master_files mf
on bak.FileId = mf.file_id
where database_id = db_id(@database_name)

select @database_name

select @database_name, fileid, LogicalName, PhysicalName backup_physical_name, Physical_Name original_physical_name, FileGroupName, IsReadOnly
from @table bak inner join sys.master_files mf
on bak.FileId = mf.file_id
where database_id = db_id(@database_name)

set  @restore = @restore+'NOUNLOAD, NORECOVERY, REPLACE, STATS = 1'
end
else
begin
select @restore = @restore+'MOVE N'+''''+LogicalName+''''+' TO N'+''''+Physical_Name+''''+',
'
from msdb.dbo.restorehistory rh inner join msdb.dbo.backupfile bf
on rh.backup_set_id = bf.backup_set_id
inner join @table t
on bf.file_number = t.FileId
where bf.backup_set_id in (Select max(backup_set_id) 
							from msdb.dbo.restorehistory)
and destination_database_name = @database_name

--select fileid, LogicalName, PhysicalName backup_physical_name, Physical_Name original_physical_name, FileGroupName, IsReadOnly
--from msdb.dbo.restorehistory rh inner join msdb.dbo.backupfile bf
--on rh.backup_set_id = bf.backup_set_id
--inner join @table t
--on bf.file_number = t.FileId
--where bf.backup_set_id in (Select max(backup_set_id) 
--							from msdb.dbo.restorehistory)
--and destination_database_name = @database_name

set  @restore = @restore+'NOUNLOAD, NORECOVERY, STATS = 1'
end

print(@restore)

set nocount off
				