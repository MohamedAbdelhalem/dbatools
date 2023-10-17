if object_id('sp_table_size') is not null
begin
drop Procedure [dbo].[sp_table_size]
end
go
CREATE Procedure [dbo].[sp_table_size](
@all char(1)			= '*',
@tables varchar(max)	= '', 
@order_by varchar(100)	= 'rows'
) 
-- example: put * in any place of the word and it will replace with % like F_DE_ADDRESS = *DE_ADD* ==> %DE_ADD%
-- exec [dbo].[sp_table_size] ,FBNK_CUSTOMER* ,FBNK_ACCOUNT* ,[dbo].[F_DE_ADDRESS]  ,[dbo].[FBNK_BAB_208]  ,[dbo].[F_BAB_H_AC_ADD_INFO] 
as
begin
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

if @order_by = 'name'
begin
select --top 200
t.name, 
'['+schema_name(schema_id)+'].['+t.name+']' table_name, case when i.index_id = 0 then 'heap' when i.index_id = 1 then 'clusterd' when i.index_id > 1 then 'nonclusterd' end index_type,
case when g.name is null then 
master.dbo.format(sum(rows),-1) --sum_rows, 
else
master.dbo.format(max(rows),-1) --max_rows, 
end rows_n,
case when g.name is null then ps.type_desc else 'FILEGROUP' end fg_type, 
isnull(g.name,ps.name) scheme_filegroup,
master.dbo.numbersize(sum(total_pages) * 8, 'kb') total_pages,
master.dbo.numbersize(sum(used_pages) * 8, 'kb') used_pages,
master.dbo.numbersize((sum(total_pages) - sum(used_pages)) * 8, 'kb') unused_pages,
master.dbo.numbersize(sum(data_pages) * 8, 'kb') data_pages,
master.dbo.numbersize((sum(total_pages) - sum(data_pages) - (sum(total_pages) - sum(used_pages))) * 8.0, 'kb') index_pages,
sum(total_pages) total_pages_n
from sys.partitions p with (nolock) inner join sys.allocation_units a with (nolock) 
on (a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type = 2 and a.container_id = p.partition_id)
inner join sys.tables t with (nolock) 
on p.object_id = t.object_id
inner join sys.indexes i with (nolock) 
on i.object_id = p.object_id
and i.index_id = p.index_id
left join sys.filegroups g with (nolock) 
on i.data_space_id = g.data_space_id
left join sys.partition_schemes ps with (nolock) 
on i.data_space_id = ps.data_space_id
--where i.index_id in (0,1)
where p.object_id in (select objectid from @table__$ize)
--and g.name = DATAFG
group by schema_id, t.name, g.name, ps.name, ps.type_desc, i.index_id
order by t.name
end
else
begin
select --top 200
t.name, 
'['+schema_name(schema_id)+'].['+t.name+']' table_name, case when i.index_id = 0 then 'heap' when i.index_id = 1 then 'clusterd' when i.index_id > 1 then 'nonclusterd' end index_type,
case when g.name is null then 
master.dbo.format(sum(rows),-1) --sum_rows, 
else
master.dbo.format(max(rows),-1) --max_rows, 
end rows_n,
case when g.name is null then ps.type_desc else 'FILEGROUP' end fg_type, 
isnull(g.name,ps.name) scheme_filegroup,
master.dbo.numbersize(sum(total_pages) * 8, 'kb') total_pages,
master.dbo.numbersize(sum(used_pages) * 8, 'kb') used_pages,
master.dbo.numbersize((sum(total_pages) - sum(used_pages)) * 8, 'kb') unused_pages,
master.dbo.numbersize(sum(data_pages) * 8, 'kb') data_pages,
master.dbo.numbersize((sum(total_pages) - sum(data_pages) - (sum(total_pages) - sum(used_pages))) * 8.0, 'kb') index_pages,
sum(total_pages) total_pages_n
from sys.partitions p with (nolock) inner join sys.allocation_units a with (nolock) 
on (a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type = 2 and a.container_id = p.partition_id)
inner join sys.tables t with (nolock) 
on p.object_id = t.object_id
inner join sys.indexes i with (nolock) 
on i.object_id = p.object_id
and i.index_id = p.index_id
left join sys.filegroups g with (nolock) 
on i.data_space_id = g.data_space_id
left join sys.partition_schemes ps with (nolock) 
on i.data_space_id = ps.data_space_id
--where i.index_id in (0,1)
where p.object_id in (select objectid from @table__$ize)
--and g.name = DATAFG
group by schema_id, t.name, g.name, ps.name, ps.type_desc, i.index_id
order by case @order_by when 'size' then sum(total_pages) when 'rows' then case when g.name is null then sum(rows) else max(rows) end end desc
end
--option (querytraceon 8649)

--drop table #table__$ize
end
go

