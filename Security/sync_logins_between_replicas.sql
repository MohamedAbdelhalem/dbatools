use [master]
GO
--Create linked server and the below view and procedure in each replica. 
GO
CREATE
--ALTER
View dbo.sys_logins
as
select sp.principal_id, l.sid, l.loginname, l.isntname, sp.is_disabled, l.language, l.denylogin, l.hasaccess, 
case sysadmin        when 1 then 'sysadmin'		else null end sysadmin, 
case securityadmin   when 1 then 'securityadmin'	else null end securityadmin, 
case serveradmin     when 1 then 'serveradmin'		else null end serveradmin, 
case setupadmin      when 1 then 'setupadmin'		else null end setupadmin, 
case processadmin    when 1 then 'processadmin'		else null end processadmin, 
case diskadmin       when 1 then 'diskadmin'		else null end diskadmin, 
case dbcreator       when 1 then 'dbcreator'		else null end dbcreator, 
case bulkadmin       when 1 then 'bulkadmin'		else null end bulkadmin,
sqll.password_hash, sp.default_database_name, sqll.is_policy_checked, sqll.is_expiration_checked
from sys.syslogins l inner join sys.server_principals sp
on l.name = sp.name
left outer join sys.sql_logins sqll
on l.loginname = sqll.name
where l.name not like '#%'
and l.name not like 'NT SERVICE\%'
and l.name not like 'NT AUTHORITY\%'
and sp.type in ('u','g','s')

go

CREATE
--ALTER
Procedure [dbo].[sync_logins_between_replicas]
(
--parameters
@action varchar(50) = 'sync', 
--Accepted values: 
--"local"-------To display all logins only on the local replica.
--"all"---------To display all logins both locally the other replicas as well.
--"mismatch"----To present the mislogins in the other replicas.
--"sync"--------To create the mismatched logins that not exist on the secondary replicas.
@replica_name varchar(300) = '<replica name>'
--Accepted values: 
--"default"-----------means no replica.
--"<replica name>"----means no replica.
--"all"---------------indicates that the current replica is primary one while all other replicas.
--It will search across replicas apply the findings.
--This requires create linked for all replicas.
)
as
begin
 
--variables
declare @sql varchar(max), 
@login_script varchar(max),
@replica_server_name varchar(500),
@replica_server_name_nc2 varchar(500),
@loginname varchar(300),
@type	varchar(20)

declare @table table (
principal_id int, sid varbinary(max), loginname varchar(200), isntname int,
is_disabled int,language varchar(200),denylogin int,hasaccess int,
sysadmin varchar(200),securityadmin varchar(200),serveradmin varchar(200),setupadmin varchar(200),processadmin varchar(200),diskadmin varchar(200),dbcreator varchar(200),bulkadmin varchar(200),
password_hash varbinary(max), default_database_name varchar(255), is_policy_checked int, is_expiration_checked int,
replica_name varchar(300))

declare @mismatch_logins table (loginname varchar(200))
declare @mismatch_logins_sid table (loginname varchar(200), replica_name varchar(300), isntname int,
sid varbinary(100), password_hash varbinary(max), default_database_name varchar(255), is_policy_checked int, is_expiration_checked int, 
is_disabled int,language varchar(200),denylogin int,hasaccess int)

declare @mismatch_final table (replica_name varchar(300), loginname varchar(200), script varchar(max), opt varchar(20), type varchar(20))

set nocount on
 
insert into @table
select *, 
case when charindex('\',cast(@@servername as varchar(500))) > 0 then substring(cast(@@servername as varchar(500)),1,charindex('\',cast(@@servername as varchar(500)))-1) 
else cast(@@servername as varchar(500)) end 
from [master].dbo.sys_logins

declare @dm_hadr_availability_replica_states table (is_local int, replica_server_name varchar(200))
insert into @dm_hadr_availability_replica_states
select is_local, rcs.replica_server_name 
from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
on rs.replica_id = rcs.replica_id

--------------------------------------------------
--To display all logins only on the local replica.
--------------------------------------------------
if @action = 'local' 
begin
 
select loginname, script 
from (
select loginname,
'CREATE LOGIN ['+loginname+'] '+case isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),password_hash,1)+' HASHED, SID = '+convert(varchar(max),sid,1)+', DEFAULT_DATABASE = ['+default_database_name+'], CHECK_POLICY = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl

