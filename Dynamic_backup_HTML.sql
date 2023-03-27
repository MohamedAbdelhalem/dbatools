USE [master]
GO

/****** Object:  StoredProcedure [dbo].[Dynamic_backup_HTML]    Script Date: 8/21/2022 12:36:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create table [dbo].[white_list_users]
(id int identity(1,1), account_number varchar(100), username varchar(100), team varchar(100), is_allowed bit, email varchar(300), send_notification bit)
print('table [dbo].[white_list_users] has been created.')

insert into [dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification) values 
('Najib Anwer Anwarul Haque', 'Najib Anwer Anwarul Haque', 'T24 Team', 1,'NAnwerAnwarulHaque@Bankalbilad.com',0),
('T24_R19_Upgrade Team', 'T24_R19_Upgrade', 'T24 Team', 1,'T24_R19_Upgrade@Bankalbilad.com',0),
('ALBILAD\e008374', 'Fahad Suliman Alqarawi', 'DBA Manager', 1,'FSAlqarawi@bankAlbilad.com',0),
('ALBILAD\e004199', 'Abdulmohsen Ibrahim Bin Abdulwahed', 'DBA', 1,'AI.BinAbdulwahed@Bankalbilad.com',1),
('ALBILAD\c904153', 'Shaik Zubair Fareed', 'DBA', 1, 'SZubairFareed@Bankalbilad.com',1),
('ALBILAD\c904529', 'Mohammed Fawzy AlHaleem', 'DBA', 1, 'MFawzyAlHaleem@Bankalbilad.com',1),
('ALBILAD\e010043', 'Nawaf Abdulrahman Bukhari', 'DBA', 1,'NAbdulrahmanBukhari@Bankalbilad.com',1),
('ALBILAD\e010052', 'Hamad Fahad Al Rubayq', 'DBA', 1,'HFahadAlRubayq@Bankalbilad.com',1),
('BANKSA', 'System Admin', 'System Admin', 1, NULL, 0)

go

CREATE
Procedure [dbo].[Dynamic_backup_HTML]
(@html varchar(max) output)
as
begin
set nocount on

select 
--rn.database_name [Database Name],
'T24PROD_UAT' [Database Name],
Command,
cast(round(percent_complete,3) as varchar)+' %'  [File Percent Complete],
backup_type,
duration Backup_duration,
Time_to_complete,
Estimated_completion_time,
backup_file_name [Backup File Name]
into dynamicHTMLTable 
from [dbo].[monitor_backup] mr


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
where name like 'dynamicHTMLTable%')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable%')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable%')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from dynamicHTMLTable

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

drop table dynamicHTMLTable
set nocount off
end

