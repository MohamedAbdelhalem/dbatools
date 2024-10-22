USE [master]
GO
--CREATE procedure [dbo].[sp_snapshot_database]
declare
--(
@db_name varchar(500) = 'AdventureWorks2016', 
@snapshot_name varchar(500) = 'AdventureWorks2016_SP', 
@Path varchar(max) = 'Default'
--)
--as
--begin
declare 
@LogicalName varchar(1000),
@defaultpath varchar(max),
@PhysicalName varchar(1000),
@body varchar(max),
@sql varchar(max)
declare SS_Cursor cursor fast_forward
for
select logicalname, defaultpath, 
substring(physical_name,1, charindex('.',physical_name)-1)+'.SNP' physicalname
from (
select database_id, type, name logicalname, 
reverse(substring(reverse(physical_name),charindex('\',reverse(physical_name)),len(physical_name))) defaultpath,
reverse(substring(reverse(physical_name),1, charindex('\',reverse(physical_name))-1)) physical_name
from sys.master_files)a
where database_id = db_id(@db_name)
and type = 0

open SS_Cursor
fetch next from SS_Cursor into @LogicalName, @defaultpath ,@PhysicalName
while @@FETCH_STATUS = 0
begin
set @sql = isnull(@sql+',','')+'
(NAME = '+''''+@LogicalName+''''+', FILENAME = '+''''+case when @path = 'default' then @defaultpath else @path end+@PhysicalName+''''+')'
fetch next from SS_Cursor into @LogicalName, @defaultpath ,@PhysicalName
end
close SS_Cursor 
deallocate SS_Cursor 

set @sql = '
CREATE DATABASE '+@snapshot_name+'
ON '+@sql+'
AS SNAPSHOT OF '+@db_name
--exec (@sql)
print (@sql)