UNION

select loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl)a)b cross apply master.dbo.Separator(server_roles, ',')
 
) lo
where script is not null
order by loginname, script desc
end
----------------------------------------------------------------------------------------------
--Display allins across replicas, a replica, or only theatched logins. 
--Whether they are missing a role or the logins are identical but have different SIDs.
--Based on the primary replica
----------------------------------------------------------------------------------------------
else 
if @action in ('all','mismatch') and @replica_name not in ('default','<replica name>')
begin

if @replica_name = 'all'
begin
	declare replica_cursor cursor fast_forward
	for
	select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1
	open replica_cursor
	fetch next from replica_cursor into @replica_server_name
	while @@FETCH_STATUS = 0
	begin
		set @sql = 'select *, '+''''+@replica_server_name+''''+' from ['+@replica_server_name+'].[master].dbo.sys_logins'
		insert into @table
		exec(@sql)
	fetch next from replica_cursor into @replica_server_name
	end
	close replica_cursor
	deallocate replica_cursor
end
else
if @replica_name in (select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1)
begin
set @sql = 'select *, '+''''+@replica_name+''''+' from ['+@replica_name+'].[master].dbo.sys_logins'
insert into @table
exec(@sql)
end

if @action = 'all'
begin
select replica_name, loginname, script
from (
select replica_name, loginname,
'CREATE LOGIN ['+loginname+'] '+case isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),password_hash,1)+' HASHED, SID = '+convert(varchar(max),sid,1)+', DEFAULT_DATABASE = ['+default_database_name+'], CHECK_POLICY = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl

UNION
 
select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select replica_name, loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl)a)b cross apply master.dbo.Separator(server_roles, ',')

) lo
where script is not null
order by loginname, replica_name, script desc

end
else
if @action = 'mismatch'
begin

insert into @mismatch_logins
select distinct loginname
from (
select count(*) [count], loginname, sid, sysrole
from (
select loginname, sid,
isnull(sysadmin,'')+isnull(securityadmin,'')+isnull(serveradmin,'')+isnull(setupadmin,'')+isnull(processadmin,'')+isnull(diskadmin,'')+isnull(dbcreator,'')+isnull(bulkadmin,'')
sysrole
from @table)a
group by loginname, sid, sysrole
having count(*) >= 1
and count(*) < (select count(*) from @dm_hadr_availability_replica_states))b

insert into @mismatch_logins_sid 
select a.primary_loginname, b.replica_name, a.isntname,
a.primary_sid, a.password_hash, a.default_database_name, a.is_policy_checked, a.is_expiration_checked, 
a.is_disabled, a.language, a.denylogin, a.hasaccess
from (
select loginname primary_loginname, sid primary_sid, 
isntname, password_hash, default_database_name, is_policy_checked, is_expiration_checked, 
is_disabled, language, denylogin, hasaccess, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1))a
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on a.primary_loginname = b.secondary_loginname
where a.primary_sid != b.secondary_sid

insert into @mismatch_final 
select replica_name, loginname, 
case when type = 'MODIFY' and opt = 'CREATE' then 'DROP LOGIN ['+loginname+']; '+script else script end, 
case when type = 'MODIFY' and opt = 'CREATE' then 'DROP/CREATE' else opt end opt, type
from (
select a.replica_name, a.loginname,
'CREATE LOGIN ['+a.loginname+'] '+case c.isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),c.password_hash,1)+' HASHED, SID = '+convert(varchar(max),c.sid,1)+', DEFAULT_DATABASE = ['+c.default_database_name+'], CHECK_POLICY = '+case c.is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case c.is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script, 'CREATE' opt, 'MODIFY' type
from @mismatch_logins_sid a inner join (
select loginname, sid 
from @mismatch_logins_sid
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0)
except
select loginname, sid 
from @mismatch_logins_sid
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
)b
on a.loginname = b.loginname
and a.sid = b.sid
inner join (select loginname, isntname, sid, password_hash, default_database_name, is_policy_checked, is_expiration_checked
from @table
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)) c
on c.loginname = a.loginname

