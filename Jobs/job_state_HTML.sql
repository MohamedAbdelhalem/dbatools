USE [master]
GO
if object_id('[dbo].[job_state_HTML]') is not null
begin
drop Procedure [dbo].[job_state_HTML]
end
go

CREATE 
Procedure [dbo].[job_state_HTML](
@html			varchar(max) output)
as
begin

declare @job_name varchar(200), @job_duration varchar(30), @table_rows float,
@left_rows varchar(20),
@left_pct varchar(10)

if object_id('job_state__9870') is not null
begin
drop table job_state__9870
create table job_state__9870(
job_name varchar(100), 
job_duration varchar(100), 
table_name varchar(400), 
rows varchar(20), 
left_rows varchar(20),
percent_complete varchar(10))
end
else
begin
create table job_state__9870(job_name varchar(100), job_duration varchar(100), table_name varchar(400), rows varchar(20), left_rows varchar(20),
percent_complete varchar(10))
end


select @table_rows =  count(*) 
from T24PROD_UAT.dbo.FBNK_FUNDS_TRANSFER#HIS

select @left_rows = master.dbo.format(181966205 - @table_rows,-1)
select @left_pct = cast(round((@table_rows / 181966205.0) * 100,2) as varchar(10)) + '%'

select @job_name = job_name, @job_duration = job_duration
from master.dbo.active_job_status
where job_name = 'package onerime export import'

insert into job_state__9870 values (@job_name, @job_duration, 'T24PROD_UAT.dbo.FBNK_FUNDS_TRANSFER#HIS', 
master.dbo.format(@table_rows,-1), @left_rows, @left_pct)

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
select @loop, ','')+''''+'<td style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle; ">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''

from sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from sys.tables
where name like 'job_state__9870')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'job_state__9870')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'job_state__9870')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from job_state__9870

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

--print(@sqlstatement)
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

drop table job_state__9870
set nocount off
end

go

declare @htm varchar(max)
exec [dbo].[job_state_HTML]
@html = @htm output

select @htm



