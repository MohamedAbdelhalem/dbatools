USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_notification_table_change]    Script Date: 10/9/2022 12:55:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_notification_table_change] (
@syntax					varchar(max),
@with_cc				bit = 0,
@ccteam					varchar(200) = '', 
@dba_in_to				varchar(500) = 'ALBILAD\c904529')
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

declare 
@command varchar(500),
@sub_command varchar(500),
@table_name varchar(500),
@column_name varchar(500),
@function_name varchar(500),
@index_name varchar(500)

select @command = command, @sub_command = sub_command, @table_name = table_name, @column_name = column_name, @function_name = fn_name, @index_name = index_name 
from master.dbo.text_analysis(ltrim(rtrim(@syntax)))

set @email_body = '<p><b>Dear '+@dear+'</b>,</p>

<p>Kindly be informed that the <b style="color:green;">'+@command+'</b> statement to <b>'+@sub_command+'</b> has been completed on <b style="color:Salmon;">'+@table_name+'</b> to '+
case 
when @sub_command in('add compute column','add column') then 'add column ' 
else '' end+'<b style="color:purple;">'+@column_name+'</b>.</p>

<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'

set @subject = 'Alter table completed notification on database (T24PROD_UAT)'

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