UNION 

--mismatch server roles
select replica_name, loginname, script, 'ADD', 'MODIFY'
from (
select loginname, replica_name, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select loginname, replica_name, case when charindex(',',mismatch_server_role) > 0 and len(mismatch_server_role) > 5 then substring(mismatch_server_role,1,len(mismatch_server_role)-1) else null end mismatch_server_role
from (
select loginname, replica_name, 
isnull(case when [sysadmin] is null and sum_sysadmin > 0 then 'sysadmin' when [sysadmin] is not null then null else null end+',','')+
isnull(case when [securityadmin] is null and [sum_securityadmin] > 0 then 'securityadmin' when [securityadmin] is not null then null else null end+',','')+
isnull(case when [serveradmin] is null and [sum_serveradmin] > 0 then 'serveradmin' when [serveradmin] is not null then null else null end+',','')+
isnull(case when [setupadmin] is null and [sum_setupadmin] > 0 then 'setupadmin' when [setupadmin] is not null then null else null end+',','')+
isnull(case when [processadmin] is null and [sum_processadmin] > 0 then 'processadmin' when [processadmin] is not null then null else null end+',','')+
isnull(case when [diskadmin] is null and [sum_diskadmin] > 0 then 'diskadmin' when [diskadmin] is not null then null else null end+',','')+
isnull(case when [dbcreator] is null and [sum_dbcreator] > 0 then 'dbcreator' when [dbcreator] is not null then null else null end+',','')+
isnull(case when [bulkadmin] is null and [sum_bulkadmin] > 0 then 'bulkadmin' when [bulkadmin] is not null then null else null end+',','') mismatch_server_role
from (
select loginname, replica_name,
[sysadmin],
sum(case when [sysadmin] is null then 0 else 1 end)over(partition by loginname order by loginname) [sum_sysadmin], 
[securityadmin],
sum(case when [securityadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_securityadmin], 
[serveradmin],
sum(case when [serveradmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_serveradmin], 
[setupadmin],
sum(case when [setupadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_setupadmin], 
[processadmin],
sum(case when [processadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_processadmin], 
[diskadmin],
sum(case when [diskadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_diskadmin], 
[dbcreator],
sum(case when [dbcreator] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_dbcreator], 
[bulkadmin],
sum(case when [bulkadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_bulkadmin]
from @table sl
where loginname in (select loginname from @mismatch_logins))a)b)c cross apply master.dbo.Separator(mismatch_server_role, ','))d
where script is not null

UNION

select ars.replica_server_name , ars.loginname,
'CREATE LOGIN ['+ars.loginname+'] '+case a.isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),a.password_hash,1)+' HASHED, SID = '+convert(varchar(max),a.sid,1)+', DEFAULT_DATABASE = ['+a.default_database_name+'], CHECK_POLICY = '+case a.is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case a.is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script, 'CREATE' opt, 'NEW' type
from (select is_local, replica_server_name, loginname from @mismatch_logins cross apply @dm_hadr_availability_replica_states) ars
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on b.secondary_loginname = ars.loginname
and ars.replica_server_name = b.replica_name
inner join @table a
on a.loginname = ars.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where is_local = 0
and b.replica_name is null

UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script, 'ADD' opt, 'NEW' type
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select ars.replica_server_name replica_name, ars.loginname, isnull(a.sysadmin+',','')+isnull(a.securityadmin+',','')+isnull(a.serveradmin+',','')+isnull(a.setupadmin+',','')+isnull(a.processadmin+',','')+isnull(a.diskadmin+',','')+isnull(a.dbcreator+',','')+isnull(a.bulkadmin+',','') server_roles
from (select is_local, replica_server_name, loginname from @mismatch_logins cross apply @dm_hadr_availability_replica_states) ars
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on b.secondary_loginname = ars.loginname
and ars.replica_server_name = b.replica_name
inner join @table a
on a.loginname = ars.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where is_local = 0
and b.replica_name is null
)a)b cross apply master.dbo.Separator(server_roles, ',')
)lo3
order by loginname, replica_name, script desc

--------------
--Final result
--------------
select replica_name, loginname, script, opt, type 
from @mismatch_final

UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script, 'DROP/ADD' opt, 'MODIFY' type
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select mf.replica_name replica_name, mf.loginname, isnull(a.sysadmin+',','')+isnull(a.securityadmin+',','')+isnull(a.serveradmin+',','')+isnull(a.setupadmin+',','')+isnull(a.processadmin+',','')+isnull(a.diskadmin+',','')+isnull(a.dbcreator+',','')+isnull(a.bulkadmin+',','') server_roles
from @mismatch_final mf inner join @table a
on mf.loginname = a.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where opt = 'DROP/CREATE' and type = 'MODIFY')b)c cross apply master.dbo.Separator(server_roles, ',')
order by loginname, replica_name, script desc

end
end
----------------------------------------------------------------------------
--To create the mismatched logins that not exist on the secondary replicas.
----------------------------------------------------------------------------
else 
if @action = 'sync' and @replica_name not in ('default','<replica name>')
begin

if @replica_name = 'all'
begin
	declare replica_cursor cursor fast_forward
	for
	select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1
	open replica_cursor
	fetch next from replica_cursor into @replica_server_name
	while @@FETCH_STATUS = 0
	begin
		set @sql = 'select *, '+''''+@replica_server_name+''''+' from ['+@replica_server_name+'].[master].dbo.sys_logins'
		insert into @table
		exec(@sql)
	fetch next from replica_cursor into @replica_server_name
	end
	close replica_cursor
	deallocate replica_cursor
end
else
if @replica_name in (select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1)
begin
set @sql = 'select *, '+''''+@replica_name+''''+' from ['+@replica_name+'].[master].dbo.sys_logins'
insert into @table
exec(@sql)
end

insert into @mismatch_logins
select distinct loginname
from (
select count(*) [count], loginname, sid, sysrole
from (
select loginname, sid,
isnull(sysadmin,'')+isnull(securityadmin,'')+isnull(serveradmin,'')+isnull(setupadmin,'')+isnull(processadmin,'')+isnull(diskadmin,'')+isnull(dbcreator,'')+isnull(bulkadmin,'')
sysrole
from @table)a
group by loginname, sid, sysrole
having count(*) >= 1
and count(*) < (select count(*) from @dm_hadr_availability_replica_states))b

insert into @mismatch_logins_sid 
select a.primary_loginname, b.replica_name, a.isntname,
a.primary_sid, a.password_hash, a.default_database_name, a.is_policy_checked, a.is_expiration_checked, 
a.is_disabled, a.language, a.denylogin, a.hasaccess
from (
select loginname primary_loginname, sid primary_sid, 
isntname, password_hash, default_database_name, is_policy_checked, is_expiration_checked, 
is_disabled, language, denylogin, hasaccess, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1))a
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on a.primary_loginname = b.secondary_loginname
where a.primary_sid != b.secondary_sid

insert into @mismatch_final 
select replica_name, loginname, 
case when type = 'MODIFY' and opt = 'CREATE' then 'DROP LOGIN ['+loginname+']; '+script else script end, 
case when type = 'MODIFY' and opt = 'CREATE' then 'DROP/CREATE' else opt end opt, type
from (
select a.replica_name, a.loginname,
'CREATE LOGIN ['+a.loginname+'] '+case c.isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),c.password_hash,1)+' HASHED, SID = '+convert(varchar(max),c.sid,1)+', DEFAULT_DATABASE = ['+c.default_database_name+'], CHECK_POLICY = '+case c.is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case c.is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script, 'CREATE' opt, 'MODIFY' type
from @mismatch_logins_sid a inner join (
select loginname, sid 
from @mismatch_logins_sid
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0)
except
select loginname, sid 
from @mismatch_logins_sid
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
)b
on a.loginname = b.loginname
and a.sid = b.sid
inner join (select loginname, isntname, sid, password_hash, default_database_name, is_policy_checked, is_expiration_checked
from @table
where replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)) c
on c.loginname = a.loginname

UNION 

