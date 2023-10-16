alter procedure Dynamic_restore_HTML
(@html varchar(max) output)
as
begin
set nocount on
if not exists (
select *
from tempdb.sys.tables
where name like '#dynamicHTMLTable%')
begin
select 
rn.database_name,
command,
cast(round((cast(rn.current_file as float) / cast(rn.total_files  as float)) * 100.0, 4) as varchar)+' %' overall_percent_complete,
cast(round(percent_complete,3) as varchar)+' %'  current_backup_file_percent_complete,
restore_type,
duration,
time_to_complete,
estimated_completion_time,
backup_file_name
into #dynamicHTMLTable 
from [dbo].[monitor_restore] mr cross apply dbo.restore_notification rn
where rn.status = 0
end


declare 
@tr varchar(max), 
@th varchar(max), 
@cursor____columns varchar(max), 
@cursor_vq_columns varchar(max), 
@cursor_vd_columns varchar(max), 
@cursor_vr_columns varchar(max), 
@query_columns_count int, 
@sqlstatement varchar(max)

declare @tr_table table (id int identity(1,1), row_id int, tr varchar(1000))

select
@cursor____columns = isnull(@cursor____columns+',
','')+c.name,
@cursor_vq_columns = isnull(@cursor_vq_columns+',
','')+'@'+c.name,
@cursor_vd_columns = isnull(@cursor_vd_columns+',
','')+'@'+c.name+' '+case 
when t.name in ('char','nchar','varchar','nvarchar') then t.name+'('+case when c.max_length < 0 then 'max' else cast(c.max_length as varchar(10)) end+')' 
when t.name in ('bit') then 'varchar(5)'
when t.name in ('real','int','bigint','smallint','tinyint','float') then 'varchar(20)'
else '' 
end,
@cursor_vr_columns = isnull(@cursor_vr_columns+'
union all 
select @loop, ','')+''''+'<td style="border:1px solid black; text-align: center; vertical-align: middle;">'+''''+'+ltrim(rtrim(@'+c.name+'))+'+''''+'</td>'+''''
from tempdb.sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from tempdb.sys.tables
where name like '#dynamicHTMLTable%')
order by column_id


select @th = isnull(@th+'
','')+'<th style="border:1px solid black;">'+name+'</th>'
from tempdb.sys.columns 
where object_id in (select object_id
from tempdb.sys.tables
where name like '#dynamicHTMLTable%')
order by column_id

select @query_columns_count = count(*)
from tempdb.sys.columns 
where object_id in (select object_id
from tempdb.sys.tables
where name like '#dynamicHTMLTable%')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from #dynamicHTMLTable

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
  <tr style="border:1px solid black; text-align: center; vertical-align: middle;">
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
<table style="border:1px solid BLUE;border-collapse:collapse;width: 70%">
  <tr bgcolor="YELLOW">
  '+@th+'
  '+@tr+'
'+'</table>'

set @html = @table

--drop table #dynamicHTMLTable
set nocount off
end

