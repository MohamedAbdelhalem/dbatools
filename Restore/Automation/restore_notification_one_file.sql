declare @email_body varchar(max)
exec master.dbo.Dynamic_restore_HTML_one_file
@html = @email_body output

set @email_body = '<p><b>Dear Team</b>,</p>


<p>Kindly be informed that the restore is <b>in progress</b> and you can find the status in the below table.</p>


'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>
'

declare 
@registry_key1			varchar(1500), 
@system_instance_name	varchar(300), 
@instance_name			varchar(100),
@server_name			varchar(100),
@IpAddress				varchar(50),
@subject				varchar(1000),
@database_name			varchar(500),
@email					varchar(1000)

select 
@server_name = case when charindex('\',name) > 0 then substring(name, 1, charindex('\',name)-1) else name end,
@instance_name = case when charindex('\',name) > 0 then substring(name, charindex('\',name)+1, len(name)) else 'MSSQLSERVER' end
from sys.servers where server_id = 0

EXEC master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
	N'Software\Microsoft\Microsoft SQL Server\Instance Names\SQL',
	@instance_name,
	@system_instance_name OUTPUT;
SET @registry_key1 = N'Software\Microsoft\Microsoft SQL Server\' + @system_instance_name + 
	'\MSSQLServer\supersocketnetlib\TCP\IP1';

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
	@registry_key1,
	@value_name = 'IpAddress',
	@value = @IpAddress OUTPUT

select @database_name = database_name from [master].[dbo].[monitor_restore]
set @subject = 'Restore monitor Progress Bar '+@Server_name+' - '+@IpAddress+' ('+@database_name+')'
--print(@email_body)

select @email = isnull(@email+';','')+email 
from white_list_users
where send_notification = 1

--select * from restore_notification
--select * from monitor_restore
exec msdb..sp_send_dbmail 
@profile_name = 'DBAlert', 
@recipients = @email, 
--@copy_recipients = @ccemails,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

