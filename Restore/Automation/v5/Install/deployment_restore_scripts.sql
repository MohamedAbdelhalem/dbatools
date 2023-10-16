use master
go
if object_id('dbo.auto_restore_job_parameters') is not null
begin
drop Table dbo.auto_restore_job_parameters 
end
go

CREATE TABLE dbo.auto_restore_job_parameters (before_date datetime, db_restore_name varchar(500), username varchar(500), [workaround_locations] [varchar](4000))

Insert into dbo.auto_restore_job_parameters values ('2022-12-23 00:40:00','T24SDC8','T24SDC8',
'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\FULL\2022\November\;\\npci2.d2fs.albilad.com\T24_BK_staging_FULL\;\\npci2.d2fs.albilad.com\T24_BK_staging\DIFF\;\\npci2.d2fs.albilad.com\T24_BK_staging_LOGS\')

go

declare 
@type varchar(30),
@name varchar(300),
@sql varchar(1000)

declare i cursor fast_forward
for
select case type 
when 'P'	then 'PROCEDURE' 
when 'V'	then 'VIEW' 
when 'U'	then 'TABLE'
when 'TF'	then 'FUNCTION'
when 'FN'	then 'FUNCTION'
when 'FS'	then 'FUNCTION'
end type, '['+schema_name(schema_id)+'].['+name+']'
from sys.objects
where object_id in (
object_id('[dbo].[sp_schedule_modifier]'),
object_id('[dbo].[XEvent_errors]'), 
object_id('[dbo].[error_message]'), 
object_id('[dbo].[errors_email]'), 
object_id('[dbo].[Dynamic_error_HTML]'), 
object_id('[dbo].[Dynamic_restore_HTML]'), 
object_id('[dbo].[kill_sessions_before_restore]'),
object_id('[dbo].[monitor_restore]'),
object_id('[dbo].[set_compatibility]'),
object_id('[dbo].[sp_restore_database_distribution_groups]'),
object_id('[dbo].[sp_notification_restore]'),
object_id('[dbo].[automatic_database_restore]'),
object_id('[dbo].[white_list_users]'),
object_id('[dbo].[restore_notification]'),
object_id('[dbo].[restore_loction_groups]'),
object_id('[dbo].[team_detail]')
)
union all
select 'JOB', name 
from msdb.dbo.sysjobs
where name in ('Notification Restore','Automatic Restore Job')
order by type

open i
fetch next from i into @type, @name
while @@FETCH_STATUS = 0
begin
if @type = 'JOB'
begin
	set @sql = 'EXEC msdb.dbo.sp_delete_job @job_name=N'+''''+@name+''''+', @delete_unused_schedule=1'
	exec(@sql)
	print(@sql)
end
else
begin
	set @sql = 'DROP '+@type+' '+@name
	exec(@sql)
	print(@sql)
end
fetch next from i into @type, @name
end
close i
deallocate i

go

CREATE Procedure [dbo].[sp_schedule_modifier]
(@job_name varchar(500), @after varchar(10) = 'default', @amount int = 0, @modified_date datetime = '2000-01-01 00:00:00.000', @enable bit = 1)
as
begin
declare 
@job_id			nvarchar(100), 
@schedule_id	int, 
@date			int, 
@time			int, 
@after_date		datetime,
@date_generator nvarchar(1000),
@parameter		nvarchar(100) = '@date datetime output'

select @job_id = j.job_id, @schedule_id = schedule_id
from msdb..sysjobs j inner join msdb..sysjobschedules js
on j.job_id = js.job_id
where name = @job_name

if @after ='default'
begin
select 
@date = convert(varchar(10),@modified_date,112), 
@time = replace(convert(varchar(10),@modified_date,108),':','')
end
else
begin
set @date_generator = 'select @date = dateadd('+@after+', '+cast(@amount as varchar(10))+', getdate())'
exec sp_executesql @date_generator, @parameter, @after_date output

select 
@date = convert(varchar(10),@after_date,112), 
@time = replace(convert(varchar(10),@after_date,108),':','')
end

EXEC msdb.dbo.sp_attach_schedule @job_id=@job_id,@schedule_id=@schedule_id

EXEC msdb.dbo.sp_update_schedule @schedule_id=@schedule_id, 
@enabled = @enable, 
@active_start_date = @date, 
@active_start_time = @time
end

go

CREATE Function [dbo].[error_message](@spid int)
returns @table table ([error_number] bigint, [error_message] varchar(max), [disk volume] varchar(10), required_space varchar(20), available_space varchar(20), required_size_to_complete_restore varchar(20))
as
begin
declare @table1 table (error_id int, [error_number] bigint, [error_message] varchar(max))
declare @target_date_table table (target_data varchar(max))
insert into @target_date_table
select target_data
FROM sys.dm_xe_session_targets AS xet JOIN sys.dm_xe_sessions AS xe 
ON (xe.address = xet.event_session_address)
WHERE xe.name = 'Restore_Error_Handling_spid_'+cast(@spid as varchar(10));

insert into @table1
select row_number() over(order by em.id) , [error_number], substring([Error_Message], charindex('[',[Error_Message],4)+1, len([Error_Message])-2 - charindex('[',[Error_Message],4)) [error_message]
from (
select row_number() over(order by id) id, master.dbo.virtical_array(value, '>',3) [error_message]
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where id in (select id + 1
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where master.dbo.virtical_array(value, '>',2) like '%"message"%'))em
inner join (
select row_number() over(order by id) id, master.dbo.virtical_array(value, '>',3) [error_number]
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
where id in (select id + 1
FROM @target_date_table t cross apply master.dbo.Separator(target_data, '</') s
--where master.dbo.virtical_array(value, '>',2) like '%"message"%')) en
where value like '%"error_number"%')) en
on em.id = en.id

