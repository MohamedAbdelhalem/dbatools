CREATE Procedure [dbo].[sp_table_syntax]
(@table_name_with_scheme varchar(1000))
as
begin
declare 
@id					int,
@count_over			int,
@type				int, 
@index_id			int, 
@object_id			bigint, 
@partition_column	varchar(200), 
@filegroup			varchar(500), 
@syntax				varchar(max), 
@line				varchar(max)

--set @object_id = object_id('[HumanResources].[Employee]') -- primary key clustered index without partition
--set @object_id = object_id('[HumanResources].[Employee3]') -- primary key non-clustered index 
--set @object_id = object_id('[dbo].[Partition_Table]') -- only clustered index partition
--set @object_id = object_id('[dbo].[Partition_Table_pk]') -- clustered index partition table
--set @object_id = object_id('[dbo].[mohamed]') -- heap

set @object_id = object_id(@table_name_with_scheme)

declare @clustered_index table (
id							int identity(1,1), 
table_name					varchar(500), 
index_id					varchar(30), 
index_name					varchar(1000), 
index_type					varchar(100), 
is_disabled					varchar(30), 
index_columns				varchar(1500), 
column_is_computed			varchar(30), 
column_is_persisted			varchar(30), 
columns_computed_function	varchar(500), 
filegroup					varchar(500), 
fill_factor					varchar(30), 
synatx						varchar(max))

declare @table_syntax table (
id			int identity(1,1), 
columns		varchar(max), 
column_id	int)

declare @print_syntax table (
id		int identity(1,1), 
line	varchar(max))

SET NOCOUNT ON

if (select count(*)
	  from sys.indexes 
     where object_id = @object_id
       and index_id = 1
       and is_primary_key = 1) = 1
begin
select @filegroup = isnull(fg.name,ps.name), @partition_column = pc.partition_column_name, @index_id = i.index_id
from sys.indexes i left outer join sys.filegroups fg
on i.data_space_id = fg.data_space_id
left outer join sys.partition_schemes ps
on i.data_space_id = ps.data_space_id
left outer join (
				select ic.object_id, c.name partition_column_name
				from sys.index_columns ic inner join sys.columns c
				on ic.object_id = c.object_id
				and ic.column_id = c.column_id
				where ic.index_id = 1
				and ic.partition_ordinal > 0)pc
on i.object_id = pc.object_id
where i.object_id = @object_id
and index_id = 1

insert into @clustered_index
exec sp_index_details @object_id, @index_id

select @syntax = substring(synatx, 1, CHARINDEX(')', synatx))+') ON ['+@filegroup+']'+ISNULL('('+@partition_column+')','')
from (
select substring(synatx, CHARINDEX(' ADD ', synatx) + 5, len(synatx)) synatx
from @clustered_index)ci
select @type = 1

end
else
if (select count(*)
	  from sys.indexes 
     where object_id = @object_id
       and index_id > 1
       and is_primary_key = 1) = 1
begin
select @filegroup = fg.name , @index_id = i.index_id
from sys.indexes i inner join sys.filegroups fg
on i.data_space_id = fg.data_space_id
where i.index_id > 1
and is_primary_key = 1
and i.object_id = @object_id

insert into @clustered_index
exec sp_index_details @object_id, @index_id

select @syntax = substring(synatx, 1, CHARINDEX(')', synatx))+') ON ['+@filegroup+']'+ISNULL('('+@partition_column+')','')
from (
select substring(synatx, CHARINDEX(' ADD ', synatx) + 5, len(synatx)) synatx
from @clustered_index)ci
select @type = 2

end
else
if (select count(*)
	  from sys.indexes 
     where object_id = @object_id
       and index_id = 1
       and is_primary_key = 0) = 1
begin
select @filegroup = isnull(fg.name,ps.name), @partition_column = pc.partition_column_name, @index_id = i.index_id
from sys.indexes i left outer join sys.filegroups fg
on i.data_space_id = fg.data_space_id
left outer join sys.partition_schemes ps
on i.data_space_id = ps.data_space_id
left outer join (
				select ic.object_id, c.name partition_column_name
				from sys.index_columns ic inner join sys.columns c
				on ic.object_id = c.object_id
				and ic.column_id = c.column_id
				where ic.index_id = 1
				and ic.partition_ordinal > 0)pc
on i.object_id = pc.object_id
where i.object_id = @object_id
and index_id = 1

insert into @clustered_index
exec sp_index_details @object_id, @index_id

select @syntax = synatx
from @clustered_index
select @type = 3

