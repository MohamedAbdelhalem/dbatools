declare 
@f_user varchar(100) = 'ALBILAD\e003738', 
@t_user varchar(100) = 'ALBILAD\e010204'

select 'GRANT '+[permission_name]+' TO ['+@t_user+'];'
from (
select p.permission_name
from sys.server_permissions p inner join sys.server_principals i
on p.grantee_principal_id = i.principal_id
where is_disabled = 0
and type_desc in ('SQL_LOGIN','WINDOWS_LOGIN')
and name = @f_user
except
select p.permission_name
from sys.server_permissions p inner join sys.server_principals i
on p.grantee_principal_id = i.principal_id
where is_disabled = 0
and type_desc in ('SQL_LOGIN','WINDOWS_LOGIN')
and name = @t_user)a

--GRANT ALTER ANY CONNECTION TO [ALBILAD\e010204];
--GRANT VIEW ANY DATABASE TO [ALBILAD\e010204];
--GRANT VIEW ANY DEFINITION TO [ALBILAD\e010204];