insert into @table
select 
[error_number], 
[error_message], 
[disk volume],
master.dbo.numbersize(required_space,'byte') required_space, 
master.dbo.numbersize(substring(available_space, 1, charindex(' ', available_space)-1),'byte') available_space, 
master.dbo.numbersize(cast(required_space as bigint) - cast(substring(available_space, 1, charindex(' ', available_space)-1) as bigint),'byte') required_size_to_complete_restore
from (
select 
[error_number], 
[error_message], 
[disk volume],
substring([message],1, charindex(' ', [message])-1) required_space, 
ltrim(substring([message], charindex('while only', [message])+len('while only'),len([message]))) available_space
from (
select 
[error_number], 
[error_message], 
[disk volume],
substring(message,1, charindex('.',  message)-1) [message]
from (
select [error_number], [error_message], 
case when [error_number] = 3257 then ltrim(rtrim(replace(ltrim(substring([error_message],charindex('disk volume', [error_message]) + len('disk volume'), 6)),'''','"'))) end [disk volume],
case when [error_number] = 3257 then ltrim(substring([error_message],charindex('the database requires', [error_message]) + len('the database requires'), len([error_message]))) end [message]
from @table1)a)b)c

return
end

go

CREATE --ALTER
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

go

create Procedure [dbo].[XEvent_errors]
(@spid varchar(10), @create bit = 1)
as
begin
declare 
@sql_create varchar(max) = 'CREATE EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER 
ADD EVENT sqlserver.error_reported(
    WHERE ([package0].[not_equal_int64]([error_number],(5703)) 
	AND [package0].[not_equal_int64]([error_number],(5701)) 
	AND [sqlserver].[session_id]=('+@spid+')))
ADD TARGET package0.ring_buffer
WITH (
MAX_MEMORY=4096 KB,
EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,
STARTUP_STATE=OFF)',
@exec	  varchar(max) = 'ALTER EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER STATE=START',
@sql_drop varchar(max) = 'DROP EVENT SESSION [Restore_Error_Handling_spid_'+@spid+'] ON SERVER' 

if @create = 1
begin
exec(@sql_create)
exec(@exec)
end
else
begin
exec(@sql_drop)
end

end

go

CREATE
Procedure [dbo].[errors_email] --@project_name = 'CRM - CRM', @ccteam = '', @with_cc = 0, @exceed_threshold = 0
(
@project_name			varchar(100),
@ccteam					varchar(200) = '', 
@dba_in_to				varchar(500) = 'ALBILAD\c904529',
@with_cc				bit = 1,
@spid					int = 85)
as
begin
declare 
@registry_key1			varchar(1500), 
@system_instance_name	varchar(300), 
@instance_name			varchar(100),
@server_name			varchar(100),
@IpAddress				varchar(50),
@subject				varchar(1000),
@database_name			varchar(500),
@email					varchar(1000),
@ccemail				varchar(1000),
@email_body				varchar(max),
@dear					varchar(500),
@db_mail_profile		varchar(50),
@over_disks				int

select @db_mail_profile = name 
from msdb.dbo.sysmail_account 
where account_id in (
select ms.account_id from msdb.dbo.sysmail_profile p inner join msdb.dbo.sysmail_profileaccount pa
on p.profile_id = pa.profile_id
inner join msdb.dbo.sysmail_server ms
on ms.account_id = pa.account_id)

select @dear = isnull(@dear+', '+case when id = users and users > 1 then 'and ' else '' end, '') + username
from (
select top 100 percent row_number() over(order by id) id, substring(username,1, charindex(' ',username)-1) username, count(*) over() users
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)
order by id)a

exec master.[dbo].[Dynamic_error_HTML]
@html				= @email_body output,
@spid				= @spid

declare @hostname_table table (output_text varchar(100))
insert into @hostname_table
exec('xp_cmdshell ''hostname''')

select @server_name = output_text 
from @hostname_table 
where output_text is not null

declare @table table (id int identity(1,1), output_Text varchar(max))
declare @xp varchar(200), @id int
set @xp = 'ipconfig'
insert into @table
exec xp_cmdshell @xp

select top 1 @id = id 
from (
select id, case when charindex('.',ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))) > 0 then 1 else 0 end has_gateway
from @table
where id in (select id + 2
from @table
where output_Text like '%IPV4%'))a
where has_gateway = 1

select @IpAddress = ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))-- IP_address
from @table
where id = @id - 2

set @email_body = '<p><b>Dear '+@dear+'</b>,</p>


<p>Kindly find the errors below.</p>

'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>
'

set @subject = 'Errors - Restore monitor Progress Bar '+@Server_name+' - '+@IpAddress+' ('+@project_name+')'

select @ccemail = isnull(@ccemail+';','')+email 
from white_list_users
where send_notification = case @with_cc when 1 then 1 else 2 end
and account_number != @dba_in_to
and is_allowed = case @with_cc when 1 then 1 else 2 end

select @email = isnull(@email+';','')+email 
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end

go

CREATE FUNCTION [dbo].[team_detail](@text varchar(500), @type varchar(100))
returns varchar(500)
as begin
declare @result varchar(500)

if @type = 'name'
begin
select @result = ltrim(rtrim(substring(@text, 1, charindex('<',@text)-1)))
end
else
if @type = 'email'
begin
select @result = substring(@text, charindex('<',@text)+1, charindex('>',@text) - charindex('<',@text)-1)
end
return @result
end

go

CREATE TABLE [dbo].[white_list_users]
(id int identity(1,1), account_number varchar(100), username varchar(100), team varchar(100), is_allowed bit, email varchar(300), send_notification bit)
print('table [dbo].[white_list_users] has been created.')

insert into [dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification) values 
('ALBILAD\e008374', 'Fahad  Alqarawi Suliman', 'DBA Manager', 1,'FSAlqarawi@bankAlbilad.com',0),
('ALBILAD\e004199', 'Abdulmohsen Ibrahim Bin Abdulwahed', 'DBA', 1,'AI.BinAbdulwahed@Bankalbilad.com',1),
('ALBILAD\c904153', 'Shaik Zubair Fareed', 'DBA', 1, 'SZubairFareed@Bankalbilad.com',1),
('ALBILAD\c904529', 'Mohammed Fawzy AlHaleem', 'DBA', 1, 'MFawzyAlHaleem@Bankalbilad.com',1),
('ALBILAD\e010043', 'Nawaf Abdulrahman Bukhari', 'DBA', 1,'NAbdulrahmanBukhari@Bankalbilad.com',1),
('ALBILAD\e010052', 'Hamad Fahad Al Rubayq', 'DBA', 1,'HFahadAlRubayq@Bankalbilad.com',1),
('ALBILAD\e010057','Odai Abdulaziz Alageel','DBA', 1, 'oabdulazizalageel@bankalbilad.com', 1),
('ALBILAD\e010053','Saud Abdullah Al Ballaa','DBA', 1, 'SAbdullahAlBallaa@Bankalbilad.com', 1),
('ALBILAD\e010059','Rahaf Omar AL Tirbaq','DBA', 1, 'ROmarALTirbaq@Bankalbilad.com', 1),
('ALBILAD\e010312','Nawaf Ayed Alhajri','DBA',1,'NAyedAlhajri@Bankalbilad.com',1),
('BANKSA', 'System Admin', 'System Admin', 1, NULL, 0)

go
declare @team_members varchar(max) = 'Ragupathi . Ramanujam <R.Ramanujam@Bankalbilad.com>'
insert into [dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification)
select master.dbo.team_detail([value],'name'),master.dbo.team_detail([value],'name'),'T24 Team', 1, master.dbo.team_detail([value],'email'),0
from master.dbo.separator(@team_members,';') s

go

CREATE TABLE [dbo].[restore_notification](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[database_name] [varchar](500) NULL,
	[status] [int] NULL,
	[start_time] [datetime] NULL,
	[finish_time] [datetime] NULL,
	[total_files] [int] NULL,
	[current_file] [int] NULL,
	[last_file_name] [varchar](1000) NULL
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[restore_loction_groups](
	[directorys_map] [varchar](max) NULL
) ON [PRIMARY]

declare @physical_name varchar(max) = ''
select 
@physical_name = cast(data_space_id as varchar)+'-'+physical_name+';' + @physical_name
from (
select distinct data_space_id, reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name)), len(physical_name))) physical_name
from sys.master_files
where db_name(database_id) in (select db_name from (select count(*) c, db_name(database_id) db_name from sys.master_files where database_id > 4 group by database_id having count(*) > 8)n))a
order by data_space_id desc, physical_name 

delete from [dbo].[restore_loction_groups]

insert into [dbo].[restore_loction_groups] values (substring(@physical_name,1,len(@physical_name)-1))

