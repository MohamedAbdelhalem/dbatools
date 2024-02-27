declare 
@type varchar(30),
@name varchar(300),
@sql varchar(1000)

declare i cursor fast_forward
for
select case type 
when 'P'	then 'PROCEDURE' 
when 'V'	then 'VIEW' 
when 'U'	then 'TABLE'
when 'TF'	then 'FUNCTION'
when 'FN'	then 'FUNCTION'
when 'FS'	then 'FUNCTION'
end type, '['+schema_name(schema_id)+'].['+name+']'
from sys.objects
where object_id in (
object_id('[dbo].[sp_table_indexes]'),
object_id('[dbo].[sp_tables_indexes]'),
object_id('[dbo].[sp_index_details]')
)
order by type

open i
fetch next from i into @type, @name
while @@FETCH_STATUS = 0
begin
set @sql = 'DROP '+@type+' '+@name
exec(@sql)
print(@sql)
fetch next from i into @type, @name
end
close i
deallocate i

go

CREATE PROCEDURE [dbo].[sp_index_details]
(@P_object_id int, @p_index_id int)
as
begin
declare
@P_table_Name varchar(200), @P_index_Name varchar(200), @index_type varchar(100), @is_unique varchar(20), @is_unique_constraint varchar(20), @is_primary_key varchar(20),
@compute_function varchar(500), @is_computed varchar(20), @is_persisted varchar(20), @is_disabled varchar(20)

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

declare @index_columns_keys varchar(max), @filegroup_type varchar(255), @partition_column_name varchar(255)
declare @index_id int, @index_name varchar(100), @column_name varchar(1500), @sql varchar(max), @is_include int, @fill_factor int, @filegroup varchar(500)

