declare @validation_syntax table (id int identity(1,1), syntax nvarchar(max))
declare @s nvarchar(max) = 'use [T24PROD_PT]
go
CREATE FUNCTION dbo.FBNK_LIMIT_C7 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c7/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LIMIT ADD EXPIRY_DATE AS dbo.FBNK_LIMIT_C7(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_EXPIRY_DATE_LIMIT_C7 ON FBNK_LIMIT(EXPIRY_DATE)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C110 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c110/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LIMIT ADD UNUTIL_ACCT AS dbo.FBNK_LIMIT_C110(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_UNUTIL_ACCT_LIMIT_C110 ON FBNK_LIMIT(UNUTIL_ACCT)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C113 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c113/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LIMIT ADD PREV_UNUTIL_ACCT AS dbo.FBNK_LIMIT_C113(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_PREV_UNUTIL_ACCT_LIMIT_C113 ON FBNK_LIMIT(PREV_UNUTIL_ACCT)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C118 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c118/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LIMIT ADD UTIL_ACCOUNT AS dbo.FBNK_LIMIT_C118(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_UTIL_ACCOUNT_LIMIT_C118 ON FBNK_LIMIT(UTIL_ACCOUNT)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C120 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c120/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LIMIT ADD PREV_UTIL_ACCT AS dbo.FBNK_LIMIT_C120(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_PREV_UTIL_ACCT_LIMIT_C120 ON FBNK_LIMIT(PREV_UTIL_ACCT)
GO
CREATE FUNCTION dbo.FBNK_MD_DEAL#HIS_C1 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c1/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_MD_DEAL#HIS ADD CUSTOMER AS dbo.FBNK_MD_DEAL#HIS_C1(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CUSTOMER_MD_DEAL#HIS_C1 ON FBNK_MD_DEAL#HIS(CUSTOMER)
GO
CREATE FUNCTION dbo.FBNK_LETTER_OF_CREDIT_C9 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c9/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_LETTER_OF_CREDIT ADD APPLICANT_CUSTNO AS dbo.FBNK_LETTER_OF_CREDIT_C9(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_APPLICANT_CUSTNO_LETTER_OF_CREDIT_C9 ON FBNK_LETTER_OF_CREDIT(APPLICANT_CUSTNO)
GO
CREATE FUNCTION dbo.FBNK_FUNDS_TRANSFER_C225 (@xmlrecord XML)
RETURNS nvarchar(4)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c225/text())[1]'', ''nvarchar(4)'')
END
GO
ALTER TABLE FBNK_FUNDS_TRANSFER ADD DEPT_CODE AS dbo.FBNK_FUNDS_TRANSFER_C225(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_DEPT_CODE_FUNDS_TRANSFER_C225 ON FBNK_FUNDS_TRANSFER(DEPT_CODE)
GO
CREATE FUNCTION dbo.FBNK_FUNDS_TRANSFER#NAU_C225 (@xmlrecord XML)
RETURNS nvarchar(4)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c225/text())[1]'', ''nvarchar(4)'')
END
GO
ALTER TABLE FBNK_FUNDS_TRANSFER#NAU ADD DEPT_CODE AS dbo.FBNK_FUNDS_TRANSFER#NAU_C225(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_DEPT_CODE_FUNDS_TRANSFER#NAU_C225 ON FBNK_FUNDS_TRANSFER#NAU(DEPT_CODE)
GO
CREATE FUNCTION dbo.FBNK_FUNDS_TRANSFER#NAU_C1 (@xmlrecord XML)
RETURNS nvarchar(4)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c1/text())[1]'', ''nvarchar(4)'')
END
GO
ALTER TABLE FBNK_FUNDS_TRANSFER#NAU ADD TRANSACTION_TYPE AS dbo.FBNK_FUNDS_TRANSFER#NAU_C1(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_TRANSACTION_TYPE_FUNDS_TRANSFER#NAU_C1 ON FBNK_FUNDS_TRANSFER#NAU(TRANSACTION_TYPE)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C6 (@xmlrecord XML)
RETURNS nvarchar(17)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c6/text())[1]'', ''nvarchar(17)'')
END
GO
ALTER TABLE FBNK_LIMIT ADD REVIEW_FREQUENCY AS dbo.FBNK_LIMIT_C6(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_REVIEW_FREQUENCY_LIMIT_C6 ON FBNK_LIMIT(REVIEW_FREQUENCY)
GO
CREATE FUNCTION dbo.FBNK_LIMIT_C95 (@xmlrecord XML)
RETURNS nvarchar(35)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c95/text())[1]'', ''nvarchar(35)'')
END
GO
ALTER TABLE FBNK_LIMIT ADD LIABILITY_NUMBER AS dbo.FBNK_LIMIT_C95(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_LIABILITY_NUMBER_LIMIT_C95 ON FBNK_LIMIT(LIABILITY_NUMBER)
GO
CREATE FUNCTION dbo.FBNK_ACCOUNT_C2 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c2/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_ACCOUNT ADD CATEGORY AS dbo.FBNK_ACCOUNT_C2(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CATEGORY_FBNK_ACCOUNT_C2 ON FBNK_ACCOUNT(CATEGORY)
GO
CREATE FUNCTION dbo.FBNK_ACCOUNT_C11 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c11/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_ACCOUNT ADD ACCOUNT_OFFICER AS dbo.FBNK_ACCOUNT_C11(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_ACCOUNT_OFFICER_FBNK_ACCOUNT_C11 ON FBNK_ACCOUNT(ACCOUNT_OFFICER)
GO
CREATE FUNCTION dbo.FBNK_ACCOUNT_C78 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c78/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_ACCOUNT ADD OPENING_DATE AS dbo.FBNK_ACCOUNT_C78(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_OPENING_DATE_FBNK_ACCOUNT_C78 ON FBNK_ACCOUNT(OPENING_DATE)
GO
CREATE FUNCTION dbo.F_IM_DOCUMENT_IMAGE_C4 (@xmlrecord XML)
RETURNS nvarchar(35)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c4/text())[1]'', ''nvarchar(35)'')
END
GO
ALTER TABLE F_IM_DOCUMENT_IMAGE ADD IMAGE_REFERENCE AS dbo.F_IM_DOCUMENT_IMAGE_C4(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_IMAGE_REFERENCE_C4 ON F_IM_DOCUMENT_IMAGE(IMAGE_REFERENCE)
GO
CREATE FUNCTION dbo.FBNK_BAB_CARD_ISSUE_C15 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c15/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_BAB_CARD_ISSUE ADD ISSUE_DATE AS dbo.FBNK_BAB_CARD_ISSUE_C15(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_ISSUE_DATE_C45_BAB_CARD_ISSUE ON FBNK_BAB_CARD_ISSUE(ISSUE_DATE)
GO
CREATE FUNCTION dbo.FBNK_BAB_VISA_CRD_ISSUE_C5 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c5/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FBNK_BAB_VISA_CRD_ISSUE ADD CUSTOMER AS dbo.FBNK_BAB_VISA_CRD_ISSUE_C5(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CUSTOMER_C5_BAB_VISA_CRD_ISSUE ON FBNK_BAB_VISA_CRD_ISSUE(CUSTOMER)
GO
CREATE FUNCTION dbo.FBNK_CUSTOMER_CUSTOMER_TYPE_C101 (@xmlrecord XML)
RETURNS nvarchar(35)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c101/text())[1]'', ''nvarchar(35) '') 
END
GO
ALTER TABLE dbo.FBNK_CUSTOMER ADD CUSTOMER_TYPE AS dbo.FBNK_CUSTOMER_CUSTOMER_TYPE_C101(XMLRECORD) --PERSISTED;
GO
CREATE NONCLUSTERED INDEX IX_CUSTOMER_TYPE_FBNK_CUSTOMER_C101 ON dbo.FBNK_CUSTOMER(CUSTOMER_TYPE ASC);
GO
CREATE FUNCTION dbo.FBNK_CUSTOMER_c179m13  (@xmlrecord XML)
RETURNS nvarchar(45)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c179[@m="13"]/text())[1]'', ''nvarchar(45) '') 
END
GO
ALTER TABLE dbo.FBNK_CUSTOMER ADD MOBILE_NO AS dbo.FBNK_CUSTOMER_c179m13(XMLRECORD) --PERSISTED;
GO
CREATE NONCLUSTERED INDEX MOBILE_NO_CUSTOMER_c179m13 ON dbo.FBNK_CUSTOMER(MOBILE_NO ASC);
GO
CREATE FUNCTION dbo.FENJ_FUND200_C18 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c18/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FENJ_FUND200 ADD PROCESSING_DATE AS dbo.FENJ_FUND200_C18(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_PROCESSING_DATE_FENJ_FUND200_C18 ON FENJ_FUND200(PROCESSING_DATE)
GO
CREATE FUNCTION dbo.FENJ_FUND200_C153 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c153/text())[1]'', ''bigint'')
END
GO
ALTER TABLE FENJ_FUND200 ADD AUTH_DATE AS dbo.FENJ_FUND200_C153(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_AUTH_DATE_FENJ_FUND200_C153 ON FENJ_FUND200(AUTH_DATE)
GO
CREATE FUNCTION dbo.F_BAB_L_REM_FT_TRACK_C28 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c28/text())[1]'', ''bigint''
END
GO
ALTER TABLE F_BAB_L_REM_FT_TRACK ADD REM_TXN_DATE AS dbo.F_BAB_L_REM_FT_TRACK_C28(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_REM_TXN_DATE_F_BAB_L_REM_FT_TRACK_C28 ON F_BAB_L_REM_FT_TRACK(REM_TXN_DATE)
GO
CREATE FUNCTION dbo.F_BAB_L_REM_FT_TRACK_C1 (@xmlrecord XML)
RETURNS nvarchar(10)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c1/text())[1]'', ''nvarchar(10)''
END
GO
ALTER TABLE F_BAB_L_REM_FT_TRACK ADD TXN_TYPE AS dbo.F_BAB_L_REM_FT_TRACK_C1(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_TXN_TYPE_F_BAB_L_REM_FT_TRACK_C1 ON F_BAB_L_REM_FT_TRACK(TXN_TYPE)
GO
CREATE FUNCTION dbo.F_BAB_L_REM_FT_TRACK_C2 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c2/text())[1]'', ''bigint''
END
GO
ALTER TABLE F_BAB_L_REM_FT_TRACK ADD CUSTOMER AS dbo.F_BAB_L_REM_FT_TRACK_C2(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CUSTOMER_F_BAB_L_REM_FT_TRACK_C2 ON F_BAB_L_REM_FT_TRACK(CUSTOMER)
GO
CREATE FUNCTION dbo.F_BAB_L_REM_FT_TRACK_C4 (@xmlrecord XML)
RETURNS nvarchar(10)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c4/text())[1]'', ''nvarchar(10)''
END
GO
ALTER TABLE F_BAB_L_REM_FT_TRACK ADD CHANNEL_REF AS dbo.F_BAB_L_REM_FT_TRACK_C4(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CHANNEL_REF_F_BAB_L_REM_FT_TRACK_C4 ON F_BAB_L_REM_FT_TRACK(CHANNEL_REF)
GO
CREATE FUNCTION dbo.F_BAB_L_REM_FT_TRACK_C12 (@xmlrecord XML)
RETURNS nvarchar(2)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c12/text())[1]'', ''nvarchar(2)''
END
GO
ALTER TABLE F_BAB_L_REM_FT_TRACK ADD BEN_COUNTRY AS dbo.F_BAB_L_REM_FT_TRACK_C12(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_BEN_COUNTRY_F_BAB_L_REM_FT_TRACK_C12 ON F_BAB_L_REM_FT_TRACK(BEN_COUNTRY)
GO
CREATE FUNCTION dbo.FENJ_ACCOUNT_C78 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c78/text())[1]'', ''bigint''
END
GO
ALTER TABLE FENJ_ACCOUNT ADD OPENING_DATE AS dbo.FENJ_ACCOUNT_C78(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_OPENING_DATE_FENJ_ACCOUNT_C78 ON FENJ_ACCOUNT(OPENING_DATE)
GO
CREATE FUNCTION dbo.FENJ_ACCOUNT_C2 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c2/text())[1]'', ''bigint''
END
GO
ALTER TABLE FENJ_ACCOUNT ADD CATEGORY AS dbo.FENJ_ACCOUNT_C2(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_CATEGORY_FENJ_ACCOUNT_C2 ON FENJ_ACCOUNT(CATEGORY)
GO
CREATE FUNCTION dbo.FENJ_ACCOUNT_C11 (@xmlrecord XML)
RETURNS bigint
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c11/text())[1]'', ''bigint''
END
GO
ALTER TABLE FENJ_ACCOUNT ADD ACCOUNT_OFFICER AS dbo.FENJ_ACCOUNT_C11(XMLRECORD) --PERSISTED
GO
CREATE INDEX IX_ACCOUNT_OFFICER_FENJ_ACCOUNT_C11 ON FENJ_ACCOUNT(ACCOUNT_OFFICER)
GO
CREATE FUNCTION dbo.FBNK_BAB_VISA_CRD_ISSUE_c64 (@xmlrecord XML)
RETURNS nvarchar(15)
WITH SCHEMABINDING
BEGIN
RETURN @xmlrecord.value(''(/row/c64/text())[1]'', ''nvarchar(15) '') 
END
GO
ALTER TABLE dbo.FBNK_BAB_VISA_CRD_ISSUE ADD SELL_STAFF_ID AS dbo.FBNK_BAB_VISA_CRD_ISSUE_c64 (XMLRECORD) --PERSISTED;
GO
CREATE NONCLUSTERED INDEX SELL_STAFF_ID_BAB_VISA_CRD_ISSUE_c64 ON dbo.FBNK_BAB_VISA_CRD_ISSUE(SELL_STAFF_ID ASC);
GO
'