go
--select * from [dbo].[restore_loction_groups]
--select * from sys.master_files where database_id = db_id('tempdb')
create Procedure set_compatibility
(@db_name varchar(500))
as
begin
declare 
@instance_level		int,
@database_level		int,
@version			int, 
@sql				varchar(1500)

select @version = substring(cast(value_data as varchar(20)),1,charindex('.',cast(value_data as varchar(20)))-1)
from sys.dm_server_registry
where value_name = 'CurrentVersion'

select @instance_level = case @version 
when 10 then 100	--2008
when 11 then 110	--2012
when 12 then 120	--2014
when 13 then 130	--2016
when 14 then 140	--2017
when 15 then 150	--2019
end

select @database_level = compatibility_level 
from sys.databases
where name = @db_name

if @instance_level != @database_level
begin
	set @sql = 'ALTER DATABASE ['+@db_name+'] SET COMPATIBILITY_LEVEL = '+cast(@instance_level as varchar)
	exec(@sql)
end
end
go

CREATE Procedure [dbo].[kill_sessions_before_restore]
(@type varchar(100), @name varchar(400))
as
begin
declare @kill varchar(50)
declare @table table (kill_statement varchar(30))

if @type = 'database'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where dbid = db_id(@name)
end
else
if @type = 'login'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where loginame = @name
end

declare k cursor fast_forward
for
select kill_statement from @table
open k
fetch next from k into @kill
while @@FETCH_STATUS = 0
begin
print(@kill)
exec(@kill)
fetch next from k into @kill
end
close k
deallocate k
end

go

