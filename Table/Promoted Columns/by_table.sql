--FBNK_LETTER_OF_CREDIT	CLOSING_DATE	nvarchar	11
--FBNK_LETTER_OF_CREDIT	REP_TO_SIMAH	nvarchar	2
--FBNK_MD_DEAL			MATURITY_DATE	nvarchar	11
--FBNK_MD_DEAL			REP_TO_SIMAH	nvarchar	2
--FBNK_MD_DEAL			CATEGORY		nvarchar	6
--FBNK_PD_PAYMENT_DUE	STATUS			nvarchar	4
--FBNK_PD_PAYMENT_DUE	CATEGORY		nvarchar	6


declare 
@table_name varchar(500)  = 'F_TSA_SERVICE',
@columns_dt varchar(4000) = 'FREQUENCY:nvarchar:30,SERVICE_CONTROL:nvarchar:10'

declare @view_name varchar(500), @v varchar(10)
select top 1 @view_name = v.name 
from sys.sql_expression_dependencies dep inner join sys.views v
on v.object_id = dep.referencing_id
where dep.referenced_entity_name = @table_name
and v.name like '%'+dep.referenced_entity_name+'%'
order by v.name desc

set @v = substring(@view_name,1,charindex('_',@view_name)-1)
exec sp_Table_size '',@table_name
exec sp_Table_indexes @table_name
exec sp_auto_create_promoted_columns @table_name, @columns_dt, @v, 1,'new'

exec sp_Table_indexes @table_name
