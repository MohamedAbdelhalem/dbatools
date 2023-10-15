use T24Prod
go
if OBJECT_ID('dbo.indexes_of_converted_tables') is not null
begin
truncate table dbo.indexes_of_converted_tables
end
else
begin
create table dbo.indexes_of_converted_tables (id int identity(1,1), table_name varchar(500), index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))
end
go
if OBJECT_ID('dbo.nonclustered_indexes_of_converted_tables') is not null
begin
truncate table dbo.nonclustered_indexes_of_converted_tables
end
else
begin
create table dbo.nonclustered_indexes_of_converted_tables (id int identity(1,1), table_name varchar(500), table_size bigint, index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))
end
go
if OBJECT_ID('dbo.promoted_columns_of_converted_tables') is not null
begin
truncate table dbo.promoted_columns_of_converted_tables
end
else
begin
create table dbo.promoted_columns_of_converted_tables (id int identity(1,1), table_name varchar(500), column_name varchar(500), definition varchar(1000), table_size bigint)
end
go
if OBJECT_ID('dbo.clustered_indexes_of_converted_tables') is not null
begin
truncate table dbo.clustered_indexes_of_converted_tables 
end
else
begin
create table dbo.clustered_indexes_of_converted_tables (id int identity(1,1), table_name varchar(500), table_size bigint, index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))
end
go
if OBJECT_ID('dbo.activity_convert_var_to_nvar_log') is not null
begin
truncate table dbo.activity_convert_var_to_nvar_log 
end
else
begin
create table dbo.activity_convert_var_to_nvar_log (id int identity(1,1), table_name varchar(1000), index_name varchar(1000), activity_status varchar(100), activity_name varchar(100), action_time datetime default getdate())
end
go


--sp_table_indexes '*'
declare @tables varchar(max) = '[dbo].[scFOMS_SC_V031],[dbo].[FOMS_SC_CASH_FLOW_TRANS]'
declare @object_id bigint, @index_id bigint, @table_size bigint
declare idx cursor fast_forward
for
select distinct p.object_id, index_id, 
SUM(alo.total_pages) over(partition by p.object_id) table_size
from (
select count(*)c, ltrim(rtrim(value)) table_name
from master.dbo.Separator(@tables,',') 
group by ltrim(rtrim(value)))a inner join sys.partitions p
on object_id(a.table_name) = p.object_id
inner join sys.allocation_units alo
on (alo.type in (1,3) and alo.container_id = p.hobt_id)
or (alo.type = 2 and alo.container_id = p.partition_id)
order by table_size desc
declare @indexes table (id int identity(1,1), table_name varchar(500), index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))

open idx
fetch next from idx into @object_id, @index_id, @table_size
while @@FETCH_STATUS = 0
begin

insert into indexes_of_converted_tables (table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id

fetch next from idx into @object_id, @index_id, @table_size
end
close idx
deallocate idx

select * 
from indexes_of_converted_tables
