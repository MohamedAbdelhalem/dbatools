declare 
@database_name	varchar(300) = 'default',  --put default in the name if db_exist in (1,2) to restore the same name
@db_exist		smallint = 3, /*
							1) database exist; 
							2) database does not exist but it was restored before; 
							3) database did not restore before.*/
@recovery		bit = 0,
@fileid			smallint = 1,
@printype		smallint = 1,
@filename		varchar(1000) = 'E:\Backup\KeyWatcherMain_2022_06_09__14_45_PM__Full.bak' ,
@restore		varchar(3500),
@sql			varchar(3500)

declare @filelistonly table(
LogicalName varchar(1000),			PhysicalName varchar(1000), Type varchar(1000), 
FileGroupName varchar(1000),		Size varchar(1000),			MaxSize varchar(1000), 
FileId varchar(1000),				CreateLSN varchar(1000),	DropLSN varchar(1000), 
UniqueId varchar(1000),				ReadOnlyLSN varchar(1000),	ReadWriteLSN varchar(1000), 
BackupSizeInBytes varchar(1000),	SourceBlockSize varchar(1000), 
FileGroupId varchar(1000),			LogGroupGUID varchar(1000), DifferentialBaseLSN varchar(1000), 
DifferentialBaseGUID varchar(1000), IsReadOnly varchar(1000),	IsPresent varchar(1000), 
--TDEThumbprint varchar(1000)) -- 12
TDEThumbprint varchar(1000),		SnapshotUrl varchar(1000)) --> 12

set nocount on

set @sql = 'RESTORE filelistonly 
FROM  DISK = N'+''''+@filename+'''' 
insert into @filelistonly
exec(@sql)

--restore headeronly from disk = '\\npci2.d2fs.albilad.com\DBTEMP\R19_UATbackup_12052022_Keep01month.bak'
--select d. from @filelistonly d


if @database_name = 'default'
begin
	select @database_name = destination_database_name
	from msdb.dbo.restorehistory
	where backup_set_id in (Select max(backup_set_id) from msdb.dbo.restorehistory)
end

set @restore = 'RESTORE DATABASE ['+@database_name+'] 
FROM  DISK = N'+''''+@filename+''''+' WITH  FILE = '+cast(@fileid as varchar)+',  
'

if @db_exist = 1
begin
select @restore = @restore+'MOVE N'+''''+LogicalName+''''+' TO N'+''''+physical_name+''''+',
'
from @filelistonly bak inner join sys.master_files mf
on bak.FileId = mf.file_id
where database_id = db_id(@database_name)

if @printype = 2
begin
	select fileid, LogicalName, PhysicalName backup_physical_name, Physical_Name original_physical_name, FileGroupName, IsReadOnly
	from @filelistonly bak inner join sys.master_files mf
	on bak.FileId = mf.file_id
	where database_id = db_id(@database_name)
end

set  @restore = @restore+'NOUNLOAD, '+case @recovery when 0 then 'NORECOVERY' else '' end+', REPLACE, STATS = 1'
end
else if @db_exist = 2
begin
select @restore = @restore+'MOVE N'+''''+LogicalName+''''+' TO N'+''''+Physical_Name+''''+',
'
from msdb.dbo.restorehistory rh inner join msdb.dbo.backupfile bf
on rh.backup_set_id = bf.backup_set_id
inner join @filelistonly t
on bf.file_number = t.FileId
where bf.backup_set_id in (Select max(backup_set_id) from msdb.dbo.restorehistory)
and destination_database_name = @database_name

if @printype = 2
begin
	select fileid, LogicalName, PhysicalName backup_physical_name, Physical_Name original_physical_name, FileGroupName, IsReadOnly
	from msdb.dbo.restorehistory rh inner join msdb.dbo.backupfile bf
	on rh.backup_set_id = bf.backup_set_id
	inner join @filelistonly t
	on bf.file_number = t.FileId
	where bf.backup_set_id in (Select max(backup_set_id) from msdb.dbo.restorehistory)
	and destination_database_name = @database_name
end
set  @restore = @restore+'NOUNLOAD,  '+case @recovery when 0 then 'NORECOVERY' else '' end+', STATS = 1'
end

else if @db_exist = 3
begin
select @restore = @restore+'MOVE N'+''''+LogicalName+''''+' TO N'+''''+PhysicalName+''''+',
'
from @filelistonly t

if @printype = 2
begin
	select fileid, LogicalName, PhysicalName backup_physical_name, FileGroupName, IsReadOnly
	from @filelistonly t
end
set  @restore = @restore+'NOUNLOAD,  '+case @recovery when 0 then 'NORECOVERY' else '' end+', STATS = 1'
end

print(@restore)

set nocount off

--select * from msdb.dbo.restorehistory
