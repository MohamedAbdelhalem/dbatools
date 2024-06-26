USE [master]
GO
if object_id('[dbo].[job_state_email]') is not null
begin
drop Procedure [dbo].[job_state_email]
end
go

CREATE 
Procedure [dbo].[job_state_email] --@project_name = 'Data Hub', @ccteam = '', @with_cc = 0 
(
@project_name			varchar(100),
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

exec master.[dbo].[job_state_html]
@html = @email_body output

set @email_body = '<p><b>Dear '+@dear+'</b>,</p>

<p>Kindly find in the below the job status of the ETL for <b>'+@project_name+'</b>,<p> 

'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'


set @subject = 'ETL Job Status for ('+@project_name+')'

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

--select @db_mail_profile, @email, @ccemail, @subject, @email_body

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end
go

exec [dbo].[job_state_email] 
@project_name		= 'Transfer data to FBNK_FUNDS_TRANSFER#HIS in 10.37.3.25 from 10.38.5.65', 
@ccteam				= 'project', 
@with_cc			= 0


select * from white_list_users
