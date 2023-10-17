declare 
@table_name	varchar(1000) = 'SCFBNK_BAB_011',
@columns	varchar(max) = 'CUSTOMER_NO:nvarchar:8,LSF_IHLR_ID:nvarchar:10,SUB_PROD:nvarchar:20,STAFF_BRANCH:nvarchar:15',
@action		int = 1
--V_FBNK_TXN_JOURNAL" WHERE "PROCESS_DATE" >= @P0 and ("PROCESS_DATE" <= @P1 OR ("PROCESS_DATE" IS NULL OR "PROCESS_DATE" = '')) and "COMPANY_CODE" = @P2 ORDER BY "CONTINGENT_IND", "APPLICATION_ID", RECID
declare @columns_in_view table (syntax varchar(2000))
declare 
@sql			varchar(max), 
@search_columns varchar(max) 

set nocount on
select @search_columns = ISNULL(@search_columns,'')+case when id = 1 then 'and (' else 'or' end +' s.value like ''%"'+dbo.vertical_array(value,':',1)+'"%''
'
from dbo.Separator(@columns, ',')

set @sql = 'select s.value
from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s
where object_id = object_id(''V_'+@table_name+''''+')
'+@search_columns+') order by s.id'

print(@sql)
print('go')

insert into @columns_in_view
exec(@sql)

declare 
@column_name		varchar(500),
@xml_c				varchar(500),
@data_type			varchar(100),
@max_len			varchar(50),
@function_syntax	varchar(3000),
@alter_table		varchar(2000),
@Create_index		varchar(2000)

declare steps cursor fast_forward
for
select 
cv.column_name, 
substring(cv.xml_literl,charindex('/',cv.xml_literl),charindex(')',cv.xml_literl) - charindex('/',cv.xml_literl)), 
cdl.data_type, cdl.max_length
from (
select 
replace(reverse(substring(reverse(ltrim(rtrim(syntax))), 1, charindex(' ',reverse(ltrim(rtrim(syntax))))-1)),'"','') column_name,
reverse(substring(reverse(ltrim(rtrim(syntax))), charindex(' ',reverse(ltrim(rtrim(syntax))))+1, LEN(syntax))) xml_literl
from @columns_in_view
where syntax like '%XMLRECORD.value%') cv inner join (  select master.dbo.vertical_array(value,':',1) column_name,
														master.dbo.vertical_array(value,':',2) data_type,
														master.dbo.vertical_array(value,':',3) max_length
														from dbo.Separator(@columns, ','))cdl
on cv.column_name = cdl.column_name

open steps
fetch next from steps into @column_name, @xml_c, @data_type, @max_len
while @@FETCH_STATUS = 0
begin

--select case 
--when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
--else null end

set @function_syntax = '
CREATE FUNCTION [dbo].['+@table_name+'_'+
case 
when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
when dbo.vertical_array(@xml_c,'/',2) = 'row' then dbo.vertical_array(@xml_c,'/',3) 
else dbo.vertical_array(@xml_c,'/',2) end+'](@xmlrecord XML)
RETURNS '+@data_type+case when @data_type in ('varchar','nvarchar','char','nchar') then '('+@max_len+')' else '' end+'
WITH SCHEMABINDING
BEGIN
'+case when @xml_c like '%@%=%' then 'RETURN @xmlrecord.query('+''''+substring(@xml_c,1,charindex(']',@xml_c))+''''+').value(''/'+substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'[1]'+''''+', '+''''++@data_type+case when @data_type in ('varchar','nvarchar','char','nchar') then '('+@max_len+')' else '' end+''');'
else
'RETURN @xmlrecord.value(''('+@xml_c+'/text())[1]'', '+''''+@data_type+case when @data_type in ('varchar','nvarchar','char','nchar') then '('+@max_len+')' else '' end+''')' end+'
END'
print(@function_syntax)
print('go')
--RETURN @xmlrecord.value('(/row/c11/text())[1]', 'nvarchar(6)')
--RETURN @xmlrecord.query('/row/c167[@m="82"]').value('/c167[1]', 'nvarchar(16)');
--RETURN @xmlrecord.query('/row/c57[@m="3"]').value('/c57[1]', 'nvarchar(10)');


set @alter_table  = 'ALTER TABLE '+@table_name+' ADD ['+@column_name+'] AS ([dbo].['+@table_name+'_'+
case 
when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
when dbo.vertical_array(@xml_c,'/',2) = 'row' then dbo.vertical_array(@xml_c,'/',3) 
else dbo.vertical_array(@xml_c,'/',2) end+'](XMLRECORD))'
print(@alter_table)
print('go')

set @Create_index = 'CREATE NONCLUSTERED INDEX idx_'+@table_name+'_'+
case 
when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
when dbo.vertical_array(@xml_c,'/',2) = 'row' then dbo.vertical_array(@xml_c,'/',3) 
else dbo.vertical_array(@xml_c,'/',2) end+' ON '+@table_name+' (['+@column_name+']) WITH (ONLINE=ON) ON DATA'
print(@Create_index)
print('go')

fetch next from steps into @column_name, @xml_c, @data_type, @max_len
end
close steps
deallocate steps
set nocount off
