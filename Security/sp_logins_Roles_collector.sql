use [master]
go
CREATE Procedure [dbo].[sp_logins_Roles_collector]
as
begin

declare @users table (
	[database_name]				varchar(300), 
	[principal_id]				int, 
	[sid]						varbinary(255), 
	[login_name]				varchar(300), 
	[login_type]				varchar(100), 
	[default_schema_name]		varchar(100), 
	[authentication_type_desc]	varchar(100), 
	[db_role_name]				varchar(200)
)

declare @login table (
	[id]			int identity(1,1), 
	[sid]			varbinary(255), 
	[Login_name]	varchar(300), 
	[Roles]			varchar(max)
)

declare @table_permissions table (
	[principal_id]					int, 
	[sid]							varbinary(255), 
	[database_name]					varchar(500), 
	[loginame]						varchar(300), 
	[state_desc]					varchar(100), 
	[Object_Name_Type_Permissions]	varchar(max)
)

declare @server_db_roles table (
	[sid]				varbinary(255), 
	[loginame]			varchar(500), 
	[is_disabled]		int, 
	[hasAccess]			int, 
	[server_roles]		varchar(500), 
	[database_roles]	varchar(max)
)

create table #permissions (
	[database_name]					varchar(500), 
	[sid]							varbinary(255), 
	[state_desc]					varchar(100), 
	[Object_Name_Type_Permissions]	varchar(max)
)

declare @sql varchar(max)
declare @db_name varchar(500)
declare db_cursor cursor fast_forward
for
select name
from sys.databases

insert into @users 
exec sp_MSforeachdb '
use [?]
select "?" database_name, p.principal_id, p.sid, p.name login_name, p.type_desc login_type, p.default_schema_name, p.authentication_type_desc, isnull(r.name,''Public'') db_role_name
from sys.database_principals p
left outer join (
select p.name, p.principal_id, p.type_desc,sid, p.default_schema_name, p.authentication_type_desc, dbm.member_principal_id
from sys.database_principals p left outer join sys.database_role_members dbm
on p.principal_id = dbm.role_principal_id) r
on p.principal_id = r.member_principal_id
where p.type_desc in (''sql_user'',''windows_user'')
and p.authentication_type_desc != ''none''
order by p.type_desc, p.name'

insert into @login (sid, Login_name, Roles)
select sid, [login_name],
[1]+isnull(' ;'+[2],'')+isnull(' ;'+[3],'')+isnull(' ;'+[4],'')+isnull(' ;'+[5],'')+isnull(' ;'+[6],'')
+isnull(' ;'+[7],'')+isnull(' ;'+[8],'')+isnull(' ;'+[9],'')+isnull(' ;'+[10],'')+isnull(' ;'+[11],'')+isnull(' ;'+[12],'') database_roles_array
from (
select row_number() over(partition by login_name order by login_name) id, 
sid, [login_name], '['+[database_name]+'] ('+db_roles+')' logins_db_roles
from (
select row_number() over(partition by database_name order by login_name) id,
[database_name], sid, [login_name], 
'"'+[1]+'"'+isnull(' -"'+[2]+'"','')+isnull(' -"'+[3]+'"','')+isnull(' -"'+[4]+'"','')+isnull(' -"'+[5]+'"','')+isnull(' -"'+[6]+'"','')
+isnull(' -"'+[7]+'"','')+isnull(' -"'+[8]+'"','')+isnull(' -"'+[9]+'"','')+isnull(' -"'+[10]+'"','')+isnull(' -"'+[11]+'"','')+isnull(' -"'+[12]+'"','')
db_roles 
from (
select 
row_number() over(partition by sid, database_name order by database_name) id,
database_name,  sid, login_name, db_role_name 
from @users)a
pivot (
max(db_role_name) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p)b
where login_name not like '%#%')c
pivot (
max(logins_db_roles) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]))p
order by login_name

