Declare @table table
(id int identity(1,1), 
tablename varchar(400),
columnname varchar(400),
valuetext nvarchar(max))

declare @sql varchar(max)
declare 
@table_table varchar(400),
@column_name varchar(400)
declare
table_cursor cursor fast_forword
as
select '['+schema_name(t.schema_id)+'].['+t.name+']', c.name
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

set @sql = 'select '+@column_name+'
from '+@table_name+'
where '+@column_name+' like '+''''+'%'+@text+'%'+''''

