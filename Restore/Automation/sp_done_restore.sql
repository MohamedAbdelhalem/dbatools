USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_done_restore]    Script Date: 8/8/2022 2:33:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_done_restore]
(@ccteam varchar(200))
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
@dear					varchar(500)

select @dear = isnull(@dear+', '+case when id = users and users > 1 then 'and ' else '' end, '') + username
from (
select top 100 percent row_number() over(order by id) id, substring(username,1, charindex(' ',username)-1) username, count(*) over() users
from white_list_users
where is_allowed = 1
and (account_number = 'ALBILAD\c904529'
or team = 't24 team')
order by id)a

set @email_body = '<p><b>Dear '+@dear+'</b>,</p>

<p>Kindly be informed that the restore was <b>completed successfully</b>.</p>

<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'

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

select @database_name = name from [master].sys.databases where database_id > 4
set @subject = 'Restore monitor done '+@Server_name+' - '+@IpAddress+' ('+@database_name+')'

select @ccemail = isnull(@ccemail+';','')+email 
from white_list_users
where send_notification = 1
and is_allowed = 1
and account_number != 'ALBILAD\c904529'

select @email = isnull(@email+';','')+email 
from white_list_users
where is_allowed = 1
and (account_number = 'ALBILAD\c904529'
or team = @ccteam)

exec msdb..sp_send_dbmail 
@profile_name = 'DBAlert', 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end