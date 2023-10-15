go
declare @bulk float = 500
declare @query_or_table_rows float = 10063

declare @indexes_script table (id int identity(1,1), table_name varchar(500), index_id int, index_name varchar(1000), index_type varchar(100), is_disabled bit, 
index_columns varchar(1500), column_is_computed int, column_is_persisted int, columns_computed_function varchar(500), filegroup varchar(500), fill_factor int, index_scrip varchar(max))
declare @loop int = 0, @sql varchar(max)

set nocount on
while @loop < Ceiling(@query_or_table_rows/@bulk) + 1
begin
set @loop = @loop + 1
set @sql = null
select @sql = isnull(@sql+',','')+table_name
from (
select top 100 percent master.dbo.gBulk(id, @bulk) gBulk, table_name
from (

select 
row_number() over(order by '['+schema_name(schema_id)+'].['+name+']') id, 
'['+schema_name(schema_id)+'].['+name+']' table_name
from sys.tables
where name like 'D_F_%' and left(name,4) = 'D_F_'

)a)b
where gBulk = @loop

declare @object_id bigint, @index_id bigint
create table #indexes (id int identity(1,1), table_name varchar(500), index_id int, index_name varchar(1000), index_type varchar(100), is_disabled bit, 
index_columns varchar(1500), column_is_computed int, column_is_persisted int, columns_computed_function varchar(500), filegroup varchar(500), fill_factor int, synatx varchar(max))

declare x cursor fast_forward
for
select t.object_id, i.index_id
from sys.tables t left outer join sys.indexes i
on t.object_id = i.object_id
where i.type_desc != 'HEAP'
and i.object_id in (select object_id(ltrim(rtrim(value))) from master.dbo.Separator(@sql,','))
order by object_id, i.index_id

open x
fetch next from x into @object_id, @index_id
while @@FETCH_STATUS = 0
begin

insert into #indexes (table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id
fetch next from x into @object_id, @index_id
end
close x
deallocate x

insert into @indexes_script
select table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx 
from #indexes

drop table #indexes

end

select *
from @indexes_script
order by id
set nocount off
--end
