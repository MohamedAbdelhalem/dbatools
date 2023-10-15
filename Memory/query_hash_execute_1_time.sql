select count(*), query_hash from sys.dm_exec_query_stats
where execution_count = 1
and query_hash != 0x0000000000000000
group by query_hash
order by count(*) desc

--select count(*), query_plan_hash from sys.dm_exec_query_stats
--where execution_count = 1
--and query_plan_hash != 0x0000000000000000
--group by query_plan_hash
--order by count(*) desc

select count(*) cached_plans_for_1_hash, query_hash, master.dbo.numbersize(sum(cp.size_in_bytes/1024.0), 'kb') total_cached_size
from sys.dm_exec_query_stats qs cross apply sys.dm_exec_sql_text(qs.sql_handle)s
inner join sys.dm_exec_cached_plans cp
on cp.plan_handle = qs.plan_handle 
where execution_count = 1
and query_hash != 0x0000000000000000
group by query_hash
order by sum(cp.size_in_bytes/1024.0) desc
--order by cached_plans_for_1_hash desc

--select count(*) cached_plans_for_1_hash, query_plan_hash, master.dbo.numbersize(sum(cp.size_in_bytes/1024.0), 'kb') total_cached_size
--from sys.dm_exec_query_stats qs cross apply sys.dm_exec_sql_text(qs.sql_handle)s
--inner join sys.dm_exec_cached_plans cp
--on cp.plan_handle = qs.plan_handle 
----where execution_count != 1
--where query_plan_hash != 0x0000000000000000
--group by query_plan_hash
--order by sum(cp.size_in_bytes/1024.0) desc
----order by cached_plans_for_1_hash desc

select 
s.text, qs.query_hash, qs.query_plan_hash, qs.plan_handle, cp.size_in_bytes--, --count(*) over() number_plans, sum(cp.size_in_bytes) over() total_size, sql_handle 
from sys.dm_exec_query_stats qs 
inner join sys.dm_exec_cached_plans cp
on cp.plan_handle = qs.plan_handle 
cross apply sys.dm_exec_sql_text(qs.sql_handle)s
where qs.query_hash = 0xA96D21170997C8C6

select 
s.text, qs.query_hash, qs.query_plan_hash, qs.plan_handle, cp.size_in_bytes--, --count(*) over() number_plans, sum(cp.size_in_bytes) over() total_size, sql_handle 
from sys.dm_exec_query_stats qs 
inner join sys.dm_exec_cached_plans cp
on cp.plan_handle = qs.plan_handle 
cross apply sys.dm_exec_sql_text(qs.sql_handle)s
--where qs.query_plan_hash = 0x7098A8DC3FFD0FF4
where qs.query_plan_hash != 0x0000000000000000
and text not like '%CREATE%PROCEDURE%'
and text not like '%CREATE%PROC%'
and text not like '%CREATE%FUNCTION%'
and text not like '(@_msparam_0 %'
and text not like '(%'
order by query_hash

SELECT t.RECID,t.XMLRECORD FROM FBNK_LIMI000 t WHERE XMLRECORD.exist(N'/row[some $t in c4/text() satisfies contains($t, "13783794.")]') = 1

--select sp.value, 
--s.text, query_hash, query_plan_hash, plan_handle, size_in_bytes, master.dbo.format(number_plans,-1) number_plans, master.dbo.numbersize(total_size,'byte') total_size 
--from (
--select top 1 
--qs.query_hash, qs.query_plan_hash, qs.plan_handle, cp.size_in_bytes, count(*) over() number_plans, sum(cp.size_in_bytes) over() total_size, sql_handle 
--from sys.dm_exec_query_stats qs 
--inner join sys.dm_exec_cached_plans cp
--on cp.plan_handle = qs.plan_handle 
--where qs.query_hash = 0x2AC685765B18E8DB
--)a
--cross apply sys.dm_exec_sql_text(a.sql_handle)s
--cross apply master.dbo.Separator(s.text, char(10)) sp
--order by sp.id

