declare @app_name varchar(1000)
select @app_name = [app_name] from dbo.server_details
select @app_name

exec [dbo].[server_disk_state_email] 
@project_name		= @app_name, 
@ccteam				= '', 
@with_cc			= 0,
@threshold			= 85,
@exceed_threshold	= 0

