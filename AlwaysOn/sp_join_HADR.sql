CREATE Procedure [dbo].[sp_join_HADR] (
@ag_name		varchar(500),
@database_name	varchar(max) = '*', 
@except_db		varchar(max) = '0',
@replica_type	int, 
@action			int)
as
begin
declare @sql varchar(max)
declare @dbs table (database_name varchar(300))
if @database_name != '*'
begin
insert into @dbs
select db.name
from sys.databases db
where db.state_desc = 'restoring'
and db.name in (select ltrim(rtrim(value)) from master.dbo.Separator(@database_name,','))
and db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
end
else
begin
insert into @dbs
select db.name
from sys.databases db
where db.state_desc = 'restoring'
and db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
end

declare remove_cursor cursor fast_forward
for
select database_name
from @dbs

open remove_cursor
fetch next from remove_cursor into @database_name
while @@FETCH_STATUS = 0
begin

if @replica_type = 2
begin
set @sql = 'ALTER DATABASE ['+@database_name+'] SET HADR AVAILABILITY GROUP = ['+@ag_name+'];'
	if @action = 1
	begin
		print(@sql)
	end
	else 
	if @action = 2
	begin
		exec(@sql)
	end
	else 
	if @action = 3
	begin
		print(@sql)
		exec(@sql)
	end
end

fetch next from remove_cursor into @database_name
end
close remove_cursor
deallocate remove_cursor

end

go
declare @agName varchar(500)
select @agName = name from sys.availability_groups

exec [dbo].[sp_join_HADR]
@ag_name		= @agName,
@database_name	= '*', 
--@except_db		= '     BABmfaccountsdbPROD      ,       BABmfreportsdbPROD     ', 
@replica_type	= 2, 
@action			= 1
