exec master.[dbo].[logins_compare_db_roles] 
@db_name_source  = 'AccountStatementUAT_main',
@db_name_destination = 'AccountStatementUAT', 
@login_name = '*'

go
create procedure [dbo].[logins_compare_db_roles] (
@db_name_source varchar(500),
@db_name_destination varchar(500), 
@login_name varchar(max))
as
begin

declare @result_logins table (Login_Name varchar(500), is_disabled varchar(50), hasaccess varchar(500), server_roles varchar(500), database_roles varchar(500))
declare @users table (
[database_name] varchar(300), 
[login_name] varchar(300), 
[login_type] varchar(100), 
default_schema_name varchar(100), 
--authentication_type_desc varchar(100), 
[db_role_name] varchar(200))

declare @login table (id int identity(1,1), Login_name varchar(300), Roles varchar(max))

insert into @users 
exec sp_MSforeachdb '
use [?]
select "?" database_name, p.name login_name, p.type_desc login_type, p.default_schema_name,  r.name db_role_name
from sys.database_principals p
inner join (
select p.name, p.principal_id, p.type_desc, p.default_schema_name, dbm.member_principal_id
from sys.database_principals p inner join sys.database_role_members dbm
on p.principal_id = dbm.role_principal_id) r
on p.principal_id = r.member_principal_id
order by p.type_desc, p.name'

