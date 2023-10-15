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
go

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
--drop primry keyu clustered indexes, alter table change the data type to nvarchar, then create again the prmary key clustered index
SET STATISTICS PROFILE ON
go
set QUOTED_IDENTIFIER ON
GO
set nocount on
go
declare 
@table_name	varchar(1000),
@index_name	varchar(1000),
@index_columns	varchar(1000),
@type_name	varchar(100),
@index_id	int,
@drop_constraint	varchar(4000),
@alter_table	varchar(4000),
@add_constraint	varchar(4000)

declare clust_cursor cursor fast_forward
for
select table_name--, index_name, index_columns,ty.name ,i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = 'RECID'
and ((ty.name = 'varchar' and i.index_id in (0,1))
or (ty.name = 'nvarchar' and i.index_id in (0)))
and index_type = 'clustered'
order by table_size 

open clust_cursor
fetch next from clust_cursor into @table_name--, @index_name, @index_columns , @type_name, @index_id
while @@FETCH_STATUS = 0
begin

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = 'RECID'
and ((ty.name = 'varchar' and i.index_id in (0,1))
or (ty.name = 'nvarchar' and i.index_id in (0)))
and index_type = 'clustered'
and table_name = @table_name
order by table_size 

if @index_id = 1 and @type_name = 'varchar'
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'before', 'drop primary key', GETDATE())

set @drop_constraint = 'ALTER TABLE '+@table_name+' DROP CONSTRAINT '+@index_name
exec(@drop_constraint)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'after', 'drop primary key', GETDATE())

end

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = 'RECID'
and ((ty.name = 'varchar' and i.index_id in (0,1))
or (ty.name = 'nvarchar' and i.index_id in (0)))
and index_type = 'clustered'
and table_name = @table_name
order by table_size 

if @type_name = 'varchar'
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'before', 'column convert', GETDATE())

set @alter_table = 'ALTER TABLE '+@table_name+' ALTER COLUMN '+replace(@index_columns,'var','nvar')+' NOT NULL'
exec(@alter_table)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'after', 'column convert', GETDATE())

end

select @index_name = index_name, @index_columns = index_columns ,@type_name = ty.name ,@index_id = i.index_id
from dbo.clustered_indexes_of_converted_tables con left outer join sys.indexes i
on object_id(con.table_name) = i.object_id
inner join sys.columns c
on c.object_id = object_id(con.table_name)
inner join sys.types ty
on c.user_type_id = ty.user_type_id
where c.name = 'RECID'
and ((ty.name = 'varchar' and i.index_id in (0,1))
or (ty.name = 'nvarchar' and i.index_id in (0)))
and index_type = 'clustered'
and table_name = @table_name
order by table_size 

if @index_id = 0 and @type_name = 'nvarchar'
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'before', 'create primary key', GETDATE())

set @add_constraint = 'ALTER TABLE '+@table_name+' ADD CONSTRAINT '+@index_name+' PRIMARY KEY (RECID)'
exec(@add_constraint)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'after', 'create primary key', GETDATE())

end

fetch next from clust_cursor into @table_name--, @index_name, @index_columns , @type_name, @index_id
end
close clust_cursor
deallocate clust_cursor
set nocount off

SET STATISTICS PROFILE off
go

--select * from dbo.activity_convert_var_to_nvar_log 
--truncate table dbo.activity_convert_var_to_nvar_log 
go

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

go

--recreate the non-clustered indexes
declare @table_name varchar(1000), @index_name varchar(1000), @sql varchar(max)
declare non_cursor cursor 
for
select table_name, index_name, replace(synatx, ' WITH (', ' WITH (ONLINE = ON, ')
from dbo.nonclustered_indexes_of_converted_tables 
order by table_size desc

set nocount on
open non_cursor
fetch next from non_cursor into @table_name, @index_name, @sql
while @@FETCH_STATUS = 0
begin

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'before', 'create non-clustered index', GETDATE())

exec(@sql)

insert into dbo.activity_convert_var_to_nvar_log (table_name, index_name, activity_status, activity_name, action_time)
values (@table_name, @index_name, 'after', 'create non-clustered index', GETDATE())

fetch next from non_cursor into @table_name, @index_name, @sql
end
close non_cursor
deallocate non_cursor
set nocount off
go