select sp.value, 
s.text, query_hash, query_plan_hash, plan_handle, size_in_bytes, master.dbo.format(number_plans,-1) number_plans, master.dbo.numbersize(total_size,'byte') total_size 
from (
select top 1 
qs.query_hash, qs.query_plan_hash, qs.plan_handle, cp.size_in_bytes, count(*) over() number_plans, sum(cp.size_in_bytes) over() total_size, sql_handle 
from sys.dm_exec_query_stats qs 
inner join sys.dm_exec_cached_plans cp
on cp.plan_handle = qs.plan_handle 
where qs.query_plan_hash = 0x89C20EBEFAA98FE0 --0x00D427C1DBD55DA2
)a
cross apply sys.dm_exec_sql_text(a.sql_handle)s
cross apply master.dbo.Separator(s.text, char(10)) sp
order by sp.id

declare @table table (id int identity(1,1), database_name varchar(300))
insert into @table (database_name)
exec sp_MSforeachdb 'use [?]
if object_id(''dbo.CMS_RELATIONS7'') is not null
begin
select ''?''
end'
select * from @table

use bo_rep_TST
go
declare 
@sql_statement nvarchar(max),
@parameters	nvarchar(max)
exec sp_get_query_template
N'SELECT RELTABLE.CHILDID, RELTABLE.PARENTID FROM dbo.CMS_RELATIONS7 RELTABLE  WHERE RELTABLE.RELATIONSHIPID IN (535) AND RELTABLE.CHILDID IN (1228) ORDER BY RELTABLE.ORDINAL',
@sql_statement output,
@parameters output
--select @sql_statement, @parameters
exec sp_create_plan_guide
N'DeleteTAFJ_VIEWDEP_Template',
@sql_statement,
N'TEMPLATE',
NULL,
@parameters,
N'OPTION(PARAMETERIZATION FORCED)'
go
use Data_Hub_SMS_GW
go
declare 
@sql_statement nvarchar(max),
@parameters	nvarchar(max)
exec sp_get_query_template
N'SELECT   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_RECIPIENT,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_MESSAGE,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.CREATION_TIME,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.PROCESSED_TIME FROM   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP WHERE   (    Cast(Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.PROCESSED_TIME As Date)  BETWEEN  ''11/22/2022 00:0:0''  AND  ''11/22/2022 00:0:0''    AND    Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_RECIPIENT  IN  (''966555154707'')   ) ',
@sql_statement output,
@parameters output
--select @sql_statement, @parameters
exec sp_create_plan_guide
N'DATAHUB_T24_01_Template',
@sql_statement,
N'TEMPLATE',
NULL,
@parameters,
N'OPTION(PARAMETERIZATION FORCED)'


DECLARE @stmt nvarchar(max);
	DECLARE @params nvarchar(max);
	EXEC sp_get_query_template 
	N'SELECT   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_RECIPIENT,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_MESSAGE,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.CREATION_TIME,   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.PROCESSED_TIME FROM   Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP WHERE   (    Cast(Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.PROCESSED_TIME As Date)  BETWEEN  ''01/01/2023 00:0:0''  AND  ''01/08/2023 00:0:0''    AND    Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_RECIPIENT  IN  (''966555333333'',''966505388369'')   ) ',
	 @stmt OUTPUT, @params OUTPUT;
select @stmt, @params

	--set @stmt = N'(SELECT t.RECID FROM FBNK_COLLATERAL_RIGHT t WHERE XMLRECORD.exist(N''/row[c19/text()!="LIQ" or fn:not(c19/text())]'') = 1 and RECID LIKE ''12846648%'' ESCAPE ''\'' ORDER BY RECID'
	EXEC sp_create_plan_guide 
	   N'TemplateGuide12', 
	   @stmt, 
	   N'TEMPLATE', 
	   NULL, 
	   @params, 
	   N'OPTION(PARAMETERIZATION FORCED)';
select 
s.text, a.query_hash, a.query_plan_hash, a.plan_handle
from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(a.sql_handle)s
where s.text like '%Data_Hub_SMS_GW.dbo.MESSAGE_OUT_BKP.SMS_RECIPIENT%'
where a.query_hash = 0xE0D101CA77B7D8C1



SELECT db_name(st.dbid) DBName,

object_schema_name(st.objectid, dbid) SchemaName,

object_name(st.objectid, dbid) StoredProcedure,

MAX(cp.usecounts) Execution_count,

st.text [Plan_Text]

FROM sys.dm_exec_cached_plans cp

CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st

WHERE db_name(st.dbid) IS NOT NULL

AND cp.objtype = 'proc'

GROUP BY cp.plan_handle,

db_name(st.dbid),

object_schema_name(objectid, st.dbid),

object_name(objectid, st.dbid),

st.text

ORDER BY MAX(cp.usecounts) DESC

