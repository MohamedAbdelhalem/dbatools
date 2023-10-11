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
object_id('[dbo].[XEvent_errors]'), 
object_id('[dbo].[error_message]'), 
object_id('[dbo].[errors_email]'), 
object_id('[dbo].[Dynamic_error_HTML]'), 
object_id('[dbo].[kill_sessions_before_restore]')
)
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
