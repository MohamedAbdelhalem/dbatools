select sp.principal_id, l.sid, loginname, is_disabled, language, denylogin, hasaccess, 
case sysadmin        when 1 then 'sysadmin'			else null end sysadmin, 
case securityadmin   when 1 then 'securityadmin'	else null end securityadmin, 
case serveradmin     when 1 then 'serveradmin'		else null end serveradmin, 
case setupadmin      when 1 then 'setupadmin'		else null end setupadmin, 
case processadmin    when 1 then 'processadmin'		else null end processadmin, 
case diskadmin       when 1 then 'diskadmin'		else null end diskadmin, 
case dbcreator       when 1 then 'dbcreator'		else null end dbcreator, 
case bulkadmin       when 1 then 'bulkadmin'		else null end bulkadmin 
from sys.syslogins l inner join sys.server_principals sp
on l.name = sp.name
where l.name not like '#%'
and l.name not like 'NT SERVICE\%'
and l.name not like 'NT AUTHORITY\%'
and sp.type in ('u','g','s')
