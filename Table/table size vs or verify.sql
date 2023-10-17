select --top 200
t.name, 
'['+schema_name(schema_id)+'].['+t.name+']' table_name,-- i.index_id, i.name index_name,
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
sum(total_pages) * 8 total_pages_n
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
where i.index_id in (0,1)
--where p.object_id in (select objectid from #table__$ize with (nolock))
group by schema_id, t.name, g.name, ps.name, ps.type_desc, i.index_id, i.name
order by table_name--, index_id
--order by sum(total_pages) desc
option (querytraceon 8649)

--vs or verify

declare @table table (id int identity(1,1), table_name nvarchar(600), rows nvarchar(50))
declare @table_name nvarchar(600), @sql nvarchar(1000), @parameter nvarchar(100) = '@rows nvarchar(50) output', @table_rows nvarchar(50)
declare i cursor fast_forward
for
select '['+schema_name(schema_id)+'].['+t.name+']'
from sys.tables t

open i
fetch next from i into @table_name
while @@FETCH_STATUS = 0
begin

set @sql = 'select @rows = master.dbo.format(count(*),-1) from '+@table_name
exec sp_executesql @sql, @parameter, @rows = @table_rows output 
insert into @table (table_name,rows)
values (@table_name, @table_rows)

fetch next from i into @table_name
end
close i
deallocate i

select * from @table
--order by cast(replace(rows, ',','') as bigint) desc
order by table_name
