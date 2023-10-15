--sp_table_indexes '*'
declare @object_id bigint, @index_id bigint
declare idx cursor fast_forward
for
select OBJECT_ID, index_id
from sys.indexes 
where type_desc != 'HEAP'
and object_id in (select object_id from sys.tables)
order by object_id

declare @indexes table (id int identity(1,1), table_name varchar(500), index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))

open idx
fetch next from idx into @object_id, @index_id
while @@FETCH_STATUS = 0
begin

insert into @indexes (table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id

fetch next from idx into @object_id, @index_id
end
close idx
deallocate idx

select * from @indexes
order by id