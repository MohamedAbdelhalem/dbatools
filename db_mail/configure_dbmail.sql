DECLARE 
@profileId	int,
@profile	varchar(255) = 'DBAlert',
@emailid	varchar(255) = 'sqlalerts@bankalbilad.com',
@smtpsrv	varchar(255) = 'babsmtp.albilad.com'
  
EXECUTE msdb.dbo.sysmail_add_profile_sp
@profile_name		= @profile,
@description		= @profile,
@profile_id			= @profileId OUTPUT
  
EXEC msdb.dbo.sysmail_add_account_sp
@account_name		= @profile,
@description		= @profile,
@email_address		= @emailid,
@replyto_address	= @emailid,
@display_name		= @profile,
@mailserver_name	= @smtpsrv

EXEC msdb.dbo.sysmail_add_profileaccount_sp
@profile_name		= @profile,
@account_name		= @profile,
@sequence_number	= 1

EXEC msdb.dbo.sysmail_add_principalprofile_sp
@principal_name		= 'public',
@profile_name		= @profile,
@is_default			= 1
