if object_id('[dbo].[sp_table_indexes]') is not null
begin
drop procedure [dbo].[sp_table_indexes]
end

GO
CREATE Procedure [dbo].[sp_table_indexes]
(@table_name varchar(500))
as
begin

declare @object_id bigint, @index_id bigint
declare @indexes table (id int identity(1,1), table_name varchar(500), index_id int, index_name varchar(1000), index_type varchar(100), 
index_columns varchar(1500), column_is_computed int, column_is_persisted int, columns_computed_function varchar(500), filegroup varchar(500), fill_factor int, synatx varchar(max))

declare x cursor fast_forward
for
select t.object_id, i.index_id
from sys.tables t left outer join sys.indexes i
on t.object_id = i.object_id
where i.type_desc != 'HEAP'
and i.object_id = object_id(@table_name)
order by object_id

open x
fetch next from x into @object_id, @index_id
while @@FETCH_STATUS = 0
begin

insert into @indexes (table_name, index_id, index_name, index_type, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id
fetch next from x into @object_id, @index_id
end
close x
deallocate x

select * from @indexes
end