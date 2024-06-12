declare 
@server_audit_loc	varchar(500) = 'C:\backups',
@drop			varchar(255),
@p1			varchar(255),
@p2			varchar(max),
@audit_script		varchar(max),
@objects		varchar(max) = '*',
@audit_types		varchar(255) = 'SELECT, Insert, Update, Delete',
@users			varchar(max) = '*',
@action			int = 1
--1 = configuration print
--2 = confgiuration execute
--3 = select from audit log
declare
@SAuditName		varchar(255) = replace(replace(replace(convert(varchar(30),getdate(),120),'-',''),':',''),' ','-'), 
@audit_log		varchar(500) = @server_audit_loc + case when ltrim(rtrim(right(@server_audit_loc,1))) != '\' then '\' else '' end + '*'

set @SAuditName = 'Audit-'+@SAuditName

if @action in (1,2)
begin

if exists (select * from sys.server_audits)
begin

select top 1
@drop =
'USE ['+db_name(db_id())+']
ALTER DATABASE AUDIT SPECIFICATION ['+name+'] WITH (STATE = OFF)
DROP DATABASE AUDIT SPECIFICATION ['+name+']'
from sys.database_audit_specifications

select top 1 @p1 = 'CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-'+db_name(db_id())+']
FOR SERVER AUDIT ['+name+']'
from sys.server_audits
--name = ''

if @objects != '*'
begin
if @users != '*'
begin
select @p2 = isnull(@p2+',
','') + 'ADD ('+@audit_types+' ON ['+schema_name(schema_id)+'].['+t.name+'] BY ['+ltrim(rtrim(s.value))+'])'
from sys.tables t cross apply master.dbo.Separator(@users, ',') s
where schema_name(schema_id)+'.'+t.name collate SQL_Latin1_General_CP1_CI_AS 
in (select replace(replace(ltrim(rtrim(value)),']',''),'[','') from master.dbo.Separator(@objects,','))
order by s.value, schema_name(schema_id)+'.'+t.name 
end
else
begin
select @p2 = isnull(@p2+',
','') + 'ADD ('+@audit_types+' ON ['+schema_name(schema_id)+'].['+t.name+'] BY [Public])'
from sys.tables t
where schema_name(schema_id)+'.'+t.name collate SQL_Latin1_General_CP1_CI_AS 
in (select replace(replace(ltrim(rtrim(value)),']',''),'[','') from master.dbo.Separator(@objects,','))
order by schema_name(schema_id)+'.'+t.name
end

end
else
begin
if @users != '*'
begin
select @p2 = isnull(@p2+',
','') + 'ADD ('+@audit_types+' ON ['+schema_name(schema_id)+'].['+t.name+'] BY ['+ltrim(rtrim(s.value))+'])'
from sys.tables t cross apply master.dbo.Separator(@users, ',') s
order by s.value, schema_name(schema_id)+'.'+t.name
end
else
begin
select @p2 = isnull(@p2+',
','') + 'ADD ('+@audit_types+' ON ['+schema_name(schema_id)+'].['+t.name+'] BY [Public])'
from sys.tables t
order by schema_name(schema_id)+'.'+t.name
end

end
set @audit_script = isnull(@drop,'')+isnull(@p1,'')+isnull(@p2,'')+'
WITH (STATE = ON)'

if @action = 1
begin
print(@audit_script)
end
else
if @action = 2
begin
exec(@audit_script)
end
end
else
begin
set @audit_script = 'USE master
GO
CREATE SERVER AUDIT [Audit-20240612-153449]
TO FILE 
(FILEPATH = N'+''''+@server_audit_loc+''''+'
,MAXSIZE = 0 MB
,MAX_ROLLOVER_FILES = 2147483647
,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
GO
ALTER SERVER AUDIT ['+@SAuditName+'] WITH (STATE = ON)
GO
'
if @action = 1
begin
print(@audit_script)
end
else
if @action = 2
begin
exec(@audit_script)
end

end
end
else if @action = 3
begin

--to fetch from the audit file(s)
select 
	event_time, database_name, session_server_principal_name, succeeded, action_id, 
	is_column_permission,schema_name, object_name, statement, application_name, client_ip  
from sys.fn_get_audit_file(
@audit_log,
DEFAULT,
DEFAULT)

end