SELECT @index_columns_keys = ISNULL(@index_columns_keys+'','') +  
case is_included_column 
when 0 then (
case when (select max(key_ordinal) 
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id 
WHERE i.name = @P_Index_Name and ic.is_included_column = 0) = 1 then substring(COLUMN_NAME,1,charindex(',',COLUMN_NAME)-1)+')' else column_name end)
when 1 then (
case when (select count(*) 
FROM sys.indexes AS i INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id 
WHERE i.name = @P_Index_Name and ic.is_included_column = 1) = 1 then substring(COLUMN_NAME,1,charindex(',',COLUMN_NAME)-1)+')' else column_name end) 
end 
from(
SELECT i.index_id, '['+i.name+']' AS index_name ,
case key_ordinal
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
SELECT i.index_id, '['+i.name+']' AS index_name ,case key_ordinal
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
order by key_ordinal

set @sql = substring(ltrim(rtrim(@index_columns_keys )),1,len(ltrim(rtrim(@index_columns_keys )))-1)

select 
@fill_factor = fill_factor, 
@filegroup_type = case when fg.name is null then 'Partition Scheme' else 'Filegroup' end, 
@filegroup = isnull(fg.name,ps.name), 
@partition_column_name = pc.partition_column_name, 
@is_disabled = is_disabled
from sys.indexes i left outer join sys.filegroups fg
on i.data_space_id = fg.data_space_id
left outer join sys.partition_schemes ps
on i.data_space_id = ps.data_space_id
left outer join (select ic.object_id, c.name partition_column_name
from sys.index_columns ic inner join sys.columns c
on ic.object_id = c.object_id
and ic.column_id = c.column_id
where ic.index_id = 1
and ic.partition_ordinal > 0)pc
on i.object_id = pc.object_id
where i.object_id = @P_object_id 
and i.index_id = @p_index_id

--select @sql, @fill_factor, @filegroup, @filegroup_type, @partition_column_name, @is_disabled

select 
@compute_function = isnull(@compute_function +',','')+substring(cc.definition,2,charindex('(',cc.definition,2)-2),
@is_computed = isnull(@is_computed +',','')+cast(isnull(cc.is_computed,0) as varchar(10)),
@is_persisted = isnull(@is_persisted +',','')+cast(isnull(cc.is_persisted,0) as varchar(10))
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
left outer join (
select i.object_id, i.index_id, i.name index_name, ic.column_id, key_ordinal
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
and cc.column_id is not null
order by cc.column_id

set @column_name = null

select 
--@column_name = isnull(@column_name+', ','') + c.name 
@column_name = isnull(@column_name+', ','') + '['+c.name+'] ['+tt.name+']' + 
case 
when tt.name in ('char','varchar','binary','varbinary') then '('+cast(CEILING(cast(c.max_length as float)) as varchar(30))+')' 
when tt.name in ('nchar','nvarchar') then '('+cast(CEILING(cast(c.max_length/2 as float)) as varchar(30))+')' 
else '' end 
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tt
on c.user_type_id = tt.user_type_id
left outer join (
select i.object_id, i.index_id, i.name index_name, ic.column_id, key_ordinal
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
order by i.key_ordinal

if @is_primary_key = 1
begin
set @sql = 'ALTER TABLE '+@p_table_name+' ADD CONSTRAINT ['+@p_index_name+'] PRIMARY KEY '+ case when @index_id = 1 then 'CLUSTERED ' else 'NONCLUSTERED ' end + @sql + 
') WITH (FILLFACTOR = '+cast(case when @fill_factor = 0 then 100 else @fill_factor end as varchar)+') ON [' + @filegroup +']'+ISNULL('('+@partition_column_name+')','')
end
else
begin
if @is_unique_constraint = 1
begin

set @sql = 'ALTER TABLE '+@p_table_name+' ADD CONSTRAINT ['+@p_index_name+'] UNIQUE '+ case when @index_id = 1 then 'CLUSTERED ' else 'NONCLUSTERED ' end + @sql + 
' ON [' + @filegroup +']'+ISNULL('('+@partition_column_name+')','')
end
else
begin
set @sql = 'CREATE '+case @is_unique when 1 then 'Unique ' else '' end+
Case @index_type 
when 1 then 'CLUSTERED' 
when 2 then 'NONCLUSTERED' 
end + ' INDEX ['+@P_index_Name+'] ON '+@P_table_Name+' '+@sql + 
') WITH (FILLFACTOR = '+cast(case when @fill_factor = 0 then 100 else @fill_factor end as varchar)+') ON [' + @filegroup +']'+ISNULL('('+@partition_column_name+')','')
end
end
select @P_table_Name, @p_index_id, @P_index_Name,Case @index_type 
when 1 then 'CLUSTERED' 
when 2 then 'NONCLUSTERED' 
end, @is_disabled, @column_name, @is_computed, @is_persisted, @compute_function,
@filegroup, case when @fill_factor = 0 then 100 else @fill_factor end, @sql

end

go
CREATE Procedure [dbo].[sp_table_indexes]
(@table_name varchar(500))
as
begin

declare @object_id bigint, @index_id bigint
declare @indexes table (id int identity(1,1), table_name varchar(500), index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))

declare x cursor fast_forward
for
select t.object_id, i.index_id
from sys.tables t left outer join sys.indexes i
on t.object_id = i.object_id
where i.type_desc != 'HEAP'
and i.object_id = object_id(ltrim(rtrim(@table_name)))
order by object_id, i.index_id

open x
fetch next from x into @object_id, @index_id
while @@FETCH_STATUS = 0
begin

insert into @indexes (table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id
fetch next from x into @object_id, @index_id
end
close x
deallocate x

select * from @indexes
end
go
CREATE Procedure [dbo].[sp_tables_indexes]
(@table_name varchar(max), @type int = 0)
as
begin

declare @object_id bigint, @index_id bigint
declare @indexes table (id int identity(1,1), table_name varchar(500), index_id varchar(30), index_name varchar(1000), index_type varchar(100), is_disabled varchar(30), 
index_columns varchar(1500), column_is_computed varchar(30), column_is_persisted varchar(30), columns_computed_function varchar(500), filegroup varchar(500), fill_factor varchar(30), synatx varchar(max))

declare x cursor fast_forward
for
select t.object_id, i.index_id
from sys.tables t left outer join sys.indexes i
on t.object_id = i.object_id
where i.type_desc != 'HEAP'
and i.object_id in (select object_id(ltrim(rtrim(value))) from master.dbo.Separator(@table_name,','))
order by object_id, i.index_id

open x
fetch next from x into @object_id, @index_id
while @@FETCH_STATUS = 0
begin

insert into @indexes (table_name, index_id, index_name, index_type, is_disabled, index_columns, column_is_computed, column_is_persisted, columns_computed_function, filegroup, fill_factor, synatx)
exec [dbo].[sp_index_details] @P_object_id = @object_id,  @p_index_id = @index_id

fetch next from x into @object_id, @index_id
end
close x
deallocate x

if @type = 0
begin
select * 
from @indexes
end
else
if @type = 1
begin
select * 
from @indexes
where index_id in (0,1)
end
else
if @type = 2
begin
select * 
from @indexes
where index_id > 1
end

end