insert into @validation_syntax
select value from master.dbo.Separator(@s,char(10))
order by id

declare @validation_syntax_2 table (id int, syntax varchar(max), line_group int, line_group_id int, DDL_command varchar(100))

insert into @validation_syntax_2

select id, syntax, line_group, line_group_id, case when line_group_id = 1 then 
case 
when syntax like '%CREATE%FUNCTION%' then 'CREATE FUNCTION'
when syntax like '%ALTER%FUNCTION%' then 'ALTER FUNCTION'
when syntax like '%DROP%FUNCTION%' then 'DROP FUNCTION'
when syntax like '%CREATE%INDEX%' then 'CREATE INDEX'
when syntax like '%DROP%INDEX%' then 'DROP INDEX'
when syntax like '%ALTER%TABLE%' then 'ALTER TABLE'
end 
when syntax like 'RETURN%' then master.dbo.vertical_array(ltrim(rtrim(syntax)), ' ', 2) 
else '' end 
from (
select id, syntax, g, line_group, row_number() over(partition by line_group order by id) line_group_id
from (
select id, syntax, case when syntax like '%go%' and len(syntax) < 5 then 'go' else '' end g, (select gid from (
select id, gid, case when go_between = 0 then (select count(*) from @validation_syntax) else go_between end go_between
from (
select id, g, gid, lag(id,1,1) over(order by id desc) - 1 go_between
from (
select top 100 percent id, g, case when g = 'go' then row_number() over(partition by g order by id) else 0 end gid
from (
select id, syntax, case when syntax like '%go%' and len(syntax) < 5 then 'go' else '' end g
from @validation_syntax)a
order by id
)b
where g = 'go')c
)d where a.id between d.id and d.go_between) line_group
from @validation_syntax a)e
where g != 'go'
and line_group is not null)f
order by id

