--parameters
 
CREATE Procedure [dbo].[sync_logins_between_replicas]
(
@show varchar(50) = 'sync',
@replica_name varchar(300) = 'IAUSQLCLS02'
)
as
begin
 
--variables
declare @sql varchar(max), @login_script varchar(max)
declare @table table (principal_id int, sid varbinary(max), loginname varchar(200),is_disabled int,language varchar(200),denylogin int,hasaccess int,
sysadmin varchar(200),securityadmin varchar(200),serveradmin varchar(200),setupadmin varchar(200),processadmin varchar(200),diskadmin varchar(200),dbcreator varchar(200),bulkadmin varchar(200),
replica_name varchar(300))
 
set nocount on
 
insert into @table
select *, 
case when charindex('\',cast(@@servername as varchar(500))) > 0 then substring(cast(@@servername as varchar(500)),1,charindex('\',cast(@@servername as varchar(500)))-1) 
else cast(@@servername as varchar(500)) end 
from [master].dbo.sys_logins
 
if @show = 'sync' and @replica_name != 'default'
begin
set @sql = 'select *, '+''''+@replica_name+''''+' from ['+@replica_name+'].[master].dbo.sys_logins'
insert into @table
exec(@sql)
 
declare logins_cursor cursor fast_forward
for
select script 
from (
select loginname,
'Create Login ['+loginname+'] '+case when charindex('\',loginname) > 0 
then 'From Windows' 
else 'With Password = '+convert(varchar(max),sqll.password_hash,1)+' Hashed, SID = '+convert(varchar(max),sl.sid,1)+', Default_Database = ['+sp.default_database_name+'], Check_Policy = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', Check_Expiration = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
select loginname from @table
where replica_name != @replica_name
except
select loginname from @table
where replica_name  = @replica_name)
 
UNION
 
select loginname, server_roles 
from (
select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
select loginname from @table
where replica_name != @replica_name
except
select loginname from @table
where replica_name  = @replica_name))a)b
where server_roles is null
 
UNION
 
select loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
select loginname from @table
where replica_name != @replica_name
except
select loginname from @table
where replica_name  = @replica_name))a)b cross apply master.dbo.Separator(server_roles, ',')
 
) lo
where script is not null
order by loginname, script desc
 
open logins_cursor
fetch next from logins_cursor into @login_script
while @@FETCH_STATUS = 0
begin
 
set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_name+']'
exec(@sql)
fetch next from logins_cursor into @login_script
end
close logins_cursor
deallocate logins_cursor
 
end
else
begin
 
select loginname, script 
from (
select loginname,
'Create Login ['+loginname+'] '+case when charindex('\',loginname) > 0 
then 'From Windows' 
else 'With Password = '+convert(varchar(max),sqll.password_hash,1)+' Hashed, SID = '+convert(varchar(max),sl.sid,1)+', Default_Database = ['+sp.default_database_name+'], Check_Policy = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', Check_Expiration = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
 
UNION
 
select loginname, server_roles 
from (
select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name)a)b
where server_roles is null

UNION

select loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name)a)b cross apply master.dbo.Separator(server_roles, ',')
 
) lo
where script is not null
order by loginname, script desc
end
set nocount off
----Exec ('Create Login [DBA_Temp] With Password = 0x0200B5868C4C2387D6EDEBF8BEE40E4C5A9C890C35B9CF025088511C04F41EB0B19B2D19B2651EFC65059DC3736DBB1D66A5E03CEA43A923B05382CCBE18FC12BBEB3D44EEE6 Hashed, SID = 0xC86970323776CF4F90EECCA4D88C5B48, Default_Database = [master], Check_Policy = OFF, Check_Expiration = OFF;') AT [IAUSQLCLS02]
end
