if object_id('fn_table_size') is not null
begin
drop Function [dbo].[fn_table_size]
end
go
CREATE function [dbo].[fn_table_size](
@all	char(1) = '*',
@tables varchar(max) = '', 
@sort	varchar(10) = 'size') 
returns @table table (
id						int,
number_of_partitions	int, 
object_id				bigint, 
table_name				varchar(500), 
fg_type					varchar(30), 
scheme_filegroup		varchar(300), 
rows					varchar(30), 
total_pages				varchar(30), 
used_pages				varchar(30), 
unused_pages			varchar(30), 
data_pages				varchar(30), 
index_pages				varchar(30))
-- example: put * in any place of the word and it will replace with % like F_DE_ADDRESS = *DE_ADD* ==> %DE_ADD%
-- exec [dbo].[sp_table_size] ,FBNK_CUSTOMER* ,FBNK_ACCOUNT* ,[dbo].[F_DE_ADDRESS]  ,[dbo].[FBNK_BAB_208]  ,[dbo].[F_BAB_H_AC_ADD_INFO] 
as
begin
declare @staging table (
number_of_partitions int, 
object_id bigint, 
table_name varchar(500), 
fg_type varchar(30), 
scheme_filegroup varchar(300), 
rows varchar(30), 
total_pages varchar(30), 
used_pages varchar(30), 
unused_pages varchar(30), 
data_pages varchar(30), 
index_pages varchar(30), 
rows_n bigint, 
total_pages_n bigint) 

declare 
@values				varchar(max), 
@loop				int = 0,
@table_name_like	varchar(500)

declare @table__$ize table (objectid bigint)

if @all = '*'
begin
	insert into @table__$ize
	select object_id 
	from sys.tables with (nolock)
end
else
begin
	insert into @table__$ize
	select object_id 
	from sys.tables with (nolock) 
	where object_id in (
						select object_id(ltrim(rtrim(value))) 
						from master.[dbo].[Separator](@tables,',')
						where value not like '%*%')

declare like_cursor cursor fast_forward
for
select replace(ltrim(rtrim(value)),'*','%') 
from master.[dbo].[Separator](@tables,',')
where value like '%*%'

open like_cursor
fetch next from like_cursor into @table_name_like
while @@FETCH_STATUS = 0
begin

insert into @table__$ize
select object_id 
from sys.tables with (nolock) 
where name like @table_name_like

fetch next from like_cursor into @table_name_like
end
close like_cursor 
deallocate like_cursor

end

insert into @staging
select count(distinct partition_number) number_of_partitions, p.object_id, '['+schema_name(schema_id)+'].['+t.name+']' table_name,
case when g.name is null then 'PARTITION SCHEMA' else 'FILEGROUP' end fg_type, 
isnull(g.name,ps.name) scheme_filegroup,
master.dbo.format(case when count(*) = 1 then max(rows) else sum(rows) end,-1) rows,
master.dbo.numbersize(sum(total_pages) * 8, 'kb') total_pages,
master.dbo.numbersize(sum(used_pages) * 8, 'kb') used_pages,
master.dbo.numbersize((sum(total_pages) - sum(used_pages)) * 8, 'kb') unused_pages,
master.dbo.numbersize(sum(data_pages) * 8, 'kb') data_pages,
master.dbo.numbersize((sum(total_pages) - sum(data_pages) - (sum(total_pages) - sum(used_pages))) * 8.0, 'kb') index_pages,
case when count(*) = 1 then max(rows) else sum(rows) end rows_n,
sum(total_pages) total_pages_n
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_id)
inner join sys.indexes i with (nolock) 
on i.object_id = p.object_id
and i.index_id = p.index_id
left join sys.filegroups g with (nolock) 
on i.data_space_id = g.data_space_id
left join sys.partition_schemes ps with (nolock) 
on i.data_space_id = ps.data_space_id
where i.index_id in (0,1)
group by schema_id, t.name, g.name,ps.name, p.object_id

if @all = '*'
begin
insert into @table
select case 
when @sort = 'rows' then row_number() over(order by rows_n desc) 
when @sort = 'size' then row_number() over(order by total_pages_n desc) 
end id, number_of_partitions, object_id, table_name, fg_type, scheme_filegroup, rows, total_pages, used_pages, unused_pages, data_pages, index_pages
from @staging
end
else
begin
insert into @table
select case 
when @sort = 'rows' then row_number() over(order by rows_n desc) 
when @sort = 'size' then row_number() over(order by total_pages_n desc) 
end id, number_of_partitions, object_id, table_name, fg_type, scheme_filegroup, rows, total_pages, used_pages, unused_pages, data_pages, index_pages
from @staging
where object_id in (select object_id(ltrim(rtrim(value))) from master.dbo.Separator(@tables, ','))
end

return
end

