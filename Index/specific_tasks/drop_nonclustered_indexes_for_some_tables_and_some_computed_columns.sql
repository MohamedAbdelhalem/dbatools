declare @txt varchar(max) = '
[dbo].[FBNK_CUSTOMER_SECURITY]	*	CUSTOMER_TYPE	)
[dbo].[FBNK_EB_QUERIES_ANSWERS]	*	ACTIVITY_DATE	)
[dbo].[FBNK_FUNDS_TRANSFER]	*	DEPT_CODE	)
[dbo].[FBNK_FUNDS_TRANSFER#HIS]	*	PROCESSING_DATE	)
[dbo].[FBNK_FUNDS_TRANSFER#HIS]	*	AUTH_DATE	)
[dbo].[FBNK_FUNDS_TRANSFER#NAU]	*	DEPT_CODE	)
[dbo].[FBNK_FUNDS_TRANSFER#NAU]	*	TRANSACTION_TYPE	)
[dbo].[FBNK_LIMIT]	*	EXPIRY_DATE	)
[dbo].[FBNK_LIMIT]	*	UNUTIL_ACCT	)
[dbo].[FBNK_LIMIT]	*	PREV_UNUTIL_ACCT	)
[dbo].[FBNK_LIMIT]	*	UTIL_ACCOUNT	)
[dbo].[FBNK_LIMIT]	*	PREV_UTIL_ACCT	)
[dbo].[FBNK_LIMIT]	*	REVIEW_FREQUENCY	)
[dbo].[FBNK_LIMIT]	*	FX_OR_TIME_BAND	)
[dbo].[FBNK_MD_DEAL#HIS]	*	CUSTOMER	)
[dbo].[lcFBNK_LETT001]	*	APPLICANT_CUSTNO	)
[dbo].[FBNK_ACCOUNT]	*	CATEGORY	)
[dbo].[FBNK_ACCOUNT]	*	ACCOUNT_OFFICER	)
[dbo].[FBNK_ACCOUNT]	*	OPENING_DATE	)
[dbo].[F_IM_DOCUMENT_IMAGE]	*	IMAGE_REFERENCE	)'

declare @table table (syntax nvarchar(max), [schema_name] varchar(100), table_name varchar(500), index_column varchar(500), type_def varchar(1500))
insert into @table 
select 'DROP INDEX ['+index_name+'] ON ['+schema_name(schema_id)+'].['+table_name+']', schema_name(schema_id), table_name, index_name, type_desc index_type 
from (
select t.schema_id, t.name table_name, 
i.name index_name, i.is_primary_key, i.type_desc
from sys.indexes i with (nolock) inner join sys.tables t with (nolock) 
on i.object_id = t.object_id
where is_primary_key != 1
and i.type_desc not in ('HEAP','CLUSTERED')
and t.name not in ('sysdiagrams'))a
where table_name not in ('sysdiagrams')
and table_name in (select replace(replace(dbo.vertical_array(replace(replace(replace(value,char(10),''),char(9),''),0x0D00,''),'*',1),'[dbo].[',''),']','') table_name
from dbo.Separator(@txt,')'))
--order by table_name 
insert into @table 
select 'ALTER TABLE '+'['+schema_name(t.schema_id)+'].['+t.name+'] DROP COLUMN ['+cc.name+']', schema_name(t.schema_id), t.name table_name, cc.name column_name, definition
from sys.computed_columns cc inner join sys.tables t
on cc.object_id = t.object_id
where cc.object_id in (select object_id(dbo.vertical_array(replace(replace(replace(value,char(10),''),char(9),''),0x0D00,''),'*',1)) table_name
from dbo.Separator(@txt,')'))
and cc.name in (select dbo.vertical_array(replace(replace(replace(value,char(10),''),char(9),''),0x0D00,''),'*',2) column_name
from dbo.Separator(@txt,')'))
--order by table_name

select * from @table order by [schema_name], table_name, type_def desc