--mismatch server roles
select replica_name, loginname, script, 'ADD', 'MODIFY'
from (
select loginname, replica_name, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select loginname, replica_name, case when charindex(',',mismatch_server_role) > 0 and len(mismatch_server_role) > 5 then substring(mismatch_server_role,1,len(mismatch_server_role)-1) else null end mismatch_server_role
from (
select loginname, replica_name, 
isnull(case when [sysadmin] is null and sum_sysadmin > 0 then 'sysadmin' when [sysadmin] is not null then null else null end+',','')+
isnull(case when [securityadmin] is null and [sum_securityadmin] > 0 then 'securityadmin' when [securityadmin] is not null then null else null end+',','')+
isnull(case when [serveradmin] is null and [sum_serveradmin] > 0 then 'serveradmin' when [serveradmin] is not null then null else null end+',','')+
isnull(case when [setupadmin] is null and [sum_setupadmin] > 0 then 'setupadmin' when [setupadmin] is not null then null else null end+',','')+
isnull(case when [processadmin] is null and [sum_processadmin] > 0 then 'processadmin' when [processadmin] is not null then null else null end+',','')+
isnull(case when [diskadmin] is null and [sum_diskadmin] > 0 then 'diskadmin' when [diskadmin] is not null then null else null end+',','')+
isnull(case when [dbcreator] is null and [sum_dbcreator] > 0 then 'dbcreator' when [dbcreator] is not null then null else null end+',','')+
isnull(case when [bulkadmin] is null and [sum_bulkadmin] > 0 then 'bulkadmin' when [bulkadmin] is not null then null else null end+',','') mismatch_server_role
from (
select loginname, replica_name,
[sysadmin],
sum(case when [sysadmin] is null then 0 else 1 end)over(partition by loginname order by loginname) [sum_sysadmin], 
[securityadmin],
sum(case when [securityadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_securityadmin], 
[serveradmin],
sum(case when [serveradmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_serveradmin], 
[setupadmin],
sum(case when [setupadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_setupadmin], 
[processadmin],
sum(case when [processadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_processadmin], 
[diskadmin],
sum(case when [diskadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_diskadmin], 
[dbcreator],
sum(case when [dbcreator] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_dbcreator], 
[bulkadmin],
sum(case when [bulkadmin] is null then 0 else 1 end)over(partition by loginname order by loginname)[sum_bulkadmin]
from @table sl
where loginname in (select loginname from @mismatch_logins))a)b)c cross apply master.dbo.Separator(mismatch_server_role, ','))d
where script is not null

UNION

select ars.replica_server_name , ars.loginname,
'CREATE LOGIN ['+ars.loginname+'] '+case a.isntname when 1 
then 'FROM WINDOWS' 
else 'WITH PASSWORD = '+convert(varchar(max),a.password_hash,1)+' HASHED, SID = '+convert(varchar(max),a.sid,1)+', DEFAULT_DATABASE = ['+a.default_database_name+'], CHECK_POLICY = '+case a.is_policy_checked when 1 then 'ON' else 'OFF' end+', CHECK_EXPIRATION = '+case a.is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script, 'CREATE' opt, 'NEW' type
from (select is_local, replica_server_name, loginname from @mismatch_logins cross apply @dm_hadr_availability_replica_states) ars
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on b.secondary_loginname = ars.loginname
and ars.replica_server_name = b.replica_name
inner join @table a
on a.loginname = ars.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where is_local = 0
and b.replica_name is null

UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script, 'ADD' opt, 'NEW' type
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select ars.replica_server_name replica_name, ars.loginname, isnull(a.sysadmin+',','')+isnull(a.securityadmin+',','')+isnull(a.serveradmin+',','')+isnull(a.setupadmin+',','')+isnull(a.processadmin+',','')+isnull(a.diskadmin+',','')+isnull(a.dbcreator+',','')+isnull(a.bulkadmin+',','') server_roles
from (select is_local, replica_server_name, loginname from @mismatch_logins cross apply @dm_hadr_availability_replica_states) ars
left outer join (
select loginname secondary_loginname, sid secondary_sid, replica_name
from @table sl
where loginname in (select loginname from @mismatch_logins)
and replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 0))b
on b.secondary_loginname = ars.loginname
and ars.replica_server_name = b.replica_name
inner join @table a
on a.loginname = ars.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where is_local = 0
and b.replica_name is null
)a)b cross apply master.dbo.Separator(server_roles, ',')
)lo3
order by loginname, replica_name, script desc

