use [master]
GO
--Create linked server and the below view and procedure in each replica. 
GO
Create View dbo.sys_logins
as
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


GO
--exec [dbo].[sync_logins_between_replicas] @show='sync',@replica_name='SQLSERVERVM02'
GO
CREATE
Procedure [dbo].[sync_logins_between_replicas]
(
--parameters
@action varchar(50) = 'local', 
--Accepted values: 
--"local"-------to show logins on the local node.
--"all"---------to show you all logins locally and the other replicas too.
--"mismatch"----to show you the mis logins in the other replicas.
--"sync"--------to create the mismatched logins that are not exit on the secondary replicas.
@replica_name varchar(300) = '<replica name>'
--Accepted values: 
--"default"-----------means no replica.
--"<replica name>"----means no replica.
--"all"---------------means the current replica is the primary and all other replicas
--it will search on all replicas and apply it
--this option prerequisites to create linked servers for all replicas
)
as
begin
 
--variables
declare @sql varchar(max), 
@login_script varchar(max),
@replica_server_name varchar(500)

declare @table table (
principal_id int, sid varbinary(max), loginname varchar(200), 
is_disabled int,language varchar(200),denylogin int,hasaccess int,
sysadmin varchar(200),securityadmin varchar(200),serveradmin varchar(200),setupadmin varchar(200),processadmin varchar(200),diskadmin varchar(200),dbcreator varchar(200),bulkadmin varchar(200),
replica_name varchar(300))
 
set nocount on
 
insert into @table
select *, 
case when charindex('\',cast(@@servername as varchar(500))) > 0 then substring(cast(@@servername as varchar(500)),1,charindex('\',cast(@@servername as varchar(500)))-1) 
else cast(@@servername as varchar(500)) end 
from [master].dbo.sys_logins

--------------------------------------------------
--show you all logins in the current node
--------------------------------------------------
if @action = 'local' 
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
 
--select loginname, server_roles 
--from (
--select loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
--from (
--select loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
--from @table sl left outer join sys.sql_logins sqll
--on sl.loginname = sqll.name
--left outer join sys.server_principals sp
--on sl.loginname = sp.name)a)b
--where server_roles is null

--UNION

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
--------------------------------------------------
--synchronizing the missing logins
--------------------------------------------------
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
		print(@sql)
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
'Create Login ['+loginname+'] '+case when charindex('\',loginname) > 0 
then 'From Windows' 
else 'With Password = '+convert(varchar(max),sqll.password_hash,1)+' Hashed, SID = '+convert(varchar(max),sl.sid,1)+', Default_Database = ['+sp.default_database_name+'], Check_Policy = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', Check_Expiration = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
 
UNION
 
select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select replica_name, loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name)a)b cross apply master.dbo.Separator(server_roles, ',')

) lo
where script is not null
order by loginname, replica_name, script desc
end
else
if @action = 'mismatch'
begin

select replica_name, loginname, script 
from (

select replica_name, loginname,
'Create Login ['+loginname+'] '+case when charindex('\',loginname) > 0 
then 'From Windows' 
else 'With Password = '+convert(varchar(max),sqll.password_hash,1)+' Hashed, SID = '+convert(varchar(max),sl.sid,1)+', Default_Database = ['+sp.default_database_name+'], Check_Policy = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', Check_Expiration = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local = 1)
				except
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local != 1))
 
UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select replica_name, loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local = 1)
				except
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local != 1))
)a)b cross apply master.dbo.Separator(server_roles, ',')
 
) lo
where script is not null
order by loginname, replica_name, script desc
 
end
end
--------------------------------------------------
--synchronizing the missing logins
--------------------------------------------------
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

declare logins_cursor cursor fast_forward
for
select script 
from (

select replica_name, loginname,
'Create Login ['+loginname+'] '+case when charindex('\',loginname) > 0 
then 'From Windows' 
else 'With Password = '+convert(varchar(max),sqll.password_hash,1)+' Hashed, SID = '+convert(varchar(max),sl.sid,1)+', Default_Database = ['+sp.default_database_name+'], Check_Policy = '+case is_policy_checked when 1 then 'ON' else 'OFF' end+', Check_Expiration = '+case is_expiration_checked when 1 then 'ON' else 'OFF' end 
end + ';' script
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local = 1)
				except
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local != 1))
 
UNION

select replica_name, loginname, 'ALTER SERVER ROLE ['+value+'] ADD MEMBER ['+loginname+']' script
from (
select replica_name, loginname, case when charindex(',',server_roles) > 0 and len(server_roles) > 5 then substring(server_roles,1,len(server_roles)-1) else null end server_roles
from (
select replica_name, loginname, isnull(sysadmin+',','')+isnull(securityadmin+',','')+isnull(serveradmin+',','')+isnull(setupadmin+',','')+isnull(processadmin+',','')+isnull(diskadmin+',','')+isnull(dbcreator+',','')+isnull(bulkadmin+',','') server_roles
from @table sl left outer join sys.sql_logins sqll
on sl.loginname = sqll.name
left outer join sys.server_principals sp
on sl.loginname = sp.name
where loginname in (
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local = 1)
				except
				select loginname 
				from @table
				where replica_name in (select rcs.replica_server_name 
										from sys.dm_hadr_availability_replica_states rs inner join sys.dm_hadr_availability_replica_cluster_states rcs
										on rs.replica_id = rcs.replica_id
										where is_local != 1))
)a)b cross apply master.dbo.Separator(server_roles, ',') 
) lo
where script is not null
order by loginname, replica_name, script desc
 
open logins_cursor
fetch next from logins_cursor into @login_script
while @@FETCH_STATUS = 0
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
		set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_server_name+']'
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
set @sql = 'Exec ('+''''+@login_script+''''+') AT ['+@replica_name+']'
exec(@sql)
end

fetch next from logins_cursor into @login_script
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

ALTER TRIGGER create_new_login
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

CREATE Procedure dbo.apply_sync_logins
as
begin
declare @replica_server_name varchar(300)
if (select role_desc 
      from sys.dm_hadr_availability_replica_states
      where is_local = 1) = 'PRIMARY'
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
	exec [dbo].[sync_logins_between_replicas] @show='sync',@replica_name=@replica_server_name
	fetch next from replica_cursor into @replica_server_name
	end
	close replica_cursor
	deallocate replica_cursor
end
end
GO

--create a new job on each replica including the primary node for this job name sync_logins_job and if you need to change the name of this job change it on the above trigger too.
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
--then add this procedure master.dbo.apply_sync_logins in the step
--add scheduler to run one time and disable the scheduler

