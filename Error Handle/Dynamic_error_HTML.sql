USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Dynamic_error_HTML]    Script Date: 11/14/2022 10:36:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER --ALTER
Procedure [dbo].[Dynamic_error_HTML]
(@html varchar(max) output, @spid int)
as
begin
set nocount on

select isnull([error_number],'') [error_number], isnull([error_message],'') [error_message], isnull([disk volume],'') [disk volume], 
isnull([required_space],'') [required_space], isnull([available_space],'') [available_space], isnull([required_size_to_complete_restore],'') [required_size_to_complete_restore] 
into dynamicHTMLTable_error 
from [dbo].[error_message](@spid) 

declare 
@tr varchar(max), 
@th varchar(max), 
@cursor____columns varchar(max), 
@cursor_vq_columns varchar(max), 
@cursor_vd_columns varchar(max), 
@cursor_vr_columns varchar(max), 
@query_columns_count int, 
@sqlstatement varchar(max),
@border_color varchar(100) = 'gray'

declare @tr_table table (id int identity(1,1), row_id int, tr varchar(1000))

select
@cursor____columns = isnull(@cursor____columns+',
','')+'['+c.name+']',
@cursor_vq_columns = isnull(@cursor_vq_columns+',
','')+'@'+replace(c.name,' ','_'),
@cursor_vd_columns = isnull(@cursor_vd_columns+',
','')+'@'+replace(c.name,' ','_')+' '+case 
when t.name in ('char','nchar','varchar','nvarchar') then t.name+'('+case when c.max_length < 0 then 'max' else cast(c.max_length as varchar(10)) end+')' 
when t.name in ('bit') then 'varchar(5)'
when t.name in ('real','int','bigint','smallint','tinyint','float') then 'varchar(20)'
else '' 
end,
@cursor_vr_columns = isnull(@cursor_vr_columns+'
union all 
select @loop, ','')+''''+'<td style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle;">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''
from sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable_error%')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable_error%')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable_error%')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from dynamicHTMLTable_error

open i 
fetch next from i into '+@cursor_vq_columns+'
while @@fetch_status = 0
begin
set @loop = @loop + 1
select @loop, '+@cursor_vr_columns+'
fetch next from i into '+@cursor_vq_columns+'
end
close i
deallocate i'

insert into @tr_table
exec(@sqlstatement)

select @tr = isnull(@tr+'
','') +
case 
when col_position = 1 then
'</tr>
  <tr style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle;">
  '+tr
when col_position = col_count then
tr+'
</tr>'
else 
tr
end
from (
select top 100 percent row_number() over(partition by row_id order by id) col_position,id,row_id,@query_columns_count col_count,tr 
from @tr_table
order by id, row_id)a


declare @table varchar(max) = '
<table style="border:1px solid '+@border_color+';border-collapse:collapse;width: 70%">
  <tr bgcolor="YELLOW">
  '+@th+'
  '+@tr+'
'+'</table>'

set @html = @table

drop table dynamicHTMLTable_error
set nocount off
end

