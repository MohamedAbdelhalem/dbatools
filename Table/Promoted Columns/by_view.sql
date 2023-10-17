declare @view_name varchar(500) = 'V_FBNK_CHEQUE_ISSUE#HIS'
declare @table_name varchar(500)

select @table_name = dep.referenced_entity_name
from sys.sql_expression_dependencies dep inner join sys.views v
on v.object_id = dep.referencing_id
inner join sys.tables t
on dep.referenced_id = t.object_id
where v.name = @view_name
and v.name like '%'+dep.referenced_entity_name+'%'

exec sp_Table_size '',@table_name
exec sp_auto_create_promoted_columns @table_name, 'CHEQUE_STATUS:bigint:0,REQUEST_DATE:bigint:0,DEPT_CODE:bigint:0', 'V', 1
