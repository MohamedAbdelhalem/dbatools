--add computed columns
declare @sql varchar(max)
declare computed_cursor cursor fast_forward
for
select 'ALTER TABLE '+table_name+' ADD ['+column_name+'] AS '+definition
from dbo.promoted_columns_of_converted_tables
order by table_size desc

open computed_cursor
fetch next from computed_cursor into @sql
while @@FETCH_STATUS = 0
begin

exec(@sql)

fetch next from computed_cursor into @sql
end
close computed_cursor
deallocate computed_cursor
