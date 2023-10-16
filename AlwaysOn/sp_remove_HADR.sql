CREATE Procedure [dbo].[sp_remove_HADR] (
@database_name	varchar(max) = '*', 
@except_db		varchar(max) = '0',
@with_db_drop	bit,
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
from sys.dm_hadr_database_replica_states dbrs inner join sys.databases db
on dbrs.database_id = db.database_id
where db.name in (select ltrim(rtrim(value)) from master.dbo.Separator(@database_name,','))
and db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
end
else
begin
insert into @dbs
select db.name
from sys.dm_hadr_database_replica_states dbrs inner join sys.databases db
on dbrs.database_id = db.database_id
where db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
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
set @sql = 'ALTER DATABASE ['+@database_name+'] SET HADR OFF'
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
if @with_db_drop = 1
begin
set @sql = 'DROP DATABASE ['+@database_name+']'
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
end

fetch next from remove_cursor into @database_name
end
close remove_cursor
deallocate remove_cursor

end

go
exec [dbo].[sp_remove_HADR]
@database_name	= '*', 
@except_db		= '0', 
@with_db_drop	= 1,
@replica_type	= 2, 
@action			= 1
