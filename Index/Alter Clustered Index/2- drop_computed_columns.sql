--drop computed columns
declare @drop_computed_columns varchar(max)
declare drop_compute cursor fast_forward
for
select 'ALTER TABLE '+table_name+' DROP COLUMN ['+column_name+']' 
from dbo.promoted_columns_of_converted_tables
order by table_size desc

open drop_compute
fetch next from drop_compute into @drop_computed_columns 
while @@FETCH_STATUS = 0
begin
exec(@drop_computed_columns )
fetch next from drop_compute into @drop_computed_columns 
end
close drop_compute
deallocate drop_compute
go