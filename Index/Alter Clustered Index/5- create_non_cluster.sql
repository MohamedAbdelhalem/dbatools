--recreate the non-clustered indexes
--SET STATISTICS PROFILE ON
go
set QUOTED_IDENTIFIER ON
GO
set nocount on
go
declare @table_name varchar(1000), @index_name varchar(1000), @sql varchar(max)
declare non_cursor cursor 
for
select table_name, index_name, replace(synatx, ' WITH (', ' WITH (ONLINE = ON, ')
from dbo.nonclustered_indexes_of_converted_tables 
order by table_size desc

set nocount on
open non_cursor
fetch next from non_cursor into @table_name, @index_name, @sql
while @@FETCH_STATUS = 0
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'before', 'create non-clustered index', GETDATE())

exec(@sql)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'after', 'create non-clustered index', GETDATE())

fetch next from non_cursor into @table_name, @index_name, @sql
end
close non_cursor
deallocate non_cursor

set nocount off
go
--SET STATISTICS PROFILE off
go

