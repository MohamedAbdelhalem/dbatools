use master
go
select * 
from (
select 
(select name from sys.database_principals where principal_id = dbrm.role_principal_id) role_name,
(select name from sys.database_principals where principal_id = dbrm.member_principal_id) user_name,
'ALTER ROLE ['+(select name from sys.database_principals where principal_id = dbrm.role_principal_id)+'] add member ['+(select name from sys.database_principals where principal_id = dbrm.member_principal_id)+']' add_member,
'ALTER ROLE ['+(select name from sys.database_principals where principal_id = dbrm.role_principal_id)+'] drop member ['+(select name from sys.database_principals where principal_id = dbrm.member_principal_id)+']' remove_member
from sys.database_role_members dbrm)a
where role_name = 'SqlJDBCXAUser'
