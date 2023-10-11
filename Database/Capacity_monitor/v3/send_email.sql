declare @app_name varchar(1000), @cmd varchar(1000), @waitfor varchar(20), @wait_seconds int = 90
select @app_name = [app_name] from dbo.server_details
set @waitfor = convert(varchar(10), dateadd(s, @wait_seconds, '2000-01-01'), 108)

--set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Start-ScheduledTask -TaskName ''''Disks_style''''}"'''
--print(@cmd)
--exec(@cmd)
--waitfor delay @waitfor
--select @app_name

exec [dbo].[server_disk_state_email] 
@project_name		= @app_name, 
@ccteam				= '', 
@with_cc			= 1,
@threshold			= 85,
@exceed_threshold	= 0
