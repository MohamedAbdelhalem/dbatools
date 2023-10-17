alter PROCEDURE Grant_view_with_dependencies(
@database_name			varchar(500),
@view_name_with_schema	varchar(500),
@login_name				varchar(500))
as
begin
declare @cursor varchar(max), @user_check varchar(max)
declare @view_id bigint, @sql nvarchar(500), @sql_databases varchar(max), @parameter nvarchar(100) = '@id bigint OUTPUT'
declare @databases table (database_name varchar(500))

set @sql = 'use ['+@database_name+'] select @id = object_id('+''''+@view_name_with_schema+''''+')'
exec sp_executesql @sql, @parameter, @id = @view_id OUTPUT

set @sql_databases = 'use ['+@database_name+']
select distinct referenced_database_name
from sys.sql_expression_dependencies 
where referencing_id = '+cast(@view_id as varchar(25))+'
and referenced_database_name is not null
union all 
select db_name(db_id())
from sys.views
where object_id = '+cast(@view_id as varchar(25))

insert into @databases
exec(@sql_databases)

--select * from @databases

declare @db_name varchar(500), @schema_name varchar(100), @object_name varchar(500)
declare db_cur cursor fast_forward
for
select database_name 
from @databases

open db_cur
fetch next from db_cur into @db_name
while @@FETCH_STATUS = 0
begin
set @user_check = 'use ['+@db_name+']
if (select count(*) from sys.sysusers where name ='+''''+@login_name+''''+') = 0
begin
CREATE USER ['+@login_name+'] FOR LOGIN ['+@login_name+']
end'

--print(@user_check)
exec(@user_check)

set @cursor = 'use ['+@database_name+']
declare @schema_name varchar(100), @object_name varchar(500), @sql varchar(1500)
declare i cursor fast_forward
for
select schema_name, name 
from (
select referenced_database_name database_name, referenced_schema_name schema_name, referenced_entity_name name 
from sys.sql_expression_dependencies 
where referencing_id = '+cast(@view_id as varchar(50))+'
and referenced_database_name is not null
union all 
select db_name(db_id()), schema_name(schema_id), name 
from sys.views
where object_id = '+cast(@view_id as varchar(50))+')a
where database_name = '+''''+@db_name+''''+'

open i
fetch next from i into @schema_name, @object_name
while @@FETCH_STATUS = 0
begin
set @sql = ''USE ['+@db_name+']
GRANT SELECT ON [''+@schema_name+''].[''+@object_name+''] TO '+@login_name+'''
print(@sql)
exec(@sql)
fetch next from i into @schema_name, @object_name
end
close i
deallocate i'

--print(@cursor)
exec(@cursor)

fetch next from db_cur into @db_name
end
close db_cur 
deallocate db_cur
end
go

exec [master].[dbo].[Grant_view_with_dependencies]
@database_name			= 'Data_Hub_T24',
@view_name_with_schema	= '[dbo].[FVCO_FUNDS_TRANSFER#HIS_M57]',
@login_name				= 'test_fawzy'
