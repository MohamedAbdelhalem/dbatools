if object_id('[dbo].[sp_index_detail]') is not null
begin
drop procedure [dbo].[sp_index_detail]
end

GO
CREATE PROCEDURE [dbo].[sp_index_detail]
(@P_object_id int, @p_index_id int)
as
begin
declare
@P_table_Name varchar(200), @P_index_Name varchar(200), @index_type varchar(100), @is_unique int, @is_unique_constraint int, @is_primary_key int,
@compute_function varchar(500), @is_computed int, @is_persisted int

select 
@P_table_Name = '['+schema_name(t.schema_id)+'].['+t.name+']', 
@P_index_Name = i.name, 
@index_type = i.type, 
@is_unique = i.is_unique, 
@is_unique_constraint = i.is_unique_constraint, 
@is_primary_key = i.is_primary_key
from sys.indexes i inner join sys.tables t
on i.object_id = t.object_id
where i.object_id = @P_object_id 
and index_id = @p_index_id

declare @index_id int, @index_name varchar(100), @column_name varchar(100), @sql varchar(max), @is_include int, @fill_factor int, @filegroup varchar(500)
declare i cursor fast_forward
for
SELECT index_id, index_name, 
case is_included_column 
when 0 then (
case when (select max(key_ordinal) 
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id 
WHERE i.name = @P_Index_Name and ic.is_included_column = 0) = 1 then substring(COLUMN_NAME,1,charindex(',',COLUMN_NAME)-1)+')' else column_name end)
when 1 then (
case when (select count(*) 
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id 
WHERE i.name = @P_Index_Name and ic.is_included_column = 1) = 1 then substring(COLUMN_NAME,1,charindex(',',COLUMN_NAME)-1)+')' else column_name end) 
end column_name,
index_column_id
from(
SELECT i.index_id, '['+i.name+']' AS index_name ,
case index_column_id
when (select min(key_ordinal) FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id WHERE i.name = @P_Index_Name and ic.is_included_column = 0) then '('+'['+COL_NAME(ic.object_id,ic.column_id)+']'+','
when (select max(key_ordinal) FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id WHERE i.name = @P_Index_Name and ic.is_included_column = 0) then '['+COL_NAME(ic.object_id,ic.column_id)+']'+')'
else '['+COL_NAME(ic.object_id,ic.column_id)+']'+',' end COLUMN_NAME,
ic.index_column_id, ic.key_ordinal, ic.is_included_column
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic 
ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.name = @P_Index_Name
and i.object_id = object_id(@P_table_name)
and is_included_column = 0
union all
SELECT i.index_id, '['+i.name+']' AS index_name ,case index_column_id
when (select min(index_column_id) FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id WHERE i.name = @P_Index_Name and ic.is_included_column = 1) then ' INCLUDE ('+'['+COL_NAME(ic.object_id,ic.column_id)+']'+','
when (select max(index_column_id) FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id WHERE i.name = @P_Index_Name and ic.is_included_column = 1) then '['+COL_NAME(ic.object_id,ic.column_id)+']'+')'
else '['+COL_NAME(ic.object_id,ic.column_id)+']'+',' end COLUMN_NAME,
ic.index_column_id, ic.key_ordinal,
ic.is_included_column
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic 
ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.name = @P_Index_Name
and i.object_id = object_id(@P_table_name)
and is_included_column = 1)A
order by index_column_id

set @sql = ''
open i
fetch next from i into @index_id, @index_name, @column_name, @is_include
while @@fetch_status = 0
begin
set @sql = @sql+' '+@column_name

fetch next from i into @index_id, @index_name, @column_name, @is_include
end
close i
deallocate i

select @fill_factor = fill_factor, @filegroup = fg.name
from sys.indexes i inner join sys.filegroups fg
on i.data_space_id = fg.data_space_id
where object_id = @P_object_id 
and index_id = @p_index_id

select 
@compute_function = substring(cc.definition,2,charindex('(',cc.definition,2)-2),
@is_computed = isnull(cc.is_computed,0), 
@is_persisted = isnull(cc.is_persisted,0)
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
left outer join (
select i.object_id, i.index_id, i.name index_name, ic.column_id
from sys.indexes i inner join sys.index_columns ic
on i.object_id = ic.object_id
and i.index_id = ic.index_id) i
on i.object_id = t.object_id
and i.column_id = c.column_id
left outer join sys.computed_columns cc
on cc.object_id = c.object_id
and cc.column_id = c.column_id
where t.object_id = @P_object_id 
and i.index_id = @p_index_id

set @column_name = null

select 
@column_name = isnull(@column_name+', ','') + c.name 
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
left outer join (
select i.object_id, i.index_id, i.name index_name, ic.column_id
from sys.indexes i inner join sys.index_columns ic
on i.object_id = ic.object_id
and i.index_id = ic.index_id) i
on i.object_id = t.object_id
and i.column_id = c.column_id
left outer join sys.computed_columns cc
on cc.object_id = c.object_id
and cc.column_id = c.column_id
where t.object_id = @P_object_id 
and i.index_id = @p_index_id

if @is_primary_key = 1
begin
set @sql = 'ALTER TABLE '+@p_table_name+' ADD CONSTRAINT ['+@p_index_name+'] PRIMARY KEY '+ case when @index_id = 1 then 'CLUSTERED ' else 'NONCLUSTERED ' end + @sql + 
' WITH (FILLFACTOR = '+cast(@fill_factor as varchar)+') ON ' + @filegroup
end
else
begin
if @is_unique_constraint = 1
begin

set @sql = 'ALTER TABLE '+@p_table_name+' ADD CONSTRAINT ['+@p_index_name+'] UNIQUE '+ case when @index_id = 1 then 'CLUSTERED ' else 'NONCLUSTERED ' end + @sql + 
' ON ' + @filegroup
end
else
begin
set @sql = 'CREATE '+case @is_unique when 1 then 'Unique ' else '' end+
Case @index_type 
when 1 then 'CLUSTERED' 
when 2 then 'NONCLUSTERED' 
end + ' INDEX ['+@P_index_Name+'] ON '+@P_table_Name+' '+@sql + 
' WITH (FILLFACTOR = '+cast(@fill_factor as varchar)+') ON ' + @filegroup
end
end
select @P_table_Name, @p_index_id, @P_index_Name,Case @index_type 
when 1 then 'CLUSTERED' 
when 2 then 'NONCLUSTERED' 
end, @column_name, @is_computed, @is_persisted, @compute_function,
@filegroup, @fill_factor, @sql
end

go

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
exec [dbo].[sp_index_detail] @P_object_id = @object_id,  @p_index_id = @index_id
fetch next from x into @object_id, @index_id
end
close x
deallocate x

select * from @indexes
end

go