insert into @server_db_roles
select  s.sid, isnull(loginname,lo.Login_name) Login_Name , is_disabled, hasaccess, server_roles, --lo.Roles database_roles --
isnull(lo.Roles, 'No Database Mapping') database_roles
from @login lo full outer join (
select sid, loginname, is_disabled, hasaccess,
case when len(server_roles) = 0 then 'Public' else substring(server_roles, 1, len(server_roles) - 1) end server_roles
from (
select principal_id, sid, loginname, is_disabled, hasaccess, 
isnull(sysadmin+', ','')    +isnull(securityadmin+', ','') +isnull(serveradmin+', ','')+
isnull(setupadmin+', ','')  +isnull(processadmin+', ','')  +isnull(diskadmin+', ','')+
isnull(dbcreator+', ','')   +isnull(bulkadmin+', ','')
server_roles
from (
select sp.principal_id, l.sid, loginname, is_disabled, hasaccess, 
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
and sp.type in ('u','g','s'))a)b)s
on lo.Login_name = s.loginname

open db_cursor
fetch next from db_cursor into @db_name
while @@FETCH_STATUS = 0
begin

set @sql = 'use ['+@db_name+']
select 
principal_id, 
sid,db_name(db_id()) db, loginame, state_desc, 
ISNULL([1],'''') +
ISNULL('' | ''+[2],'''') +ISNULL('' | ''+[3],'''') +ISNULL('' | ''+[4],'''') +ISNULL('' | ''+[5],'''')+
ISNULL('' | ''+[6],'''') +ISNULL('' | ''+[7],'''') +ISNULL('' | ''+[8],'''') +ISNULL('' | ''+[9],'''')+
ISNULL('' | ''+[10],'''')+ISNULL('' | ''+[11],'''')+ISNULL('' | ''+[12],'''')+ISNULL('' | ''+[13],'''')+
ISNULL('' | ''+[14],'''')+ISNULL('' | ''+[15],'''')+ISNULL('' | ''+[16],'''')+ISNULL('' | ''+[17],'''')+
ISNULL('' | ''+[18],'''')+ISNULL('' | ''+[19],'''')+ISNULL('' | ''+[20],'''')+ISNULL('' | ''+[21],'''')+
ISNULL('' | ''+[22],'''')+ISNULL('' | ''+[23],'''')+ISNULL('' | ''+[24],'''')+ISNULL('' | ''+[25],'''')+
ISNULL('' | ''+[26],'''')+ISNULL('' | ''+[27],'''')+ISNULL('' | ''+[28],'''')+ISNULL('' | ''+[29],'''')+
ISNULL('' | ''+[30],'''')+ISNULL('' | ''+[31],'''')+ISNULL('' | ''+[32],'''')+ISNULL('' | ''+[33],'''')+
ISNULL('' | ''+[34],'''')+ISNULL('' | ''+[35],'''')+ISNULL('' | ''+[36],'''')+ISNULL('' | ''+[37],'''')+
ISNULL('' | ''+[38],'''')+ISNULL('' | ''+[39],'''')+ISNULL('' | ''+[40],'''')+ISNULL('' | ''+[41],'''')+
ISNULL('' | ''+[42],'''')+ISNULL('' | ''+[43],'''')+ISNULL('' | ''+[44],'''')+ISNULL('' | ''+[45],'''')+
ISNULL('' | ''+[46],'''')+ISNULL('' | ''+[47],'''')+ISNULL('' | ''+[48],'''')+ISNULL('' | ''+[49],'''')+
ISNULL('' | ''+[50],'''')+ISNULL('' | ''+[51],'''')+ISNULL('' | ''+[52],'''')+ISNULL('' | ''+[53],'''')+
ISNULL('' | ''+[54],'''')+ISNULL('' | ''+[55],'''')+ISNULL('' | ''+[56],'''')+ISNULL('' | ''+[57],'''')+
ISNULL('' | ''+[58],'''')+ISNULL('' | ''+[59],'''')+ISNULL('' | ''+[60],'''') [Object_Name_Type_Permissions]
from (
select row_number() over(partition by a1.principal_id order by a1.principal_id) id, 
a1.principal_id,sid, loginame, per_objs.state_desc, object_name_type+''(''+[objects_columns_permissions]+'')'' collate SQL_Latin1_General_CP1_CI_AS object_name_type_permissions
from (
select principal_id, name loginame, object_id, 
ISNULL([1],'''') +
ISNULL('',''+[2],'''')+ISNULL('',''+[3],'''')+ISNULL('',''+[4],'''')+ISNULL('',''+[5],'''')+ISNULL('',''+[6],'''')+ISNULL('',''+[7],'''') [permissions]
from (
select row_number() over(partition by pri.principal_id, ob.object_id order by pri.principal_id, pre.permission_name) id,  pri.principal_id, pri.name, pre.permission_name, ob.object_id, pre.state_desc 
from sys.database_permissions pre inner join sys.database_principals pri
on pre.grantee_principal_id = pri.principal_id
inner join sys.objects ob
on pre.major_id = ob.object_id
where pri.type in (''S'',''U''))a
pivot (
max(permission_name) for id in ([1],[2],[3],[4],[5],[6],[7]))p)a1
inner join 
(select distinct pre.grantee_principal_id, ob.object_id, ''[''+schema_name(ob.schema_id)+''].[''+ob.name+''] "''+ 
case ob.type  
when ''P''  then ''Procedure''
when ''U''  then ''Table''
when ''S''  then ''System Table''
when ''V''  then ''View''
when ''AF'' then ''Function (CLR)''
when ''FN'' then ''Scalar Function''
when ''PC'' then ''Assembly (CLR) Procedure''
when ''FS'' then ''Assembly (CLR) Function''
when ''FT'' then ''Assembly (CLR) Table-valued Function''
when ''IF'' then ''SQL Inline Table-valued Function''
when ''IT'' then ''Internal Table''
when ''RF'' then ''Replication-filter-procedure''
when ''SN'' then ''Synonym''
when ''SO'' then ''Sequence object''
when ''SQ'' then ''Service queue''
when ''TA'' then ''Assembly (CLR) DML trigger''
when ''TF'' then ''Table-valued-function''
when ''TR'' then ''DML trigger''
when ''X''  then ''Extended stored procedure''
end +''" - '' object_name_type, pre.state_desc 
from sys.database_permissions pre 
inner join sys.objects ob
on pre.major_id = ob.object_id
) b1
on a1.object_id = b1.object_id
and a1.principal_id = b1.grantee_principal_id
inner join 
(
select distinct
principal_id, sid, major_id, state_desc,
ISNULL([1],'''') +
ISNULL('',''+[2],'''') +ISNULL('',''+[3],'''') +ISNULL('',''+[4],'''') +ISNULL('',''+[5],'''')+
ISNULL('',''+[6],'''') +ISNULL('',''+[7],'''') +ISNULL('',''+[8],'''') +ISNULL('',''+[9],'''')+
ISNULL('',''+[10],'''')+ISNULL('',''+[11],'''')+ISNULL('',''+[12],'''')+ISNULL('',''+[13],'''')+
ISNULL('',''+[14],'''')+ISNULL('',''+[15],'''')+ISNULL('',''+[16],'''')+ISNULL('',''+[17],'''')+
ISNULL('',''+[18],'''')+ISNULL('',''+[19],'''')+ISNULL('',''+[20],'''')+ISNULL('',''+[21],'''')+
ISNULL('',''+[22],'''')+ISNULL('',''+[23],'''')+ISNULL('',''+[24],'''')+ISNULL('',''+[25],'''')+
ISNULL('',''+[26],'''')+ISNULL('',''+[27],'''')+ISNULL('',''+[28],'''')+ISNULL('',''+[29],'''')+
ISNULL('',''+[30],'''')+ISNULL('',''+[31],'''')+ISNULL('',''+[32],'''')+ISNULL('',''+[33],'''')+
ISNULL('',''+[34],'''')+ISNULL('',''+[35],'''')+ISNULL('',''+[36],'''')+ISNULL('',''+[37],'''')+
ISNULL('',''+[38],'''')+ISNULL('',''+[39],'''')+ISNULL('',''+[40],'''')+ISNULL('',''+[41],'''')+
ISNULL('',''+[42],'''')+ISNULL('',''+[43],'''')+ISNULL('',''+[44],'''')+ISNULL('',''+[45],'''')+
ISNULL('',''+[46],'''')+ISNULL('',''+[47],'''')+ISNULL('',''+[48],'''')+ISNULL('',''+[49],'''')+
ISNULL('',''+[50],'''')+ISNULL('',''+[51],'''')+ISNULL('',''+[52],'''')+ISNULL('',''+[53],'''')+
ISNULL('',''+[54],'''')+ISNULL('',''+[55],'''')+ISNULL('',''+[56],'''')+ISNULL('',''+[57],'''')+
ISNULL('',''+[58],'''')+ISNULL('',''+[59],'''')+ISNULL('',''+[60],'''') [objects_columns_permissions]
from (
select row_number() over(partition by principal_id, major_id order by principal_id, major_id, minor_id ) iid, principal_id, sid, major_id, 
case 
when id = 1 and type = ''SL'' then ''SELECT (''+column_name 
when id = max_col and type = ''SL'' then column_name+'')''
else column_name end column_name, state_desc
from (
select row_number() over(partition by pri.principal_id, per.major_id order by principal_id, major_id, minor_id ) id, 
pri.principal_id, pri.sid, per.major_id, col.name column_name, per.[permission_name], per.state_desc, per.type, minor_id, COUNT(*) over(partition by pri.principal_id, per.major_id) max_col
from sys.database_permissions per inner join sys.database_principals pri
on per.grantee_principal_id = pri.principal_id
inner join sys.columns col
on per.major_id = col.object_id
and per.minor_id = col.column_id
where pri.type in (''S'',''U'')
and principal_id > 1
and major_id > 0
and minor_id > 0
union 
select row_number() over(partition by pri.principal_id, per.major_id order by pri.principal_id, per.major_id, minor_id) id, 
pri.principal_id, pri.sid, per.major_id, isnull(col.name,''*)'') column_name, per.[permission_name], per.state_desc, per.type, minor_id, 0
from sys.database_permissions per inner join sys.database_principals pri
on per.grantee_principal_id = pri.principal_id
left outer join sys.columns col
on per.major_id = col.object_id
and per.minor_id = col.column_id
where pri.type in (''S'',''U'')
and principal_id > 1
and major_id > 0
and minor_id = 0
and per.type = ''SL''
union 
select row_number() over(partition by pri.principal_id, per.major_id order by pri.principal_id, per.major_id, minor_id) id, 
pri.principal_id, pri.sid, per.major_id, isnull(col.name,per.permission_name) column_name, per.[permission_name], per.state_desc, per.type, minor_id, 0
from sys.database_permissions per inner join sys.database_principals pri
on per.grantee_principal_id = pri.principal_id
left outer join sys.columns col
on per.major_id = col.object_id
and per.minor_id = col.column_id
where pri.type in (''S'',''U'')
and principal_id > 1
and major_id > 0
and minor_id = 0
and per.type != ''SL''
)SL)SL_IN_UP_DEL_EX pivot
(max(column_name) for [iid] in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],
[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],
[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],
[51],[52],[53],[54],[55],[56],[57],[58],[59],[60]))p)per_objs
on b1.grantee_principal_id = per_objs.principal_id
and b1.object_id = per_objs.major_id
)a2 pivot
(max(object_name_type_permissions) for id in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],
[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],
[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],
[51],[52],[53],[54],[55],[56],[57],[58],[59],[60]))p2
order by loginame'

--print (@sql)
insert into @table_permissions 
exec (@sql)
fetch next from db_cursor into @db_name
end
close db_cursor
deallocate db_cursor

insert into #permissions
select tp.database_name, l.sid, tp.state_desc, tp.Object_Name_Type_Permissions 
from sys.syslogins l left outer join @table_permissions tp
on l.sid = tp.sid
order by tp.database_name

set @db_name = null
select @db_name = isnull(@db_name+',','') +'['+name+']'
from sys.databases
where database_id > 4 --remove this line if you want all database mapping

set @sql = 'select * 
			  into tempdb..permissions_pivot 
			  from #permissions 
			  pivot (
			  max([Object_Name_Type_Permissions]) for [database_name] in ('+@db_name+'))p'
exec(@sql)

select sdbr.Loginame Login_Name, case sdbr.is_disabled when 0 then 'Enabled' else 'Disabled' end [Status], 
sdbr.HasAccess, sdbr.Server_Roles, sdbr.Database_Roles, db_per.*
from @server_db_roles sdbr left outer join tempdb..permissions_pivot db_per
on sdbr.sid = db_per.sid
inner join sys.syslogins l
on sdbr.sid = l.sid
order by l.createdate

--drop table #permissions 
drop table tempdb..permissions_pivot
end

go


EXEC [dbo].[sp_logins_Roles_collector]