select * from (
select id, syntax, line_group, line_group_id, DDL_command, [object_name], returns_tname_operation, replace(replace(ltrim(rtrim(substring(return_fun,charindex(',',return_fun)+1,len(return_fun)))),'''',''),')','') function_data_type,
replace(case when DDL_command in ('CREATE FUNCTION','ALTER FUNCTION') then substring(return_tname_cname,1,charindex(',',return_tname_cname)-1) else return_tname_cname end,'''','') return_tname_cname, 
replace(substring(return_fun,1,charindex(',',return_fun)-1),'''','') function_return
from (
select b.id, syntax, line_group, line_group_id, DDL_command, [object_name], returns_tname_operation,
case when DDL_command in ('CREATE FUNCTION','ALTER FUNCTION') then substring(return_tname_cname,charindex('/',return_tname_cname),len(return_tname_cname)) else return_tname_cname end return_tname_cname, 
substring(fn.value,charindex('/',fn.value),len(fn.value)) return_fun
from (
select *
from (
select top 100 percent id, syntax, line_group, line_group_id, DDL_command, 
case 
when line_group_id = 1 and DDL_command = 'CREATE FUNCTION' then master.dbo.vertical_array(syntax,' ',3)
when line_group_id = 1 and DDL_command = 'ALTER FUNCTION'  then master.dbo.vertical_array(syntax,' ',3)
when line_group_id = 1 and DDL_command = 'DROP FUNCTION'   then master.dbo.vertical_array(syntax,' ',3)
when line_group_id = 1 and DDL_command = 'CREATE INDEX'    then case when master.dbo.vertical_array(syntax,' ',2) in ('nonclustered','clustered') then master.dbo.vertical_array(syntax,' ',4) else master.dbo.vertical_array(syntax,' ',3) end
when line_group_id = 1 and DDL_command = 'DROP INDEX'      then master.dbo.vertical_array(syntax,' ',3)
when line_group_id = 1 and DDL_command = 'ALTER TABLE'     then master.dbo.vertical_array(syntax,' ',3)
end object_name,
case
when line_group_id = 1 and DDL_command = 'CREATE FUNCTION' then lag(DDL_command,1,1) over(order by id desc)
when line_group_id = 1 and DDL_command = 'ALTER FUNCTION'  then lag(DDL_command,1,1) over(order by id desc)
when line_group_id = 1 and DDL_command = 'CREATE INDEX'    then substring(master.dbo.vertical_array(syntax,'(',2),1,charindex(')',master.dbo.vertical_array(syntax,'(',2))-1)
when line_group_id = 1 and DDL_command = 'ALTER TABLE'     then master.dbo.vertical_array(syntax,' ',4)
end returns_tname_operation,
case
when line_group_id = 1 and DDL_command = 'CREATE FUNCTION' then lag(DDL_command,4,4) over(order by id desc)
when line_group_id = 1 and DDL_command = 'ALTER FUNCTION'  then lag(DDL_command,4,4) over(order by id desc)
when line_group_id = 1 and DDL_command = 'CREATE INDEX'    then master.dbo.vertical_array(case when master.dbo.vertical_array(syntax,' ',2) in ('nonclustered','clustered') then master.dbo.vertical_array(syntax,' ',6) else master.dbo.vertical_array(syntax,' ',5) end,'(',1)
when line_group_id = 1 and DDL_command = 'ALTER TABLE'     then master.dbo.vertical_array(syntax,' ',5)
end return_tname_cname
from @validation_syntax_2
order by id)a
where line_group_id = 1 
and DDL_command is not null)b left outer join (select sp.*, o.object_id, o.name function_name
from T24PROD_PT.sys.all_sql_modules s inner join T24PROD_PT.sys.objects o
on s.object_id = o.object_id
and o.type = 'FN'
cross apply master.dbo.Separator(s.definition,char(10))sp
where sp.value like 'RETURN %') fn
on case when charindex('.',b.object_name) > 0 then substring(b.object_name,charindex('.',b.object_name)+1,len(b.object_name)) else b.object_name end = fn.function_name)r)t
where DDL_command = 'create function'
order by id
