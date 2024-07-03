declare
@db_name          varchar(255),
@sql              varchar(max)
declare           @databases table (
database_name     varchar(255),
file_id           int,
logical_name      varchar(255),
disk_letter       varchar(3),
physical_name     varchar(max),
file_size_n       bigint,
file_size         varchar(20),
file_growth_n     bigint,
file_growth       varchar(20),
file_max_size_n   bigint,
file_max_size     varchar(20),
file_used_space_n bigint,
file_used_space   varchar(20),
file_free_space_n bigint,
file_free_space   varchar(20)
)
declare db_cursor cursor fast_forward
for
select name
from sys.databases
where state_desc = 'ONLINE'

open db_cursor
fetch next from db_cursor into @db_name
while @@FETCH_STATUS = 0
begin

set @sql = 'use ['+@db_name+']
select db_name(db_id()), file_id, name, left(physical_name,3), physical_name,
(size * 8.0),
case
when (size * 8.0) < 1024 then cast(cast((size * 8.0) as numeric(10,2)) as varchar(30))+''
KB''
when (size * 8.0) between 1024 and 1048576 then cast(cast((size * 8.0)/1024.0 as
numeric(10,2)) as varchar(30))+'' MB''
when (size * 8.0) between 1048577 and 1073741824 then cast(cast((size *
8.0)/1024.0/1024.0 as numeric(10,2)) as varchar(30))+'' GB''
when (size * 8.0) > 1073741824 then cast(cast((size * 8.0)/1024.0/1024.0/1024.0 as
numeric(10,2)) as varchar(30))+'' TB''
end,
(growth * 8.0),
case
when (growth * 8.0) < 1024 then cast(cast((growth * 8.0) as numeric(10,2)) as
varchar(30))+'' KB''
when (growth * 8.0) between 1024 and 1048576 then cast(cast((growth * 8.0)/1024.0 as
numeric(10,2)) as varchar(30))+'' MB''
when (growth * 8.0) between 1048577 and 1073741824 then cast(cast((growth *
8.0)/1024.0/1024.0 as numeric(10,2)) as varchar(30))+'' GB''
when (growth * 8.0) > 1073741824 then cast(cast((growth * 8.0)/1024.0/1024.0/1024.0 as
numeric(10,2)) as varchar(30))+'' TB''
end,
case when max_size < 0 then max_size else (max_size * 8.0) end,
case when max_size < 0 then ''UNLIMITED''
else
case
when (max_size * 8.0) < 1024 then cast(cast((max_size * 8.0) as numeric(10,2)) as
varchar(30))+'' KB''
when (max_size * 8.0) between 1024 and 1048576 then cast(cast((max_size * 8.0)/1024.0 as
numeric(10,2)) as varchar(30))+'' MB''
when (max_size * 8.0) between 1048577 and 1073741824 then cast(cast((max_size *
8.0)/1024.0/1024.0 as numeric(10,2)) as varchar(30))+'' GB''
when (max_size * 8.0) > 1073741824 then cast(cast((max_size * 8.0)/1024.0/1024.0/1024.0
as numeric(10,2)) as varchar(30))+'' TB''
end
end,
isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0),
case
when isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0) < 1024 then
cast(cast(isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0) as numeric(10,2)) as
varchar(30))+'' KB''
when isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0) between 1024 and 1048576 then
cast(cast(isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0)/1024.0 as numeric(10,2)) as
varchar(30))+'' MB''
when isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0) between 1048577 and 1073741824
then cast(cast(isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0)/1024.0/1024.0 as
numeric(10,2)) as varchar(30))+'' GB''
when isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0) > 1073741824 then
cast(cast(isnull((FILEPROPERTY(name,''spaceused'') * 8.0),0)/1024.0/1024.0/1024.0 as
numeric(10,2)) as varchar(30))+'' TB''
end,
isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0),
case
when isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0) < 1024 then
cast(cast(isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0) as numeric(10,2))
as varchar(30))+'' KB''
when isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0) between 1024 and
1048576 then cast(cast(isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0),
0)/1024.0 as numeric(10,2)) as varchar(30))+'' MB''
when isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0) between 1048577 and
1073741824 then cast(cast(isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0),
0)/1024.0/1024.0 as numeric(10,2)) as varchar(30))+'' GB''
when isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0), 0) > 1073741824 then
cast(cast(isnull(((size - FILEPROPERTY(name,''spaceused'')) * 8.0),
0)/1024.0/1024.0/1024.0 as numeric(10,2)) as varchar(30))+'' TB''
end
from sys.database_files'

insert into @databases
exec (@sql)

fetch next from db_cursor into @db_name
end
close db_cursor
deallocate db_cursor

select database_name, file_id, logical_name, disk_letter, physical_name, file_size,
file_growth, file_max_size, file_used_space, file_free_space
from @databases
order by database_name, file_id

