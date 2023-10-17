USE [master]
GO
/****** Object:  StoredProcedure [dbo].[catch_log_queries]    Script Date: 8/21/2023 1:36:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create table hosts_long_queries (hostname varchar(255), status int)
insert into hosts_long_queries values ('hostname1',1),
('hostname2',1)
GO
CREATE Procedure [dbo].[catch_long_queries] (
@threshold_sec int = 120, @db_name varchar(500))
as
begin

declare @server_name varchar(255), @sql varchar(400)
declare @output table (output_text varchar(255))
declare @dm_os_volume_stats table (volume_mount_point varchar(10), total_bytes float, available_bytes float)

declare @db varchar(1000), @vol varchar(300), @file_0 int, @file_1 int
declare @db_size table (id int identity(1,1), 
database_name varchar(300), file_type int, [file_id] int, logical_name varchar(1000), physical_name varchar(2000), 
size_n int, size varchar(50), growth_n int, growth varchar(50), used_n int, used varchar(50), free_n int, free varchar(50), max_size varchar(50))

declare @disk table (id int identity(1,1), output_text varchar(255))
declare @partition table (id int identity(1,1), output_text varchar(255))
declare @disk_table table (id int, DiskNumber int, Path varchar(2000), Partition_Style varchar(10))
declare @partition_table table (id int, Disk_id varchar(2000), DiskNumber int, drive_letter varchar(50), size varchar(50))
declare @sql_disk varchar(1000), @sql_partition varchar(1000), @sql_volume varchar(1000)
declare @kill varchar(100), @session_id varchar(50), @email_body varchar(max), @html varchar(max), @threshold_pct int = 85

if object_id('sessions_with_long_running_time') is not null
begin
drop table sessions_with_long_running_time
end

create table sessions_with_long_running_time(
[#]						varchar(10), 
[session_id]			varchar(10),
[database_name]			varchar(255), 
[login_name]			varchar(255), 
[Process_host_name]		varchar(255), 
[client_net_address]	varchar(50), 
[Session_Start_time]	varchar(50),
[duration_sec]			varchar(10),
[duration]				varchar(50),
[waiting_time]			varchar(50),
[last_wait_type]		varchar(255),
[blocking_session_id]	varchar(10),
[Program_Name]			varchar(255),
[SQL_Text]				varchar(4000))

insert into sessions_with_long_running_time
select 
ROW_NUMBER() over(order by datediff(s,r.start_time,getdate()) desc),
spid, 
DB_NAME(p.dbid) database_name, 
loginame, 
hostname, 
client_net_address,
convert(varchar(50),r.start_time,120), 
datediff(s,r.start_time,getdate()) duration_sec, 
master.dbo.duration('s',datediff(s,r.start_time,getdate())) duration, 
master.dbo.duration('ms',waittime) waittime, 
lastwaittype, blocked, program_name, s.text sql_text
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
cross apply master.dbo.Separator(s.text, CHAR(9))sp
where hostname in (
select hostname 
from master.dbo.hosts_long_queries
where status = 1)
and DB_NAME(p.dbid) = @db_name
and s.text like '%SELECT%'
and p.status != 'sleeping'
and datediff(s,r.start_time,getdate()) >= @threshold_sec
order by duration_sec desc

declare kill_cursor cursor fast_forward
for
select session_id
from sessions_with_long_running_time

if (select COUNT(*) from sessions_with_long_running_time) > 0
begin

-------------------------###################################--------------------------------------------------
--killing the session scope
-------------------------###################################--------------------------------------------------
open kill_cursor
fetch next from kill_cursor into @session_id
while @@FETCH_STATUS = 0
begin

set @kill = 'kill '+@session_id
exec(@kill)

fetch next from kill_cursor into @session_id
end
close kill_cursor
deallocate kill_cursor
-------------------------###################################--------------------------------------------------
--send the eliminated session scope
-------------------------###################################--------------------------------------------------

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
select @loop, ','')+''''+'<td style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle; '+
+'background-color: '''+'+'+
case 
when c.name = 'volume_used' then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size   = ''2 TB'' then ''purple'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size  != ''2 TB'' then ''red'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red'' 
else ''green'' end' 
when c.name = 'volume' then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size  = ''2 TB'' then ''purple''  
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size != ''2 TB'' then ''red''  
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red'' 
else ''green'' end'
--when c.name = 'volume' then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @volume not in (''H:\'') then ''red'' else ''green'' end' 

when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 0 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end' 
when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 2 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end' 
when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 5 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end' 
when c.name = 'partition_style' then 'case when @partition_style = ''MBR'' then ''purple'' else ''green'' end'
else '' end+'+'+'''; '+
case 
when c.name in ('volume_used','volume','partition_style') then 'color: white' 
else 'color: black' 
end +'">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''

--this line below if you need to highlight all background row in red color.
--+'background-color: '''+'+'+'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' then ''red'' else ''white'' end' +'+'+''';">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''

from sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from sys.tables
where name like 'sessions_with_long_running_time')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'sessions_with_long_running_time')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'sessions_with_long_running_time')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from sessions_with_long_running_time
order by [#]

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

print(@sqlstatement)
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
<table style="border:1px solid '+@border_color+';border-collapse:collapse;width: 75%">
  <tr bgcolor="Azure">
  '+@th+'
  '+@tr+'
'+'</table>'

declare @n int
select @n = COUNT(*) from sessions_with_long_running_time

set @email_body = '<p><b>Dear all</b>,</p>


<p>The below select '+case when @n = 1 then 'session' else 'sessions' end+' '+case when @n = 1 then 'has' else 'have' end+' been terminated on T24 production database because '+case when @n = 1 then 'it' else 'they' end+' exceeded 2 minutes of execution timestamp.<p> 

'+@table+'


<p><b>Thanks a lot...</b></p>
<p><b>Data Management Team</b></p>

</table>'

declare 
@registry_key1			varchar(1500), 
@system_instance_name	varchar(300), 
@instance_name			varchar(100),
@IpAddress				varchar(50),
@subject				varchar(1000),
@database_name			varchar(500),
@email					varchar(1000),
@ccemail				varchar(1000),
@db_mail_profile		varchar(50),
@over_disks				int

select @db_mail_profile = name 
from msdb.dbo.sysmail_account 
where account_id in (
select ms.account_id from msdb.dbo.sysmail_profile p inner join msdb.dbo.sysmail_profileaccount pa
on p.profile_id = pa.profile_id
inner join msdb.dbo.sysmail_server ms
on ms.account_id = pa.account_id)

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = 't24_production@bankalbilad.com', 
@copy_recipients = 'alzikan@bankalbilad.com;FAlhusain@Bankalbilad.com;MS.Alghamdi@Bankalbilad.com;FSAlqarawi@bankAlbilad.com;NKolsi@bankalbilad.com;mailgroup_dba@bankalbilad.com',
@subject = 'Terminated sessions on T24 production database', 
@body = @email_body, 
@body_format = 'HTML'

--drop table sessions_with_long_running_time
set nocount off
end
end
