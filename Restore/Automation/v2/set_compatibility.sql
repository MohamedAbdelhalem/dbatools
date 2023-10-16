create Procedure set_compatibility
(@db_name varchar(500))
as
begin
declare 
@instance_level		int,
@database_level		int,
@version			int, 
@sql				varchar(1500)

select @version = substring(cast(value_data as varchar(20)),1,charindex('.',cast(value_data as varchar(20)))-1)
from sys.dm_server_registry
where value_name = 'CurrentVersion'

select @instance_level = case @version 
when 10 then 100	--2008
when 11 then 110	--2012
when 12 then 120	--2014
when 13 then 130	--2016
when 14 then 140	--2017
when 15 then 150	--2019
end

select @database_level = compatibility_level 
from sys.databases
where name = @db_name

if @instance_level != @database_level
begin
	set @sql = 'ALTER DATABASE ['+@db_name+'] SET COMPATIBILITY_LEVEL = '+cast(@instance_level as varchar)
	exec(@sql)
end
end