end
else
begin
select @filegroup = fg.name, @index_id = i.index_id
from sys.indexes i inner join sys.filegroups fg
on i.data_space_id = fg.data_space_id
where i.index_id = 0
and i.object_id = @object_id

select @syntax = ' ON ['+@filegroup+']' 
select @type = 4
end

insert into @table_syntax
select 
'['+c.name+']'
+' '+ 
case when c.is_computed = 0 then
case 
when tp.schema_id  = 4 then '['+tp.name+']' 
when tp.schema_id != 4 then '['+schema_name(tp.schema_id)+'].['+tp.name+']' 
end 
else 
'AS '+cc.definition+' '+case cc.is_persisted when 1 then 'PERSISTED' else '' end end 
+
case 
when tp.name in ('nchar','nvarchar')  then '('+case when c.max_length < 0 then 'max' else cast(c.max_length / 2 as varchar(20)) end+')'
when tp.name in ('char','varchar')	  then '('+case when c.max_length < 0 then 'max' else cast(c.max_length as varchar(20)) end+')'
when tp.name in ('numeric','decimal') then '('+cast(c.precision as varchar(20))+','+cast(c.scale as varchar(20))+')'
else ''
end
+
case when c.is_identity = 1 then ' Identity('+CAST(ic.seed_value as varchar(20))+','+CAST(ic.increment_value as varchar(20))+')' else '' end
+
case c.is_rowguidcol when 1 then ' ROWGUIDCOL' else '' end
+
case c.default_object_id when 0 then '' else ' DEFAULT '+dc.definition end 
+
case 
c.is_nullable when 1 then case when c.is_computed = 1 and cc.is_persisted = 0 then '' 
else ' NULL' end else ' NOT NULL' end+
case 
when row_number() over(order by c.column_id) != COUNT(*) over() then ',' 
when row_number() over(order by c.column_id)  = COUNT(*) over() and @type in (3,4) then ')' 
when row_number() over(order by c.column_id)  = COUNT(*) over() and @type in (2) then ',' 
else '' end,
c.column_id
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tp
on tp.user_type_id = c.user_type_id
left outer join sys.computed_columns cc
on c.object_id = cc.object_id
and c.column_id = cc.column_id
left outer join sys.default_constraints dc
on dc.parent_object_id = c.object_id
and dc.parent_column_id = c.column_id
and dc.object_id = c.default_object_id
left outer join sys.identity_columns ic
on c.object_id = ic.object_id
and c.column_id = ic.column_id
where t.object_id = @object_id
union all select @syntax, 10000
order by c.column_id

--select * from @table_syntax

if @type in (3)
begin
insert into @print_syntax (line)
select columns table_syntax
from (
select * from @table_syntax
union all
select 10000-1, 'GO',10000-1 
union all
select 0, 'CREATE TABLE '+'['+schema_name(t.schema_id)+'].['+t.name+']'+' '+'(',0 
from sys.tables t
where t.object_id = @object_id)a
order by column_id
end
else
if @type in (4)
begin
insert into @print_syntax (line)
select ltrim(rtrim(columns)) table_syntax
from (
select * from @table_syntax
union all
select 10000+1, 'GO',10000+1 
union all
select 0, 'CREATE TABLE '+'['+schema_name(t.schema_id)+'].['+t.name+']'+' '+'(',0 
from sys.tables t
where t.object_id = @object_id)a
order by column_id
end
else
if @type in (1,2)
begin
insert into @print_syntax (line)
select ltrim(rtrim(columns)) table_syntax
from (
select *
from @table_syntax
union all
select 10000+1, 'GO',10000+1 
union all
select 0, 'CREATE TABLE '+'['+schema_name(t.schema_id)+'].['+t.name+']'+' '+'(',0 
from sys.tables t
where t.object_id = @object_id)a
order by column_id
end

declare print_cursor cursor fast_forward
for
select id, line, COUNT(*) over()
from @print_syntax
order by id

open print_cursor
fetch next from print_cursor into @id, @line, @count_over
while @@FETCH_STATUS = 0
begin

print(
case 
when @id > 1 and @id != @count_over and @id != (@count_over - 1) and @type = 3 then replicate(' ',len('CREATE TABLE [')-1)+@line 
when @id > 1 and @id != @count_over and @type in (1,2,4) then replicate(' ',len('CREATE TABLE [')-1)+@line 
else @line end)

fetch next from print_cursor into @id, @line, @count_over
end
close print_cursor
deallocate print_cursor

SET NOCOUNT OFF
end
