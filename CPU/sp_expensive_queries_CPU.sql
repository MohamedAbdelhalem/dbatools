USE [master]
GO
/****** Object:  StoredProcedure [dbo].[catch_log_queries]    Script Date: 8/29/2023 3:38:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter procedure [dbo].[sp_expensive_queries_CPU]
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

if object_id('expensive_queries_CPU') is not null
begin
drop table expensive_queries_CPU
end

create table expensive_queries_CPU(
[#]						varchar(50), 
[AVG_CPU_Time]			varchar(50),
[Pct_worker_time]		varchar(255), 
[SQL_Text]				nvarchar(max), 
[Nr_of_Executions]		varchar(255), 
[Total_CPU_Time_ms]		varchar(50), 
[Total_Worker_time]		varchar(50),
[Last_CPU_Time_ms]		varchar(50),
[Last_Execution]		varchar(50))

insert into expensive_queries_CPU
select 
row_number() over(order by cast(cast([Total CPU Time (ms)] as float) / cast([Nr of Executions] as float) as numeric(10,3)) desc) [#], 
master.dbo.format(cast(cast([Total CPU Time (ms)] as float) / cast([Nr of Executions] as float) as numeric(10,3)),5) avg_CPU_Time,
cast(pct_worker_time as numeric(10,3)) pct_worker_time, 
sql_text, 
master.dbo.format([Nr of Executions],-1) [Nr of Executions], 
master.dbo.format([Total CPU Time (ms)],-1) [Total CPU Time ms], 
master.dbo.format([total_worker_time],-1) [total_worker_time], 
master.dbo.format([Last CPU Time (ms)],-1) [Last CPU Time ms], 
convert(varchar(50),[Last Execution],120) [Last Execution]
from (
select  row_number() over(ORDER BY total_worker_time DESC)id,
((total_worker_time/1000.0) / sum(total_worker_time/1000.0) over()) * 100.0 pct_worker_time, *
from (
select top 20
s.text as sql_text,
qs.execution_count  [Nr of Executions],
qs.total_worker_time/1000.0 [Total CPU Time (ms)],
total_worker_time, 
qs.last_worker_time/1000.0 [Last CPU Time (ms)],
qs.last_execution_time [Last Execution],
qp.query_plan [Query Plan]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) s
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
where s.text not like '%EXEC msdb.dbo.USP2_T_%'
order by qs.total_worker_time desc)a)b
order by [#]

-------------------------###################################--------------------------------------------------
--send 
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

declare @tr_table table (id int identity(1,1), row_id int, tr varchar(max))

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
where name like 'expensive_queries_CPU')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'expensive_queries_CPU')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'expensive_queries_CPU')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from expensive_queries_CPU
order by cast([#] as int)

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

--declare @n int
--select @n = COUNT(*) from expensive_queries_CPU

set @email_body = '<p><b>Dear all</b>,</p>


<p>The below table contains the <b>TOP 20 SQL queries</b> that are consuming a high CPU.<p> 

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

--exec msdb..sp_send_dbmail 
--@profile_name = @db_mail_profile, 
--@recipients = 't24_production@bankalbilad.com', 
--@copy_recipients = 'alzikan@bankalbilad.com;FAlhusain@Bankalbilad.com;MS.Alghamdi@Bankalbilad.com;FSAlqarawi@bankAlbilad.com;NKolsi@bankalbilad.com;mailgroup_dba@bankalbilad.com',
--@subject = 'Terminated sessions on T24 production database', 
--@body = @email_body, 
--@body_format = 'HTML'

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = 't24_production@bankalbilad.com', 
@copy_recipients = 'alzikan@bankalbilad.com;FAlhusain@Bankalbilad.com;MS.Alghamdi@Bankalbilad.com;FSAlqarawi@bankAlbilad.com;NKolsi@bankalbilad.com;mailgroup_dba@bankalbilad.com',
@subject = 'Expensive Queries for T24 - CPU Time', 
@body = @email_body, 
@body_format = 'HTML'

--drop table expensive_queries_CPU
set nocount off

end