--------------
--Final result
--------------

declare logins_cursor cursor fast_forward
for
select replica_name, loginname, script, type 
from @mismatch_final

UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script, 'MODIFY' type
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select mf.replica_name replica_name, mf.loginname, isnull(a.sysadmin+',','')+isnull(a.securityadmin+',','')+isnull(a.serveradmin+',','')+isnull(a.setupadmin+',','')+isnull(a.processadmin+',','')+isnull(a.diskadmin+',','')+isnull(a.dbcreator+',','')+isnull(a.bulkadmin+',','') server_roles
from @mismatch_final mf inner join @table a
on mf.loginname = a.loginname
and a.replica_name in (select replica_server_name from @dm_hadr_availability_replica_states where is_local = 1)
where opt = 'DROP/CREATE' and type = 'MODIFY')b)c cross apply master.dbo.Separator(server_roles, ',')
order by loginname, replica_name, script desc

open logins_cursor
fetch next from logins_cursor into @replica_server_name, @loginname, @login_script, @type
while @@FETCH_STATUS = 0
begin
 
if @replica_name = 'ALL'
begin
	if @type = 'NEW'
	begin
		declare replica_cursor cursor fast_forward
		for
		select rcs.replica_server_name 
		from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
		on rs.replica_id = rcs.replica_id
		where is_local != 1
		open replica_cursor
		fetch next from replica_cursor into @replica_server_name_nc2
		while @@FETCH_STATUS = 0
		begin
			set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_server_name_nc2+']'
			exec(@sql)
		fetch next from replica_cursor into @replica_server_name_nc2
		end
		close replica_cursor
		deallocate replica_cursor
	end
	else
	if @type = 'MODIFY'
	begin
		set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_server_name+']'
		exec(@sql)
	end
end
else
if @replica_name in (select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1)
begin
	set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_name+']'
	exec(@sql)
end

fetch next from logins_cursor into @replica_server_name, @loginname, @login_script, @type
end
close logins_cursor
deallocate logins_cursor
 
end
else 
if @action in ('all','mismatch','sync') and @replica_name not in (select rcs.replica_server_name 
	from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
	on rs.replica_id = rcs.replica_id
	where is_local != 1)
begin
print('Please ensure that you type the replica name accurately, as the name you provided does not exist.')
end

set nocount off
----Exec ('Create Login [DBA_Temp] With Password = 0xCF654654654654607777708BEE40E4C5A9C890C35B9CF025088511C04F51EFC65059D5382CCBE18FC12BBEB3D44EEE6 Hashed, SID = 0xCF654587886970323776CF4F90EECCA4D88C5B48, Default_Database = [master], Check_Policy = OFF, Check_Expiration = OFF;') AT [<linked server replica name>]
end
GO

CREATE
--ALTER 
TRIGGER create_new_login
ON ALL SERVER
AFTER CREATE_LOGIN
AS
BEGIN
declare @replica_server_name varchar(300)
IF (select role_desc 
	from sys.dm_hadr_availability_replica_states
	where is_local = 1) = 'PRIMARY'
BEGIN
declare @date int, @time int, @scheduleid int
select 
@date = 
replace(convert(varchar(10),getdate(),120),'-',''),
@time = 
cast(replace(convert(varchar(10),dateadd(minute,1,getdate()),108),':','') as bigint),
@scheduleid = jsch.schedule_id 
from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobschedules jsch
on j.job_id = jsch.job_id
where j.name = 'sync_logins_job'

EXEC msdb.dbo.sp_update_schedule 
@schedule_id=@scheduleid, 
@enabled=1, 
@active_start_date=@date, 
@active_start_time=@time

END
END;

GO

--Create a job on each replica, including the primary, 
--with the job name sync_log_job. 
--if you want to change the job name, ensure that the name also updated in the above trigger.
USE [msdb]
GO
EXEC msdb.dbo.sp_add_job @job_name=N'sync_logins_job', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa'
--1- Then add a step and the below T-SQL.
exec master.[dbo].[sync_logins_between_replicas]
@action = 'sync', 
@replica_name = 'ALL'

--2- Add scheduler for one-time execution and disable it.

