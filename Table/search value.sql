use master
go
if exists (select name from sys.tables where name = 'find_text_table')
begin
truncate table master.dbo.find_text_table;
end
else
begin
create table find_text_table (
id int identity(1,1),
table_name varchar(400),
column_name varchar(400),
like_text_number bigint)
end

go
use [AdventureWorks2022]
go

declare 
@text			nvarchar(max) = '@',
@sql			nvarchar(max),
@table_name		nvarchar(400),
@column_name	nvarchar(400),
@v_count		bigint

declare table_cursor cursor fast_forward
for
select '['+schema_name(t.schema_id)+'].['+t.name+']', '['+c.name+']'
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tp
on c.user_type_id = tp.user_type_id
where tp.name in ('varchar','nvarchar')
order by t.name, c.name

open table_cursor
fetch next from table_cursor into @table_name, @column_name
while @@fetch_status = 0
begin 

set @sql = N'select @count = count(*)
from '+@table_name+'
where '+@column_name+' like '+''''+'%'+@text+'%'+''''

exec sp_executesql @sql, N'@count bigint output', @v_count output

insert into master.dbo.find_text_table (table_name, column_name, like_text_number) 
values (@table_name, @column_name, @v_count)

fetch next from table_cursor into @table_name, @column_name
end
close table_cursor
deallocate table_cursor

select row_number() over(partition by table_name order by table_name) pid, table_name, column_name, like_text_number
from master.dbo.find_text_table
where like_text_number > 0
go
declare 
@text			nvarchar(max) = 'La'

select 
'SELECT '+
isnull([1],'')+isnull(','+[2],'')+isnull(','+[3],'')+isnull(','+[4],'')+isnull(','+[5],'')+
isnull(','+[6],'')+isnull(','+[7],'')+isnull(','+[8],'')+isnull(','+[9],'')+isnull(','+[10],'')+
isnull(','+[11],'')+isnull(','+[12],'')+isnull(','+[13],'')+isnull(','+[14],'')+isnull(','+[15],'')+
isnull(','+[16],'')+isnull(','+[17],'')+isnull(','+[18],'')+isnull(','+[19],'')+isnull(','+[20],'')+
isnull(','+[21],'')+isnull(','+[22],'')+isnull(','+[23],'')+isnull(','+[24],'')+isnull(','+[25],'')+
isnull(','+[26],'')+isnull(','+[27],'')+isnull(','+[28],'')+isnull(','+[29],'')+isnull(','+[30],'')+
isnull(','+[31],'')+isnull(','+[32],'')+isnull(','+[33],'')+isnull(','+[34],'')+isnull(','+[35],'')+
isnull(','+[36],'')+isnull(','+[37],'')+isnull(','+[38],'')+isnull(','+[39],'')+isnull(','+[40],'')+'
FROM '+table_name+'
WHERE '+[1]+' like '+''''+'%'+@text+'%'+''''+
isnull(' or '+[2]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[3]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[4]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[5]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[6]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[7]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[8]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[9]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[10]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[11]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[12]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[13]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[14]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[15]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[16]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[17]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[18]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[19]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[20]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[21]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[22]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[23]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[24]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[25]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[26]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[27]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[28]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[29]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[30]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[31]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[32]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[33]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[34]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[35]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[36]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[37]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[38]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[39]+' like '+''''+'%'+@text+'%'+'''','')+
isnull(' or '+[40]+' like '+''''+'%'+@text+'%'+'''','')
from (
select row_number() over(partition by table_name order by table_name) pid, table_name, column_name
from master.dbo.find_text_table
where like_text_number > 0)a
pivot
(max(column_name) for pid in (
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],
[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40]
))P