create view [dbo].[monitor_restore]
as
select spid, percent_complete, database_name, backup_file, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(backup_file,1,charindex('\',backup_file)-1)) backup_file_name,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(reverse(database_name),1,charindex(' ',reverse(database_name))-1)) database_name,
reverse(replace(replace(substring(text,1, charindex('''', text,6)),'N''','') ,'''','')) backup_file,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete,
case
when s.text like '%restore database%' and s.text like '%move%' then 'FULL'
when s.text like '%restore database%' and s.text not like '%move%' then 'DIFF'
when s.text like '%restore log%' then 'LOG' end [restore_type], 
dbo.duration('s',datediff(s, r.start_time, getdate())) duration, 
dbo.duration('s',
case when percent_complete = 0 then 0 else case when 
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) time_to_complete,
dbo.duration('s', estimated_completion_time/1000) estimated_completion_time,
ltrim(rtrim(substring(s.text,1, charindex('from',s.text)-4))) database_name,
substring(s.text,charindex('=',s.text)+1,len(s.text)) text,
waittime, lastwaittype, blocked, command, r.status
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
where command like 'Restore%')a)b
GO

CREATE --ALTER
Procedure [dbo].[Dynamic_restore_HTML]
(@html varchar(max) output)
as
begin
set nocount on

select 
rn.database_name [Database Name],
Command,
cast(round((cast(rn.current_file as float) / cast(rn.total_files  as float)) * 100.0, 4) as varchar)+' %' [Overall Percent Complete],
cast(round(percent_complete,3) as varchar)+' %'  [Current Backup File Percent Complete],
Restore_type,
duration Restore_duration,
Time_to_complete,
Estimated_completion_time,
rn.total_files [Total Files], rn.current_file [Current File],
backup_file_name [Backup File Name]
into dynamicHTMLTable 
from [dbo].[monitor_restore] mr cross apply dbo.restore_notification rn
where rn.status = 0


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

go
 
go
CREATE --ALTER
Procedure [dbo].[sp_notification_restore] --@done = 1, @ccteam = '', @with_cc = 0 
(
@done					bit = 0,
@ccteam					varchar(200), 
@dba_in_to				varchar(500) = 'ALBILAD\c904529',
@with_cc				bit = 1)
as
begin
declare 
@registry_key1			varchar(1500), 
@system_instance_name	varchar(300), 
@instance_name			varchar(100),
@server_name			varchar(100),
@IpAddress				varchar(50),
@subject				varchar(1000),
@database_name			varchar(500),
@email					varchar(1000),
@ccemail				varchar(1000),
@email_body				varchar(max),
@dear					varchar(500),
@db_mail_profile		varchar(50)

select @db_mail_profile = name 
from msdb.dbo.sysmail_account 
where account_id = 1

select @dear = isnull(@dear+', '+case when id = users and users > 1 then 'and ' else '' end, '') + username
from (
select top 100 percent row_number() over(order by id) id, substring(username,1, charindex(' ',username)-1) username, count(*) over() users
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)
order by id)a

if @done = 1
begin
set @email_body = '<p><b>Dear '+@dear+'</b>,</p>

<p>Kindly be informed that the restore was <b>completed successfully</b>.</p>

<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'
end
else
begin
exec master.dbo.Dynamic_restore_HTML
@html = @email_body output
set @email_body = '<p><b>Dear '+@dear+'</b>,</p>


<p>Kindly be informed that the restore is <b>in progress</b> and you can find the status in the below table.</p>


'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'
end

select 
@server_name = case when charindex('\',name) > 0 then substring(name, 1, charindex('\',name)-1) else name end,
@instance_name = case when charindex('\',name) > 0 then substring(name, charindex('\',name)+1, len(name)) else 'MSSQLSERVER' end
from sys.servers where server_id = 0

declare @table table (id int identity(1,1), output_Text varchar(max))
declare @xp varchar(200), @id int
set @xp = 'ipconfig'
insert into @table
exec xp_cmdshell @xp

select @id = id 
from (
select id, case when charindex('.',ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))) > 0 then 1 else 0 end has_gateway
from @table
where id in (select id + 2
from @table
where output_Text like '%IPV4%'))a
where has_gateway = 1

select @IpAddress = ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))-- IP_address
from @table
where id = @id - 2

select @database_name = database_name from [master].[dbo].[restore_notification] where id in (select max(id) from [master].[dbo].[restore_notification])
set @subject = 'Restore monitor Progress Bar '+@Server_name+' - '+@IpAddress+' ('+replace(replace(@database_name,'[',''),']','')+')'

select @ccemail = isnull(@ccemail+';','')+email 
from white_list_users
where send_notification = case @with_cc when 1 then 1 else 2 end
and account_number != @dba_in_to
and is_allowed = case @with_cc when 1 then 1 else 2 end

select @email = isnull(@email+';','')+email 
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end

go

create Procedure [dbo].[sp_restore_database_distribution_groups]
(
@backupfile					varchar(max), 
@filenumber					varchar(5) = 'all', 
@option_01					int = 0,				   -- the new location of all files (log, data, or archive) will be the same of the location in the file list regarding the backup file.
@option_02					int = 0,				   -- all file (primary (.mdf), log fils (.ldf), secondary file (.ndf), archive file in the same location.
@restore_loc				varchar(500)  = 'default',
@option_03					int = 0,				   -- specify the data files folder (1 folder) and the same of the log files (1 folder too).
@restore_loc_data			varchar(500)  = 'default',
@restore_loc_log			varchar(500)  = 'default',
@option_04					int = 0,
@number_of_files_per_type	varchar(100)  = 'default', --'2-4'  "2" is the file type id, and "4" is the number of files per location
@restore_loction_groups		varchar(1000) = 'default', --'0-T:\SQLSERVER\Data\;1-J:\SQLSERVER\Data\;2-J:\SQLSERVER\Data\;2-K:\SQLSERVER\Data\;2-L:\SQLSERVER\Data\;2-M:\SQLSERVER\Data\;3-N:\SQLSERVER\Data\',
													   --"0,1,2,3" file type
													   -- 0 Log file .ldf
													   -- 1 primary file .mdf
													   -- 2 secondary file .ndf
													   -- 3 archive file
@with_recovery				bit = 1,  
@new_db_name				varchar(500)  = 'default',
@percent					int = 5,
@password					varchar(100)  = 'default',
@replace					bit,
@log_stopat					varchar(100)  = 'default',
@action						int = 1)

as
begin 
declare @restor_loc_table			table (output_text varchar(max))
declare @restor_loc_table_data		table (output_text varchar(max))
declare @restor_loc_table_data_1	table (output_text varchar(max))
declare @restor_loc_table_data_2	table (output_text varchar(max))
declare @restor_loc_table_data_3	table (output_text varchar(max))
declare @restor_loc_table_log		table (output_text varchar(max))
declare @xp_cmdshell varchar(500), 
@files_exist int, 
@files_exist_data int, 
@files_exist_log int, 
@file_type varchar(5)
declare 
@sql					varchar(max), 
@file_move				varchar(max), 
@file_move_data			varchar(max), 
@file_move_log			varchar(max), 
@file					int, 
@version				int,
@logicalname			varchar(500), 
@originalpath			varchar(max), 
@physicalname			varchar(500),
@ext					varchar(10),
@unique_id				varchar(10),
@Position				int, 
@DatabaseName			varchar(500), 
@BackupType				int,
@lastfile				int

declare @filelistonly_groups table (fileid int, LogicalName varchar(300), [location] varchar(1500), filename varchar(300), ext varchar(20), Type varchar(10)) 
declare @headeronly table (
BackupName				nvarchar(512),
BackupDescription		nvarchar(255),
BackupType				smallint,
ExpirationDate 			datetime,
Compressed				int,
Position 				smallint,
DeviceType 				tinyint,
UserName 				nvarchar(128),
ServerName 				nvarchar(128),
DatabaseName 			nvarchar(512),
DatabaseVersion 		int,
DatabaseCreationDate 	datetime,
BackupSize 				numeric(20,0),
FirstLSN 				numeric(25,0),
LastLSN 				numeric(25,0),
CheckpointLSN 			numeric(25,0),
DatabaseBackupLSN 		numeric(25,0),
BackupStartDate 		datetime,
BackupFinishDate 		datetime,
SortOrder 				smallint,
CodePage 				smallint,
UnicodeLocaleId 		int,
UnicodeComparisonStyle 	int,
CompatibilityLevel 		tinyint,
SoftwareVendorId 		int,
SoftwareVersionMajor 	int,
SoftwareVersionMinor 	int,
SoftwareVersionBuild 	int,
MachineName 			nvarchar(128),
Flags 					int,
BindingID 				uniqueidentifier,
RecoveryForkID			uniqueidentifier,
Collation 				nvarchar(128),
FamilyGUID 				uniqueidentifier,
HasBulkLoggedData 		bit,
IsSnapshot				bit,
IsReadOnly				bit,
IsSingleUser 			bit,
HasBackupChecksums		bit,
IsDamaged 				bit,
BeginsLogChain 			bit,
HasIncompleteMetaData 	bit,
IsForceOffline 			bit,
IsCopyOnly 				bit,
FirstRecoveryForkID 	uniqueidentifier,
ForkPointLSN 			numeric(25,0),
RecoveryModel 			nvarchar(60),
DifferentialBaseLSN 	numeric(25,0),
DifferentialBaseGUID 	uniqueidentifier,
BackupTypeDescription 	nvarchar(60),
BackupSetGUID 			uniqueidentifier,
CompressedBackupSize 	bigint,
containment 			tinyint,
KeyAlgorithm 			nvarchar(32)  default NULL,
EncryptorThumbprint 	varbinary(20)  default NULL,
EncryptorType 			nvarchar(32))

declare @filelistonly table (
LogicalName				varchar(1000),
PhysicalName			varchar(max),
Type					varchar(5),
filegroup varchar(300), col02 varchar(max),col03 varchar(max),fileid int,
col05 varchar(max),col06 varchar(max),col07 varchar(max),col08 varchar(max),
col09 varchar(max),col10 varchar(max),col11 varchar(max),filetype int,
col13 varchar(max),col14 varchar(max),col15 varchar(max),col16 varchar(max),
col17 varchar(max),col18 varchar(max),col19 varchar(max))

set nocount on
if @password = 'default'
begin
set @sql = 'restore filelistonly from disk = '+''''+@backupfile+''''
end
else
begin
set @sql = 'restore filelistonly from disk = '+''''+@backupfile+''''+' with file = 1, mediapassword = '+''''+@password+''''
end

--restore filelistonly from disk = 'm:\backup_database\Backup_database_migration\wslogdb70_110_Full_2021_06_27__16_38_37.bak'
--print(@sql)

select @version = case 
when @@version like '%SQL Server 2008%' then 10 
when @@version like '%SQL Server 2012%' then 11 
when @@version like '%SQL Server 2014%' then 12 
when @@version like '%SQL Server 2016%' then 13 
when @@version like '%SQL Server 2017%' then 14 
when @@version like '%SQL Server 2019%' then 15 
end

if @version = 12
begin
insert into @filelistonly (
LogicalName,PhysicalName,Type,
filegroup, col02, col03, fileid, col05, col06, col07, col08,
col09, col10, col11, filetype, col13, col14, col15, col16,
col17, col18)
exec(@sql)
end
else
begin
insert into @filelistonly 
exec(@sql)
end

if @password = 'default'
begin
set @sql = 'restore headeronly from disk = '+''''+@backupfile+''''
end
else
begin
set @sql = 'restore headeronly from disk = '+''''+@backupfile+''''+' with file = 1, mediapassword = '+''''+@password+''''
end

if @version = 10
begin
insert into @headeronly (
BackupName,BackupDescription,BackupType,ExpirationDate,Compressed,Position,DeviceType,UserName,ServerName,
DatabaseName,DatabaseVersion,DatabaseCreationDate,BackupSize,FirstLSN,LastLSN,CheckpointLSN,DatabaseBackupLSN,
BackupStartDate,BackupFinishDate,SortOrder,CodePage,UnicodeLocaleId,UnicodeComparisonStyle,CompatibilityLevel,
SoftwareVendorId,SoftwareVersionMajor,SoftwareVersionMinor,SoftwareVersionBuild,MachineName,Flags,BindingID,
RecoveryForkID,Collation,FamilyGUID,HasBulkLoggedData,IsSnapshot,IsReadOnly,IsSingleUser,HasBackupChecksums,
IsDamaged,BeginsLogChain,HasIncompleteMetaData,IsForceOffline,IsCopyOnly,FirstRecoveryForkID,ForkPointLSN,
RecoveryModel,DifferentialBaseLSN,DifferentialBaseGUID,BackupTypeDescription,BackupSetGUID,CompressedBackupSize)
exec(@sql)
end
else if @version = 11
begin
insert into @headeronly (
BackupName,BackupDescription,BackupType,ExpirationDate,Compressed,Position,DeviceType,UserName,ServerName,
DatabaseName,DatabaseVersion,DatabaseCreationDate,BackupSize,FirstLSN,LastLSN,CheckpointLSN,DatabaseBackupLSN,
BackupStartDate,BackupFinishDate,SortOrder,CodePage,UnicodeLocaleId,UnicodeComparisonStyle,CompatibilityLevel,
SoftwareVendorId,SoftwareVersionMajor,SoftwareVersionMinor,SoftwareVersionBuild,MachineName,Flags,BindingID,
RecoveryForkID,Collation,FamilyGUID,HasBulkLoggedData,IsSnapshot,IsReadOnly,IsSingleUser,HasBackupChecksums,
IsDamaged,BeginsLogChain,HasIncompleteMetaData,IsForceOffline,IsCopyOnly,FirstRecoveryForkID,ForkPointLSN,
RecoveryModel,DifferentialBaseLSN,DifferentialBaseGUID,BackupTypeDescription,BackupSetGUID,CompressedBackupSize,containment)
exec(@sql)
end
else if @version > 11
begin
insert into @headeronly 
exec(@sql)
end

if @option_04 = 1
begin

insert into @filelistonly_groups (fileid, LogicalName, [location], [filename], ext, [Type])
select fileid,
LogicalName, originalPath, 
case when PhysicalName like '%.%' then 
		substring(PhysicalName, 1, charindex('.',PhysicalName)-1) else PhysicalName end PhysicalName,
case when PhysicalName like '%.%' then 
		reverse(substring(reverse(PhysicalName), 1, charindex('.',reverse(PhysicalName)))) else 'no_ext' end ext,
		type
from (
select LogicalName, type, fileid,
loc OriginalPath, 
reverse(substring(reverse(PhysicalName), 1, charindex('\',reverse(PhysicalName))-1)) PhysicalName
from (
select LogicalName, PhysicalName, Type, loc.loc, files.fileid
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, filetype, row_number() over(partition by filetype order by fileid) seq_id
from @filelistonly
where filetype != dbo.virtical_array(@number_of_files_per_type, '-', 1) 
) files 
left join (
select id, filetype, loc, row_number() over (partition by filetype order by filetype) location_id
from (
select id, dbo.virtical_array(value, '-', 1) filetype, dbo.virtical_array(value, '-', 2) loc
from dbo.separator(@restore_loction_groups,';'))a
where filetype != dbo.virtical_array(@number_of_files_per_type, '-', 1)) loc
on files.filetype = loc.filetype
union all
select LogicalName, PhysicalName, Type, loc.loc, files.fileid
from (
select *, row_number() over(partition by seq order by fileid) file_group_id
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, a.filetype, 
case when a.filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1) then 
case seq_id % cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int) when 0 then cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int) 
else seq_id % cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int)
end else 0
end seq 
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, filetype, row_number() over(partition by filetype order by fileid) seq_id
from @filelistonly
where filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1) 
)a)b) files inner join (
select id, filetype, loc, row_number() over (partition by filetype order by filetype) location_id
from (
select id, dbo.virtical_array(value, '-', 1) filetype, dbo.virtical_array(value, '-', 2) loc
from dbo.separator(@restore_loction_groups,';'))a
where filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1)) loc
on files.filetype = loc.filetype
and files.file_group_id = loc.location_id)a)b
order by fileid

declare @fileid int, @location varchar(1500)
declare g cursor fast_forward
for
select distinct fileid, location 
from @filelistonly_groups

end
--print(@sql)

select @lastfile = max(Position) from @headeronly

if (@option_01 = 1 or @option_02 = 1)
begin
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc+'"'+''''
	insert into @restor_loc_table
	exec (@xp_cmdshell)
end
else if @option_03 = 1
begin
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc_data+'"'+''''
	insert into @restor_loc_table_data
	exec (@xp_cmdshell)
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc_log+'"'+''''
	insert into @restor_loc_table_log
	exec (@xp_cmdshell)
end	
else if @option_04 = 1
begin
	open g
	fetch next from g into @fileid, @location
	while @@FETCH_STATUS = 0
	begin
		set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@location+'"'+''''
		if @fileid = 0
		begin
			insert into @restor_loc_table_log
			exec (@xp_cmdshell)
		end
		else if @fileid = 1
		begin
			insert into @restor_loc_table_data_1
			exec (@xp_cmdshell)
		end
		else if @fileid = 2
		begin
			insert into @restor_loc_table_data_2
			exec (@xp_cmdshell)
		end
		else if @fileid = 3
		begin
			insert into @restor_loc_table_data_3
			exec (@xp_cmdshell)
		end
	fetch next from g into @fileid, @location
	end
	close g
	deallocate g
end	

if (@option_01 + @option_02) = 1
begin
		select @files_exist = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end
else if (@option_03 = 1)
begin
		select @files_exist_data = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist

		select @files_exist_log = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_log
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end

else if (@option_04 = 1)
begin
		select @files_exist_data = count(*)
		from (

		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_1
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		union all
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_2
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		union all
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_3
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist

		select @files_exist_log = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_log
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end

declare backupfiles_cursor cursor fast_forward for
select Position, DatabaseName, BackupType
from @headeronly
where Position between 
case when @filenumber = 'all' then 0 else @filenumber end
and
case when @filenumber = 'all' then @lastfile else @filenumber end

declare dbfiles_cursor cursor fast_forward 
for
select 
LogicalName, originalPath, 
case when PhysicalName like '%.%' then 
		substring(PhysicalName, 1, charindex('.',PhysicalName)-1) else PhysicalName end PhysicalName,
case when PhysicalName like '%.%' then 
		reverse(substring(reverse(PhysicalName), 1, charindex('.',reverse(PhysicalName)))) else 'no_ext' end ext,
		type
from (
select LogicalName, type,
reverse(substring(reverse(PhysicalName), charindex('\',reverse(PhysicalName)),len(PhysicalName))) OriginalPath, 
reverse(substring(reverse(PhysicalName), 1, charindex('\',reverse(PhysicalName))-1)) PhysicalName
from @filelistonly)a

declare dbfiles_cursor_groups cursor fast_forward 
for
select 
LogicalName, replace([location],';',''), [filename], ext, type
from @filelistonly_groups
order by fileid


set @unique_id = ltrim(rtrim(cast(left(replace(replace(replace(replace(replace(replace(replace(newid(),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'-',''),5) as char)))

if (@option_01 + @option_02 + @option_03) = 1
begin
	open dbfiles_cursor
	fetch next from dbfiles_cursor into @logicalname, @originalpath, @physicalname, @ext, @file_type
	while @@fetch_status = 0
	begin

	if @option_01 = 1	
	begin
		if @files_exist > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	else if @option_02 = 1
	begin
		if @files_exist > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	else if @option_03 = 1
	begin
		if @file_type = 'D'
		begin
			if @files_exist_data > 0
			begin
				set @file_move_data = isnull(@file_move_data+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_data+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
			end
			else
			begin
				set @file_move_data = isnull(@file_move_data+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_data+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
			end
		end
		else if @file_type = 'L'
		begin
			if @files_exist_log > 0
			begin
				set @file_move_log = isnull(@file_move_log+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_log+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
			end
			else
			begin
				set @file_move_log = isnull(@file_move_log+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_log+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
			end
		end
	end
	fetch next from dbfiles_cursor into @logicalname, @originalpath, @physicalname, @ext, @file_type
	end
	close dbfiles_cursor 
	deallocate dbfiles_cursor 
end
else if @option_04 = 1
begin
	open dbfiles_cursor_groups
	fetch next from dbfiles_cursor_groups into @logicalname, @originalpath, @physicalname, @ext, @file_type
	while @@fetch_status = 0
	begin
	if @option_04 = 1
	begin
		if @files_exist_data > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	fetch next from dbfiles_cursor_groups into @logicalname, @originalpath, @physicalname, @ext, @file_type
	end
	close dbfiles_cursor_groups 
	deallocate dbfiles_cursor_groups 
end

open backupfiles_cursor 
fetch next from backupfiles_cursor into @Position, @DatabaseName, @BackupType
while @@fetch_status = 0
begin

if @password = 'default' and (@option_01 + @option_02 + @option_04) = 1 
begin
set @sql = '
RESTORE '+
case when @BackupType in (1,5) then 'DATABASE' when @BackupType in (2) then 'LOG' end+' '+
case when @new_db_name = 'default' then '['+@DatabaseName+']' else '['+@new_db_name+']' end
+'
FROM DISK = N'+''''+@backupfile+''''+'
WITH FILE = '+cast(@Position as varchar)+','+
case when @BackupType = 1 then @file_move+',' else '' end+'
'+case 
when @filenumber  = 'all' and @lastfile = @position then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
when @filenumber != 'all' then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
else 'NORECOVERY' end+', '+case when @backuptype = 1 then case when @replace = 1 then 'Replace, ' else '' end else '' end+
' NOUNLOAD, STATS = '+cast(@percent as varchar)+case when @backuptype = 2 and @log_stopat != 'default' then ', '+@log_stopat else '' end 

end

else if @password = 'default' and @option_03 = 1
begin

set @sql = '
RESTORE '+
case when @BackupType in (1,5) then 'DATABASE' when @BackupType in (2) then 'LOG' end+' '+
case when @new_db_name = 'default' then '['+@DatabaseName+']' else '['+@new_db_name+']' end
+'
FROM DISK = N'+''''+@backupfile+''''+'
WITH FILE = '+cast(@Position as varchar)+','+
case when @BackupType = 1 then @file_move_data+','+@file_move_log+',' else '' end+'
'+case 
when @filenumber  = 'all' and @lastfile = @position then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
when @filenumber != 'all' then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
else 'NORECOVERY' end+', '+case when @backuptype = 1 then case when @replace = 1 then 'Replace, ' else '' end else '' end+
' NOUNLOAD, STATS = '+cast(@percent as varchar)+case when @backuptype = 2 and @log_stopat != 'default' then ', '+@log_stopat else '' end 

end

if @action = 1
begin
	print(@sql)
end
else if @action = 2
begin
	exec(@sql)
end
else if @action = 3
begin
	print(@sql)
	exec(@sql)
end

fetch next from backupfiles_cursor into @Position, @DatabaseName, @BackupType
end
close backupfiles_cursor 
deallocate backupfiles_cursor 
set nocount off
end
go

CREATE 
PROCEDURE [dbo].[automatic_database_restore]
( 
@before_date				datetime		= '2022-12-07 05:00:00', 
@db_restore_name			varchar(500)	= 'T24Prod',
@username					varchar(100)	= 'T24login',
--@locations parameter used for any restore request on December 2022 and to use it make @workaround_loc = 1
@locations					varchar(max)	= '\\npci2.d2fs.albilad.com\T24_BK_staging_FULL\;\\npci2.d2fs.albilad.com\T24_BK_staging\DIFF\;\\npci2.d2fs.albilad.com\T24_BK_staging_LOGS\',
@workaround_loc				bit				= 1,
--@SDC_backup_path & @PDC_backup_path parameters used for any restore request befor December 2022 and to use those pathes make @workaround_loc = 0
@SDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\',
@PDC_backup_path			varchar(1000)	= '\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\',
--if the restore has any issues and stopped after some backup files like after differential the logs unable to restore for some reseans you can continue after the diffential 
--by add in this parameter @continue_after_file_number = 2 "this is an example"
@continue_after_file_number int				= 0,
@dbrecovery					bit				= 1,
@action						int				= 1
--1 = show backup files
--2 = begin restore 
--3 = 1 + 2
)
as
begin
declare @final_table table (id int identity(1,1), backup_type varchar(100), backup_time_from datetime, backup_time_to datetime, 
backup_file_name varchar(1000), with_stopat varchar(100), [recovery] tinyint)

declare @backup_files table (backup_type varchar(10), backup_time datetime, backup_file_name varchar(2000))
declare @full table (output_text varchar(1000), directory varchar(3000))
declare @diff table (output_text varchar(1000), directory varchar(3000))
declare @logs table (output_text varchar(1000), directory varchar(3000))
declare 
@xp_folder_full_f_SDC		varchar(1000),
@xp_folder_full_f_PDC		varchar(1000),
@xp_folder_full_t_SDC		varchar(1000),
@xp_folder_full_t_PDC		varchar(1000),
@xp_folder_diff_f_SDC		varchar(1000),
@xp_folder_diff_f_PDC		varchar(1000),
@xp_folder_diff_t_SDC		varchar(1000),
@xp_folder_diff_t_PDC		varchar(1000),
@xp_folder_logs_f_SDC		varchar(1000),
@xp_folder_logs_f_PDC		varchar(1000),
@xp_folder_logs_t_SDC		varchar(1000),
@xp_folder_logs_t_PDC		varchar(1000),
@month_f					varchar(20),
@month_t					varchar(20),
@year_f						varchar(4),
@year_t						varchar(4),
@date_time_f				datetime,
@date_time_t				datetime,
@directory_map				varchar(2000),
@backup_type				varchar(4),
@backup_time				datetime, 
@backup_time_from			datetime, 
@backup_time_to				datetime, 
@backup_file_name			varchar(2000), 
@stopat						varchar(100),
@recovery					tinyint,
@max_id						int, 
@max_file_name				varchar(2000),
@error						varchar(2000),
@add_username				varchar(2000),
@change_recovery_setting	varchar(1000)

declare 
@backup_pathes_workaround varchar(2000),
@xp_backup_pathes_workaround varchar(2000)
set nocount on

declare @sql_restore_header varchar(max)
declare @table_header table (
col01 varchar(500),col02 varchar(500),col03 varchar(500),col04 varchar(500),col05 varchar(500),col06 varchar(5),
col07 varchar(max),col08 varchar(100),col09 varchar(500),DatabaseName varchar(500),col11 varchar(max),
col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),CheckpointLSN numeric(25),DatabaseBackupLSN numeric(25),BackupStartDate datetime,
BackupFinishDate datetime,col18 varchar(max),col19 varchar(max),col20 varchar(max),col21 varchar(max),
col22 varchar(max),col23 varchar(max),col24 varchar(max),col25 varchar(max),col26 varchar(max),
col27 varchar(max),col28 varchar(max),col29 varchar(max),col30 varchar(max),col31 varchar(max),
col32 varchar(max),col33 varchar(max),col34 varchar(max),col35 varchar(max),col36 varchar(max),
col37 varchar(max),col38 varchar(max),col39 varchar(max),col40 varchar(max),col41 varchar(max),
col42 varchar(max),col43 varchar(max),col44 varchar(max),col45 varchar(max),col46 varchar(max),
col47 varchar(100),BackupTypeDescription varchar(max),col49 varchar(max),col50 varchar(100),col51 varchar(max),
col52 varchar(max),col53 varchar(max),col54 varchar(max), backup_file_name varchar(max))

select 
@date_time_f = convert(varchar(10), dateadd(day, -10, @before_date),120), 
@year_f = year(dateadd(day, -10, @before_date)),
@month_f = case month(dateadd(day, -10, @before_date))
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end,
@date_time_t = DATEADD(HOUR, 1, @before_date),
@year_t = year(DATEADD(HOUR, 1, @before_date)),
@month_t = case month(DATEADD(HOUR, 1, @before_date))
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end

if @workaround_loc = 0
begin
if month(@date_time_f) = month(@date_time_t)
begin 
set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

end
else if month(@date_time_f) != month(@date_time_t)
begin 

set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_t_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_full_t_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_t_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_t_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_t_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_t_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_full_t_SDC)
print(@xp_folder_full_t_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_diff_t_SDC)
print(@xp_folder_diff_t_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)
print(@xp_folder_logs_t_SDC)
print(@xp_folder_logs_t_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_SDC
update @full set directory = replace(substring(@xp_folder_full_t_SDC,charindex('\',@xp_folder_full_t_SDC),len(@xp_folder_full_t_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_PDC
update @full set directory = replace(substring(@xp_folder_full_t_PDC,charindex('\',@xp_folder_full_t_PDC),len(@xp_folder_full_t_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_SDC
update @diff set directory = replace(substring(@xp_folder_diff_t_SDC,charindex('\',@xp_folder_diff_t_SDC),len(@xp_folder_diff_t_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_PDC
update @diff set directory = replace(substring(@xp_folder_diff_t_PDC,charindex('\',@xp_folder_diff_t_PDC),len(@xp_folder_diff_t_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_SDC
update @logs set directory = replace(substring(@xp_folder_logs_t_SDC,charindex('\',@xp_folder_logs_t_SDC),len(@xp_folder_logs_t_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_PDC
update @logs set directory = replace(substring(@xp_folder_logs_t_PDC,charindex('\',@xp_folder_logs_t_PDC),len(@xp_folder_logs_t_PDC)),'"','') where directory is null

end
end
else
begin
declare cursor_pathes cursor fast_forward
for
select value from master.dbo.Separator(@locations,';')

open cursor_pathes 
fetch next from cursor_pathes into @backup_pathes_workaround
while @@FETCH_STATUS = 0
begin

set @xp_backup_pathes_workaround = 'dir cd "'+@backup_pathes_workaround+'"'
print(@xp_backup_pathes_workaround)

if @backup_pathes_workaround like '%Full%'
begin
insert into @full (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @full set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
else
if @backup_pathes_workaround like '%DIFF%'
begin
insert into @diff (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @diff set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
else
if @backup_pathes_workaround like '%LOGS%'
begin
insert into @logs (output_text) exec xp_cmdshell @xp_backup_pathes_workaround
update @logs set directory = replace(substring(@xp_backup_pathes_workaround,charindex('\',@xp_backup_pathes_workaround),len(@xp_backup_pathes_workaround)),'"','') where directory is null
end
fetch next from cursor_pathes into @backup_pathes_workaround
end
close cursor_pathes
deallocate cursor_pathes

end

--select * from @full 
--select * from @diff 
--select * from @logs 

--all above are only to get the backup files from which months like it's from july and august on the same year or only on august of this year

insert into @backup_files
(backup_type, backup_time, backup_file_name)
select distinct 'full' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @full
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select distinct 'diff' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @diff
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select distinct 'log' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @logs
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'

-- here to insert into @backup_files all backup files on the whole chosen month(s)

declare restore_header_cursor cursor fast_forward
for
select backup_file_name 
from @backup_files

open restore_header_cursor
fetch next from restore_header_cursor into @backup_file_name
while @@FETCH_STATUS = 0
begin

set @sql_restore_header = 'restore headeronly from disk = '+''''+@backup_file_name+''''

insert into @table_header
([col01], [col02], [col03], [col04], [col05], [col06], [col07], [col08], [col09], [DatabaseName], [col11], [col12], [col13], [col14], [col15], 
[CheckpointLSN], [DatabaseBackupLSN], [BackupStartDate], [BackupFinishDate], [col18], [col19], [col20], [col21], [col22], [col23], [col24], [col25], 
[col26], [col27], [col28], [col29], [col30], [col31], [col32], [col33], [col34], [col35], [col36], [col37], [col38], [col39], [col40], [col41], [col42], 
[col43], [col44], [col45], [col46], [col47], [BackupTypeDescription], [col49], [col50], [col51], [col52], [col53], [col54])
exec(@sql_restore_header)

update @table_header set backup_file_name = @backup_file_name where backup_file_name is null

fetch next from restore_header_cursor into @backup_file_name
end
close restore_header_cursor
deallocate restore_header_cursor

declare 
@full_backup_end_date datetime, @checkpointLSN numeric(25),
@diff_backup_end_date datetime,
@logs_backup_end_date datetime,
@backup_file_full_path varchar(3000)

select @full_backup_end_date = 
max(BackupFinishDate), @checkpointLSN = CheckpointLSN
from @table_header
where BackupFinishDate <= @before_date
and BackupTypeDescription = 'Database'
group by CheckpointLSN

select @diff_backup_end_date = 
max(BackupFinishDate)
from @table_header
where BackupfinishDate between @full_backup_end_date and @before_date 
and BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN

select @logs_backup_end_date =
max(BackupStartDate)
from (
select 
BackupStartDate,
case when @before_date between isnull(LAG(BackupStartDate,1) over(order by BackupStartDate ),0) and BackupStartDate
then 1 else 0 end end_file
from @table_header
where BackupTypeDescription = 'Transaction Log'
and DatabaseBackupLSN = @checkpointLSN
and BackupStartDate >= isnull(@diff_backup_end_date, @full_backup_end_date))a
where end_file = 1

select @directory_map = directorys_map 
from master.dbo.restore_loction_groups

insert into @final_table
select BackupTypeDescription, BackupStartDate, BackupFinishDate, backup_file_name, [with_stopat],
case when id = total_files then 1 else 0 end [recovery]
from (
select row_number() over(order by BackupStartDate) id, count(*) over() total_files, BackupTypeDescription, BackupStartDate, BackupFinishDate, 
case 
when BackupTypeDescription = 'Transaction Log' and last_file = 1 then 'STOPAT = '+''''+convert(varchar(40), @before_date, 120)+''''+'' 
else 'default' end [with_stopat], backup_file_name
from (
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Database'
and checkpointLSN = @checkpointLSN
and BackupFinishDate = @full_backup_end_date
union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN
and BackupFinishDate = @diff_backup_end_date
union 
select DatabaseName, BackupTypeDescription, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, backup_file_name, 
case when count(*) over() = row_number() over(order by BackupStartDate) then 1 else 0 end last_file
from @table_header
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate >= isnull(@diff_backup_end_date, @full_backup_end_date) 
and BackupStartDate <= @logs_backup_end_date)a)b
order by BackupStartDate 

--and here to filler out the specific backup files 

if @action in (1)
begin
	select * from @final_table
	where id > @continue_after_file_number
	and id <= (select id from @final_table where recovery = 1)
	order by backup_time_from 
end
else
if @action in (2,3)
begin
	if @action in (3)
	begin
		select * from @final_table
		where id > @continue_after_file_number
		and id <= (select id from @final_table where recovery = 1)
		order by backup_time_from 
	end

	select @max_id = id - @continue_after_file_number, @max_file_name = backup_file_name
	from @final_table
	where id in (select max(id) from @final_table where id <= (select id from @final_table where recovery = 1))
	and id > @continue_after_file_number
	
	declare restore_cur cursor fast_forward
	for
	select backup_file_name, [with_stopat], [recovery]
	from @final_table
	where id > @continue_after_file_number
	and id <= (select id from @final_table where recovery = 1)
	order by id

	update master.dbo.restore_notification set status = 1

	insert into master.dbo.restore_notification
	(database_name, status, start_time, total_files, current_file, last_file_name)
	values
	(@db_restore_name, 0, getdate(), @max_id, 1, @max_file_name)

	exec master.[dbo].[kill_sessions_before_restore] @type = 'database', @name = @db_restore_name
	exec master.[dbo].[kill_sessions_before_restore] @type = 'database', @name = @db_restore_name

	EXEC msdb.dbo.sp_update_job  
    @job_name = N'Notification Restore',  
    @enabled = 1  

	exec dbo.XEvent_errors @@spid

	open restore_cur 
	fetch next from restore_cur into @backup_file_name, @stopat, @recovery
	while @@fetch_status = 0
	begin
			exec [master].[dbo].[sp_restore_database_distribution_groups]
			@backupfile					= @backup_file_name,
			@option_04					= 1,
			@number_of_files_per_type	= '2-4',  --"2" is the file type id, and "4" is the number of files per location
			@restore_loction_groups		= @directory_map,
			@with_recovery				= @recovery,  
			@new_db_name				= @db_restore_name,
			@percent					= 5,
			@replace					= 1,
			@log_stopat					= @stopat,
			@action						= 3

			update master.dbo.restore_notification 
			set 
			status				= case when @max_id = (select current_file from restore_notification where status = 0) + 1 + @continue_after_file_number then 1 else 0 end,
			finish_time			= case when @max_id = (select current_file from restore_notification where status = 0) + 1 + @continue_after_file_number then getdate() else null end,
			current_file		= current_file + 1 + @continue_after_file_number
			where status		= 0
			and database_name	= @db_restore_name

	fetch next from restore_cur into @backup_file_name, @stopat, @recovery
	end
	close restore_cur
	deallocate restore_cur
end
set nocount off


if	(select count(*) from master.dbo.restore_notification where status = 0) = 0 and
	(select enabled from msdb.dbo.sysjobs where name = 'Notification Restore') = 1
begin

	exec [master].[dbo].[sp_notification_restore]
			@done = 1,
			@ccteam = 't24 team'
	exec [msdb].[dbo].[sp_update_job]  
			@job_name = 'Notification Restore',  
			@enabled = 0

set @add_username = 'use ['+@db_restore_name+']
declare @username varchar(300)
declare @loginname varchar(300)

select @username = name 
from sys.sysusers 
where issqlrole = 0
and name = '+''''+@username+''''+'

select @loginname = loginname 
from sys.syslogins 
where loginname = '+''''+@username+''''+'

if @username is not null and @loginname is not null
begin
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end
else
if @username is null and @loginname is not null
begin
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is not null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end'
exec(@add_username)

if @dbrecovery = 1
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	exec(@change_recovery_setting)
end

exec master.dbo.set_compatibility @db_restore_name
end

set @add_username = 'use ['+@db_restore_name+']
declare @username varchar(300)
declare @loginname varchar(300)

select @username = name 
from sys.sysusers 
where issqlrole = 0
and name = '+''''+@username+''''+'

select @loginname = loginname 
from sys.syslogins 
where loginname = '+''''+@username+''''+'

if @username is not null and @loginname is not null
begin
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end
else
if @username is null and @loginname is not null
begin
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	CREATE USER ['+@username+'] FOR LOGIN ['+@username+']
	ALTER ROLE [db_owner] ADD MEMBER ['+@username+']
end
else
if @username is not null and @loginname is null
begin
	CREATE LOGIN ['+@username+'] WITH PASSWORD=''Aa123456'', DEFAULT_DATABASE = ['+@db_restore_name+'], CHECK_POLICY=off,CHECK_EXPIRATION=off
	ALTER USER ['+@username+'] WITH LOGIN = ['+@username+'] 
end'
if @action = 1
begin
print(@add_username)
if @dbrecovery = 1
begin
	set @change_recovery_setting = 'use [master] 
	ALTER DATABASE ['+@db_restore_name+'] SET RECOVERY SIMPLE'
	print(@change_recovery_setting)
end
end
report:
if @action in (2,3)
begin
exec [dbo].[errors_email] 
@project_name			 ='T24SDC6 restore',
@ccteam					 = 'T24 Team', 
@dba_in_to				 = 'ALBILAD\c904529',
@with_cc				 = 1,
@spid					 = @@spid
exec [dbo].[XEvent_errors] @@spid, 0
end
end


go
USE [msdb]
GO

/****** Object:  Job [Notification Restore]    Script Date: 7/7/2022 1:47:28 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/7/2022 1:47:28 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16), @login_name nvarchar(100)
select @login_name = name 
from sys.syslogins 
where sid = 0x01

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Notification Restore', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [send_step]    Script Date: 7/7/2022 1:47:28 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'send_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[sp_notification_restore] @ccteam = ''t24 team''

--exec [dbo].[sp_notification_restore] @ccteam = ''''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sche_e30mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220706, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'5c0c286b-6e7a-4b37-b7aa-4e98ef817e5c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

USE [msdb]
GO
DECLARE @jobId BINARY(16), @login_name nvarchar(100)
select @login_name = name 
from sys.syslogins 
where sid = 0x01

/****** Object:  Job [Automatic Restore Job]    Script Date: 9/8/2022 12:46:31 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/8/2022 12:46:32 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

--DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Automatic Restore Job', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name , @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [restore_step]    Script Date: 9/8/2022 12:46:32 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'restore_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare 
@before_date		datetime,
@db_restore_name		varchar(500),
@username		varchar(500),
@workaround_locations	varchar(3000),
@is_using_workaround	bit

select 
@before_date		= before_date,
@db_restore_name		= db_restore_name,
@username		= username,
@workaround_locations 	= workaround_locations,
@is_using_workaround = case when @before_date < ''2022-12-01'' then 0 else 1 end
from master.dbo.auto_restore_job_parameters

exec dbo.automatic_database_restore
@before_date		 = @before_date, 
@db_restore_name		 = @db_restore_name,
@username		 = @username,
@locations		 = @workaround_locations,
@workaround_loc		 = @is_using_workaround,		-- 0 before December
@continue_after_file_number = 0,
@action			 = 2
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sch_onetime', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220905, 
		@active_end_date=99991231, 
		@active_start_time=164100, 
		@active_end_time=235959, 
		@schedule_uid=N'9e6702aa-2b53-4138-b97f-619246a42198'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
