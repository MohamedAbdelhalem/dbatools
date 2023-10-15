--drop non-clustered indexes
declare @drop_non_clustered_indexes varchar(max)
declare drop_non cursor fast_forward
for
select 'DROP INDEX ['+index_name+'] ON '+table_name 
from dbo.nonclustered_indexes_of_converted_tables 
order by table_size desc

open drop_non
fetch next from drop_non into @drop_non_clustered_indexes 
while @@FETCH_STATUS = 0
begin
exec(@drop_non_clustered_indexes )
fetch next from drop_non into @drop_non_clustered_indexes 
end
close drop_non
deallocate drop_non