if @login_name = '*'
begin
	insert into @login (Login_name, Roles)
	select [login_name],
	[1]+isnull(' ;'+[2],'')+isnull(' ;'+[3],'')+isnull(' ;'+[4],'')+isnull(' ;'+[5],'')+isnull(' ;'+[6],'')
	+isnull(' ;'+[7],'')+isnull(' ;'+[8],'')+isnull(' ;'+[9],'')+isnull(' ;'+[10],'')+isnull(' ;'+[11],'')+isnull(' ;'+[12],'') database_roles_array
	from (
	select row_number() over(partition by login_name order by login_name) id,
	[login_name], '['+[database_name]+'] ('+db_roles+')' logins_db_roles
	from (
	select row_number() over(partition by database_name order by login_name) id,
	[database_name], [login_name], 
	'"'+[1]+'"'+isnull(' -"'+[2]+'"','')+isnull(' -"'+[3]+'"','')+isnull(' -"'+[4]+'"','')+isnull(' -"'+[5]+'"','')+isnull(' -"'+[6]+'"','')
	+isnull(' -"'+[7]+'"','')+isnull(' -"'+[8]+'"','')+isnull(' -"'+[9]+'"','')+isnull(' -"'+[10]+'"','')+isnull(' -"'+[11]+'"','')+isnull(' -"'+[12]+'"','')
	db_roles 
	from (
	select 
	row_number() over(partition by login_name, database_name order by login_name) id,
	database_name, login_name, db_role_name 
	from @users)a
	pivot (
	max(db_role_name) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p)b
	where login_name not like '%#%')c
	pivot (
	max(logins_db_roles) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p
	order by login_name
end
else
begin
	insert into @login (Login_name, Roles)
	select [login_name],
	[1]+isnull(' ;'+[2],'')+isnull(' ;'+[3],'')+isnull(' ;'+[4],'')+isnull(' ;'+[5],'')+isnull(' ;'+[6],'')
	+isnull(' ;'+[7],'')+isnull(' ;'+[8],'')+isnull(' ;'+[9],'')+isnull(' ;'+[10],'')+isnull(' ;'+[11],'')+isnull(' ;'+[12],'') database_roles_array
	from (
	select row_number() over(partition by login_name order by login_name) id,
	[login_name], '['+[database_name]+'] ('+db_roles+')' logins_db_roles
	from (
	select row_number() over(partition by database_name order by login_name) id,
	[database_name], [login_name], 
	'"'+[1]+'"'+isnull(' ,"'+[2]+'"','')+isnull(' ,"'+[3]+'"','')+isnull(' ,"'+[4]+'"','')+isnull(' ,"'+[5]+'"','')+isnull(' ,"'+[6]+'"','')
	+isnull(' ,"'+[7]+'"','')+isnull(' ,"'+[8]+'"','')+isnull(' ,"'+[9]+'"','')+isnull(' ,"'+[10]+'"','')+isnull(' ,"'+[11]+'"','')+isnull(' ,"'+[12]+'"','')
	db_roles 
	from (
	select 
	row_number() over(partition by login_name, database_name order by login_name) id,
	database_name, login_name, db_role_name 
	from @users
	where login_name in (select ltrim(rtrim(value)) from master.dbo.Separator(@login_name,',')))a
	pivot (
	max(db_role_name) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p)b
	where login_name not like '%#%')c
	pivot (
	max(logins_db_roles) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p
	order by login_name
end

	if @login_name = '*'
	begin
		select isnull(loginname,lo.Login_name) Login_Name , is_disabled, hasaccess, server_roles, isnull(lo.Roles, 'no database mapping') database_roles
		from @login lo full outer join (
		select loginname, is_disabled, hasaccess,
		case when len(server_roles) = 0 then 'Public' else substring(server_roles, 1, len(server_roles) - 1) end server_roles
		from (
		select loginname, is_disabled, hasaccess, 
		isnull(sysadmin+', ','')	+isnull(securityadmin+', ','')	+isnull(serveradmin+', ','')+
		isnull(setupadmin+', ','')	+isnull(processadmin+', ','')	+isnull(diskadmin+', ','')+
		isnull(dbcreator+', ','')	+isnull(bulkadmin+', ','')
		server_roles
		from (
		select loginname, is_disabled, hasaccess, 
		case sysadmin		when 1 then 'sysadmin' else null end sysadmin, 
		case securityadmin	when 1 then 'securityadmin' else null end securityadmin, 
		case serveradmin	when 1 then 'serveradmin' else null end serveradmin, 
		case setupadmin		when 1 then 'setupadmin' else null end setupadmin, 
		case processadmin	when 1 then 'processadmin' else null end processadmin, 
		case diskadmin		when 1 then 'diskadmin' else null end diskadmin, 
		case dbcreator		when 1 then 'dbcreator' else null end dbcreator, 
		case bulkadmin		when 1 then 'bulkadmin' else null end bulkadmin 
		from sys.syslogins l inner join sys.server_principals sp
		on l.name = sp.name
		where l.name not like '#%'
		and l.name not like 'NT SERVICE\%'
		and l.name not like 'NT AUTHORITY\%'
		and sp.type in ('u','g','s'))a)b)s
		on lo.Login_name = s.loginname
	end
	else
	begin
	insert into @result_logins
		select isnull(loginname,lo.Login_name) Login_Name , is_disabled, hasaccess, server_roles, isnull(lo.Roles, 'no database mapping') database_roles
		from @login lo full outer join (
		select loginname, is_disabled, hasaccess,
		case when len(server_roles) = 0 then 'Public' else substring(server_roles, 1, len(server_roles) - 1) end server_roles
		from (
		select loginname, is_disabled, hasaccess, 
		isnull(sysadmin+', ','')	+isnull(securityadmin+', ','')	+isnull(serveradmin+', ','')+
		isnull(setupadmin+', ','')	+isnull(processadmin+', ','')	+isnull(diskadmin+', ','')+
		isnull(dbcreator+', ','')	+isnull(bulkadmin+', ','')
		server_roles
		from (
		select loginname, is_disabled, hasaccess, 
		case sysadmin		when 1 then 'sysadmin' else null end sysadmin, 
		case securityadmin	when 1 then 'securityadmin' else null end securityadmin, 
		case serveradmin	when 1 then 'serveradmin' else null end serveradmin, 
		case setupadmin		when 1 then 'setupadmin' else null end setupadmin, 
		case processadmin	when 1 then 'processadmin' else null end processadmin, 
		case diskadmin		when 1 then 'diskadmin' else null end diskadmin, 
		case dbcreator		when 1 then 'dbcreator' else null end dbcreator, 
		case bulkadmin		when 1 then 'bulkadmin' else null end bulkadmin 
		from sys.syslogins l inner join sys.server_principals sp
		on l.name = sp.name
		where l.name not like '#%'
		and l.name not like 'NT SERVICE\%'
		and l.name not like 'NT AUTHORITY\%'
		and sp.type in ('u','g','s'))a)b)s
		on lo.Login_name = s.loginname
		where lo.Login_name in (select ltrim(rtrim(value)) from master.dbo.Separator(@login_name,','))
end

select 'ALTER ROLE ['+replace(value,'"','')+'] ADD MEMBER ['+Login_Name+']'
from (
select Login_Name, s.value
from (
select Login_Name,
replace(replace(substring(value,1, charindex(']',value)-1),']',''),'[','') database_name,
replace(replace(substring(value, charindex(' ',value)+1,len(value)),')',''),'(','') database_roles
from @result_logins l cross apply master.dbo.Separator(database_roles,';')
where replace(replace(substring(value,1, charindex(']',value)-1),']',''),'[','') in (@db_name_source))a
cross apply master.dbo.Separator(database_roles, ',') s
except
select Login_Name, d.value
from (
select Login_Name,
replace(replace(substring(value,1, charindex(']',value)-1),']',''),'[','') database_name,
replace(replace(substring(value, charindex(' ',value)+1,len(value)),')',''),'(','') database_roles
from @result_logins l cross apply master.dbo.Separator(database_roles,';')
where replace(replace(substring(value,1, charindex(']',value)-1),']',''),'[','') in (@db_name_destination))a
cross apply master.dbo.Separator(database_roles, ',') d)a
order by Login_Name

end
