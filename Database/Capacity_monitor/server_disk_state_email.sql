USE [master]
GO
/****** Object:  StoredProcedure [dbo].[server_disk_state_email]    Script Date: 9/28/2022 12:06:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER
Procedure [dbo].[server_disk_state_email] --@project_name = 'CRM - CRM', @ccteam = '', @with_cc = 0, @exceed_threshold = 0
(
@project_name			varchar(100),
@ccteam					varchar(200) = '', 
@dba_in_to				varchar(500) = 'ALBILAD\c904529',
@with_cc				bit = 1,
@threshold				int = 85,
@exceed_threshold		bit = 1)
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

exec master.[dbo].[server_disk_state_HTML]
@html				= @email_body output,
@has_over			= @over_disks output,
@threshold_pct		= @threshold,
@over				= @exceed_threshold

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

if @over_disks > 0
begin
--set @email_body = '<p><b>Dear '+@dear+'</b>,</p>
set @email_body = '<p><b>Dear @Mailgroup Capacity Planning Team</b>,</p>


<p>Kindly your response and support is required for <b>'+@project_name+' database server</b> <b style="color:green;">'+@Server_name+' - '+@IpAddress+'</b>,<p> 
<p>Please find the below disk(s) that highlighted in <b style="color:red;">red</b> that they are already <b style="color:red;">exceeded the threshold,</b></p> 
<p>Please we need to extend this/these disk(s) by adding the size in the <b>recommended_extend_size</b> column to achieve the threshold <b>'+cast(@threshold as varchar)+'%</b>.</p>

'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>


<table style="border:1px solid white;border-collapse:collapse;width: 5%">
<tr bgcolor="white">
<th style="border:1px solid white;background-color: white; color: black">ALERTS</th>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: green; color: white"><'+cast(@threshold as varchar(10))+'%</td>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: red; color: white">>='+cast(@threshold as varchar(10))+'%</td>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: purple; color: white">max 2 TB</td>
</tr>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: black; color: white">max 2 TB + Growth > 0 </td>
</tr>
</table>'
end
else
begin
set @email_body = '<p><b>Dear '+@dear+'</b>,</p>


<p>Kindly find the volume stats for <b>'+@project_name+' database server</b> <b style="color:green;">'+@Server_name+' - '+@IpAddress+'</b>,<p> 

'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>


<table style="border:1px solid white;border-collapse:collapse;width: 5%">
<tr bgcolor="white">
<th style="border:1px solid white;background-color: white; color: black">ALERTS</th>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: green; color: white"><'+cast(@threshold as varchar(10))+'%</td>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: red; color: white">>='+cast(@threshold as varchar(10))+'%</td>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: purple; color: white">max 2 TB</td>
</tr>
</tr>
<tr style="border:1px solid white; text-align: center; vertical-align: left;">
<td style="border:1px solid white; text-align: center; vertical-align: left; background-color: black; color: white">max 2 TB + Growth > 0 </td>
</tr>
</table>'
end

set @subject = 'Capacity management required for this server '+@Server_name+' - '+@IpAddress+' ('+@project_name+')'

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

--select db_mail_profile, email, ccemail, subject, email_body, s.value
--from (
--select @db_mail_profile db_mail_profile, @email email, @ccemail ccemail, @subject subject, @email_body email_body)a cross apply dbo.Separator(email_body, char(10)) s
--order by s.id

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end

