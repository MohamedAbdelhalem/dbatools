USE [T24Prod]
GO
/****** Object:  StoredProcedure [dbo].[sp_auto_create_promoted_columns]    Script Date: 10/10/2023 8:28:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[sp_auto_create_promoted_columns]
(@table_name varchar(1000), @columns varchar(2000), @view varchar(10), @action int = 1, @WhatToDo varchar(20), @hotfix bit = 0,@print int = 0)
as
begin
declare @columns_in_view table (syntax varchar(2000), table_name varchar(500), alias varchar(10))
declare 
@sql			varchar(max), 
@search_columns1 varchar(max), 
@search_columns2 varchar(max), 
@order			varchar(max),
@test_columns	varchar(max),
@test_values	varchar(max)

set nocount on
if @WhatToDo = 'New'
begin
select 
@order = isnull(@order+'','')+' when c.value like ''%"'+dbo.vertical_array(value,':',1)+'"%''' +' then '+CAST(id as varchar(10)), 
@search_columns1 = ISNULL(@search_columns1,'')+case when id = 1 then 'and (' else 'or' end +' s.value like ''%"'+dbo.vertical_array(value,':',1)+'"%''
',
@search_columns2 = ISNULL(@search_columns2,'')+case when id = 1 then 'where (' else 'or' end +' c.value like ''%"'+dbo.vertical_array(value,':',1)+'"%''
'
from dbo.Separator(@columns, ',')

--*version 1
set @sql = 'select s.value
'+case @hotfix when 0 
then 'from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s'
else 'from sys.all_sql_modules sq cross apply master.dbo.Separator(CONVERT(varbinary(max),sq.definition),0x0D00)s'
end+'
where object_id = object_id('+''''+@view+'_'+@table_name+''''+')
'+@search_columns1+') 
order by case '+@order+' end'

--*version 2
set @sql = 'select c.value, t.table_name, t.alias
from (
select s.value, case when s.value like ''%tafjfield%'' 
then substring(s.value, charindex(''('',s.value)+1, charindex(''.'',s.value,charindex(''('',s.value)+1) - charindex(''('',s.value) - 1)
else substring(s.value, CHARINDEX('','',s.value)+1, CHARINDEX(''.'',s.value) - CHARINDEX('','',s.value) - 1) end alias
'+case @hotfix when 0 
then 'from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s'
else 'from sys.all_sql_modules sq cross apply master.dbo.Separator(CONVERT(varbinary(max),sq.definition),0x0D00)s'
end+'
where object_id = object_id('+''''+@view+'_'+@table_name+''''+')
'+@search_columns1+')) c
left outer join (
select 
replace(dbo.vertical_array(ltrim(rtrim(case when charindex(''JOIN'',s.value) > 0 then SUBSTRING(s.value, charindex(''JOIN'',s.value) +4, LEN(s.value)) else s.value end)),'' '',1),''"'','''') table_name,
dbo.vertical_array(ltrim(rtrim(case when charindex(''JOIN'',s.value) > 0 then SUBSTRING(s.value, charindex(''JOIN'',s.value) +4, LEN(s.value)) else s.value end)),'' '',2) alias
'+case @hotfix when 0 
then 'from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s'
else 'from sys.all_sql_modules sq cross apply master.dbo.Separator(CONVERT(varbinary(max),sq.definition),0x0D00)s'
end+'
where object_id = object_id('+''''+@view+'_'+@table_name+''''+')
and id > (select min(s.id) 
'+case @hotfix when 0 
then 'from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s'
else 'from sys.all_sql_modules sq cross apply master.dbo.Separator(CONVERT(varbinary(max),sq.definition),0x0D00)s'
end+'
where object_id = object_id('+''''+@view+'_'+@table_name+''''+')
and value like ''%FROM %'')
and value not like ''%ON %''
and value not like ''%WHERE %''
and value not like ''%AND %''
and value > CHAR(10)) t
on c.alias = t.alias
'+@search_columns2+') 
order by case '+@order+' end'

if @print in (0)
begin
print(@sql)
end
if @print in (1,2)
begin
exec(@sql)
end

insert into @columns_in_view
exec(@sql)

declare 
@column_name		varchar(500),
@xml_c				varchar(500),
@data_type			varchar(100),
@data_type_from		varchar(100),
@data_type_to		varchar(100),
@max_len			varchar(50),
@function_type		varchar(20),
@function_syntax	varchar(3000),
@pos				varchar(10),
@sep				varchar(10),
@drop_column		varchar(2000),
@alter_table		varchar(2000),
@index_name			varchar(255),
@drop_index			varchar(2000),
@Create_index		varchar(2000)

declare steps cursor fast_forward
for
select 
cv.column_name, 
substring(cv.xml_literl,charindex('/',cv.xml_literl),charindex(')',cv.xml_literl) - charindex('/',cv.xml_literl)), 
cdl.data_type, cdl.max_length, fun_type, sep, pos, table_name
from (
select 
replace(reverse(substring(reverse(ltrim(rtrim(syntax))), 1, charindex(' ',reverse(ltrim(rtrim(syntax))))-1)),'"','') column_name,
reverse(substring(reverse(ltrim(rtrim(syntax))), charindex(' ',reverse(ltrim(rtrim(syntax))))+1, LEN(syntax))) xml_literl,
case 
when syntax like '%XMLRECORD.value%' then 'xml' 
when syntax like '%tafjfield%' then 'tafjfield' 
end fun_type,
case when syntax like '%tafjfield%' then ltrim(rtrim(replace(dbo.vertical_array(SUBSTRING(syntax,CHARINDEX('(',syntax)+1,LEN(syntax)),',',2),'''',''))) else null end sep,
case when syntax like '%tafjfield%' then ltrim(rtrim(replace(dbo.vertical_array(SUBSTRING(syntax,CHARINDEX('(',syntax)+1,LEN(syntax)),',',3),'''',''))) else null end pos,
table_name
from @columns_in_view
) cv inner join (  select master.dbo.vertical_array(value,':',1) column_name,
														master.dbo.vertical_array(value,':',2) data_type,
														master.dbo.vertical_array(value,':',3) max_length
														from dbo.Separator(@columns, ','))cdl
on cv.column_name = cdl.column_name
where fun_type is not null

open steps
fetch next from steps into @column_name, @xml_c, @data_type, @max_len, @function_type, @sep, @pos, @table_name
while @@FETCH_STATUS = 0
begin

if @function_type = 'xml'
begin

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

end
else
if @function_type = 'tafjfield'
begin

set @function_syntax = '
Create Function [dbo].['+@table_name+'_RECID_POS](@RECID nvarchar(255), @sep varchar(50), @Pos int)
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < @Pos
begin
set @pos1 = isnull(charindex(@sep,@RECID,(@pos1+1)),0)
set @pos2 = case when charindex(@sep,@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex(@sep,@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex(@sep,@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end'
 
end

if (@action = 1)
begin
print(@function_syntax)
print('go')
end
else
if (@action = 2)
begin
exec(@function_syntax)
end
else
if (@action = 3)
begin
print(@function_syntax)
print('go')
exec(@function_syntax)
end

set @alter_table  = 'ALTER TABLE '+@table_name+' ADD ['+@column_name+'] AS ([dbo].['+@table_name+'_'+
case when @function_type = 'xml' then case 
when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
when dbo.vertical_array(@xml_c,'/',2) = 'row' then dbo.vertical_array(@xml_c,'/',3) 
else dbo.vertical_array(@xml_c,'/',2) end+'](XMLRECORD))' 
when @function_type = 'tafjfield' then 'RECID_POS](RECID, '+''''+@sep+''''+', '+@pos+'))'
end

if (@action = 1)
begin
print(@alter_table)
print('go')
end
else
if (@action = 2)
begin
exec(@alter_table)
end
else
if (@action = 3)
begin
print(@alter_table)
print('go')
exec(@alter_table)
end

set @Create_index = 'CREATE NONCLUSTERED INDEX idx_'+@table_name+'_'+
case 
when @function_type = 'xml' then case 
when @xml_c like '%@%=%' then substring(dbo.vertical_array(@xml_c,'/',3),1,charindex('[',dbo.vertical_array(@xml_c,'/',3))-1)+'_'+replace(replace(replace(replace(substring(dbo.vertical_array(@xml_c,'/',3),charindex('[',dbo.vertical_array(@xml_c,'/',3))+1, charindex(']',dbo.vertical_array(@xml_c,'/',3))-charindex('[',dbo.vertical_array(@xml_c,'/',3))),'=','_'),'@',''),']',''),'"','')
when dbo.vertical_array(@xml_c,'/',2) = 'row' then dbo.vertical_array(@xml_c,'/',3) 
else dbo.vertical_array(@xml_c,'/',2) end
when @function_type = 'tafjfield' then 'RECID_POS_'+@pos end +' ON '+@table_name+' (['+@column_name+']) WITH (ONLINE=ON) ON DATAFG'

if (@action = 1)
begin
print(@Create_index)
print('go')
end
else
if (@action = 2)
begin
exec(@Create_index)
end
else
if (@action = 3)
begin
print(@Create_index)
print('go')
exec(@Create_index)
end

fetch next from steps into @column_name, @xml_c, @data_type, @max_len, @function_type, @sep, @pos, @table_name
end
close steps
deallocate steps
end
else
if @WhatToDo = 'Alter'
begin

declare @function_script varchar(max) = ''
declare @function_script_table table (id int, object_id bigint, value nvarchar(max))
declare @definition varchar(1500), @function_name varchar(500), @function_id bigint
declare compute_cursor cursor fast_forward
for
select cc.name, case when t.name in ('nvarchar','nchar') then cc.max_length/2 else cc.max_length end, max_len, tp.datatype_from, tp.datatype_to, definition, object_id(master.dbo.vertical_array(definition,'(',2)), master.dbo.vertical_array(definition,'(',2)
from sys.computed_columns cc inner join (select 
master.dbo.vertical_array(ltrim(rtrim(value)),':',1) column_name,
master.dbo.vertical_array(master.dbo.vertical_array(ltrim(rtrim(value)),':',2),'-',1) datatype_from, 
master.dbo.vertical_array(master.dbo.vertical_array(ltrim(rtrim(value)),':',2),'-',2) datatype_to, 
master.dbo.vertical_array(ltrim(rtrim(value)),':',3) max_len 
from master.dbo.Separator(@columns,',')) tp 
on cc.name =  tp.column_name
inner join sys.types t
on cc.user_type_id = t.user_type_id
where object_id = object_id(@table_name)


open compute_cursor
fetch next from compute_cursor into @column_name, @data_type, @max_len, @data_type_from, @data_type_to, @definition, @function_id, @function_name
while @@FETCH_STATUS = 0
begin

select @index_name = i.name
from sys.indexes i inner join sys.index_columns ic
on i.object_id = ic.object_id
and i.index_id = ic.index_id
inner join sys.columns c
on ic.object_id = c.object_id
and ic.column_id = c.column_id
where i.object_id = object_id(@table_name)
and c.name = @column_name

set @drop_index = 'DROP INDEX ['+@index_name+'] ON '+@table_name
print(@drop_index)
print('go')

set @drop_column  = 'ALTER TABLE '+@table_name+' DROP COLUMN ['+@column_name+']'
print(@drop_column)
print('go')

if @hotfix = 1
begin

insert into @function_script_table 
select s.id, object_id, case 
when s.value like '%CREATE%FUNCTION%' then replace(s.value,'CREATE','ALTER') 
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','')
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','')
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('varchar','nvarchar','char','nchar') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','('+@max_len+')')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('varchar','nvarchar','char','nchar') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','('+@max_len+')')
else s.value end function_script
--from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,CHAR(10))s
from sys.all_sql_modules sq cross apply master.dbo.Separator(CONVERT(varbinary(max),sq.definition),0x0D00)s
where object_id = @function_id
order by s.id

set @function_syntax = NULL

--select @function_syntax = isnull(@function_syntax,'')+value
select @function_syntax = isnull(@function_syntax,'')+convert(nvarchar(10),0x0D00)+cast(value as nvarchar(max))
from @function_script_table
where object_id = @function_id
order by id
end
else
begin
insert into @function_script_table 
select s.id, object_id, case 
when s.value like '%CREATE%FUNCTION%' then replace(s.value,'CREATE','ALTER') 
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','')
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('int','bigint','float','integer') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','')
when s.value like '% '+@data_type_from+'%' and @data_type_to in ('varchar','nvarchar','char','nchar') then replace(replace(replace(s.value,' '+@data_type_from,' '+@data_type_to),''''+@data_type_from+'''',''''+@data_type_to+''''),'('+@data_type+')','('+@max_len+')')
when s.value like '%'+@data_type_from+'%' and @data_type_to in ('varchar','nvarchar','char','nchar') then replace(replace(s.value,''''+@data_type_from,''''+@data_type_to),'('+@data_type+')','('+@max_len+')')
else s.value end function_script
from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,CHAR(10))s
where object_id = @function_id
order by s.id

set @function_syntax = NULL

select @function_syntax = isnull(@function_syntax,'')+value
from @function_script_table
where object_id = @function_id
order by id
end


print(@function_syntax)
print('go')

set @alter_table  = 'ALTER TABLE '+@table_name+' ADD ['+@column_name+'] AS '+@definition
print(@alter_table)
print('go')

set @Create_index = 'CREATE NONCLUSTERED INDEX ['+@index_name+'] ON '+@table_name+' (['+@column_name+']) WITH (ONLINE=ON) ON DATAFG'
if @Create_index is null
begin
set @Create_index = 'CREATE NONCLUSTERED INDEX idx_'+@table_name+'_'+
replace(reverse(substring(reverse(@definition),CHARINDEX('(',reverse(@definition))+1,CHARINDEX('_',reverse(@definition))-CHARINDEX('(',reverse(@definition))-1)),']','')+
' ON '+@table_name+' (['+@column_name+']) WITH (ONLINE=ON) ON DATAFG'
end

print(@Create_index)
print('go')
print(' ')

fetch next from compute_cursor into @column_name, @data_type, @max_len, @data_type_from, @data_type_to, @definition, @function_id, @function_name
end
close compute_cursor
deallocate compute_cursor
end

select @test_columns = isnull(@test_columns+',','')+dbo.vertical_array(value,':',1)
from dbo.Separator(@columns,',')
order by id

set @test_values = 'SELECT RECID, '+@test_columns+'
from '+@view+'_'+@table_name+'
where RECID in (SELECT top 10 RECID from '+@view+'_'+@table_name+')
order by RECID'

if @print in (3)
begin

print(@test_values)
print('')

end

set @test_values = 'SELECT RECID, '+@test_columns+'
from '+@table_name+'
where RECID in (SELECT top 10 RECID from '+@table_name+')
order by RECID'

if @print in (3)
begin

print(@test_values)

end
set nocount off
end
