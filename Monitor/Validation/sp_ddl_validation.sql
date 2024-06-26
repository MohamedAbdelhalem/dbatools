
CREATE procedure [dbo].[sp_ddl_validation]
(
@ddl_script varchar(max), @sep varchar(100), 
@command varchar(100),
@is_table_exist int,
@is_column_exist int,
@is_index_exist int,
@is_function_exist int,
@is_main_function_exist int
)
as
begin

declare @result table (syntax varchar(max), command varchar(500), sub_command varchar(500), table_name varchar(500), is_table_exist varchar(500), rows varchar(500), column_name varchar(500), is_column_exist varchar(500), function_name varchar(500), is_function_exist varchar(500), index_name varchar(500), is_index_exist varchar(500))
  
set transaction isolation level read uncommitted 
--insert into @result
--select syntax, command, sub_command, 
--table_name, 
--is_table_exist, 
--(select max(rows) from sys.partitions  with (nolock) where object_id = object_id(table_name)) rows,
----0 rows,
--column_name, 
--is_column_exist, 
--fn_name, 
--is_function_exist, 
--index_name, 
--is_index_exist 
--from (
select * from (
select id, syntax, command, sub_command, table_name, column_name,fn_name,index_name,function_name, substring(function_returns,1,charindex(CHAR(10),function_returns)-len(CHAR(10))) function_returns,
case when sub_command = 'Add Column' or command = 'Create Index' then case when (select count(*) from sys.columns  with (nolock) where name = column_name collate Arabic_100_CI_AS and object_id = object_id(table_name collate Arabic_100_CI_AS)) > 0 then 1 else 0 end 
else '' end is_column_exist,
case when sub_command in ('Add Column') or command in ('Create Index','Drop Index') then case when (select count(*) from sys.tables  with (nolock) where object_id = object_id(table_name collate Arabic_100_CI_AS)) > 0 then 1 else 0 end 
else '' end is_table_exist,
case when sub_command = 'Add Column' then case when (select count(*) from sys.objects with (nolock) where object_id = object_id(fn_name collate Arabic_100_CI_AS) and type = 'fn') > 0 then 1 else 0 end 
else '' end is_function_exist,
case when command in ('Create Index','Drop Index') then case when (select count(*) from sys.indexes with (nolock) where name = replace(replace(index_name,']',''),'[','') collate Arabic_100_CI_AS and object_id = object_id(table_name collate Arabic_100_CI_AS)) > 0 then 1 else 0 end 
else '' end is_index_exist,
case when command in ('Create Function','Drop Function') then case when (select count(*) from sys.objects with (nolock) where object_id = object_id(function_name collate Arabic_100_CI_AS) and type = 'fn') > 0 then 1 else 0 end 
else '' end is_main_function_exist
from (
select id, syntax, command, sub_command, 
case 
when substring(table_name, 1, charindex(' ',table_name)-1) like '%(%' then substring(table_name, 1, charindex('(',table_name)-1)
else substring(table_name, 1, charindex(' ',table_name)-1) end
table_name, 
case 
when substring(fn_name, 1, charindex(' ',fn_name)-1) like '%(%' then substring(fn_name, 1, charindex('(',fn_name)-1)
else substring(fn_name, 1, charindex(' ',fn_name)-1) end
fn_name, 
case command 
when 'Alter Table' then substring(column_name, 1, charindex(' ',column_name)-1) 
when 'Create Index' then substring(replace(replace(column_name,' ASC',''),' DESC',''), 1, charindex(')',replace(replace(column_name,' ASC',''),' DESC',''))-1) 
end
column_name, 
substring(index_name, 1, charindex(' ',index_name)-1) index_name,
substring(function_name, 1, charindex(' ',function_name)-1) function_name,
substring(returns_datatype,charindex('returns',returns_datatype)+8,len(returns_datatype)) function_returns
from (
select id, syntax, command,
case when command = 'Alter Table' then case 
when syntax like '% add %' then 'Add Column'
when syntax like '% drop %' then 'Drop Column'
end end sub_command,
case 
when command = 'Alter Table' then substring(syntax, charindex(' table ',syntax)+7, len(syntax)) 
when command = 'Create Table' then substring(syntax, charindex(' table ',syntax)+7, len(syntax)) 
when command = 'Drop Table' then substring(syntax, charindex(' table ',syntax)+7, len(syntax)) 
when command = 'Create Index' then substring(syntax, charindex(' on ',syntax)+4, len(syntax)) 
when command = 'Drop Index' then substring(syntax, charindex(' on ',syntax)+4, len(syntax)) 
end table_name,
case 
when command = 'Alter Table' then substring(syntax, charindex(' as ',syntax)+4, len(syntax)) 
end fn_name,
case 
when command = 'Alter Table' then substring(syntax, charindex(' add ',syntax)+5, len(syntax)) 
when command = 'Alter Table' then substring(syntax, charindex(' drop ',syntax)+5, len(syntax)) 
when command = 'create index' then substring(syntax, charindex('(',syntax)+1, len(syntax)) 
end column_name,
case 
when command = 'Create Index' then substring(syntax, charindex(' index ',syntax)+7, len(syntax)) 
when command = 'Drop Index' then substring(syntax, charindex(' index ',syntax)+7, len(syntax)) 
end index_name,
case 
when command = 'Create Function' then substring(syntax, charindex(' Function ',syntax)+10, len(syntax)) 
end function_name,
case 
when command = 'Create Function' then substring(syntax, charindex(' returns ',syntax)+10, len(syntax)) 
end returns_datatype
from (
select id, [value] syntax, case 
when ltrim([value]) like '%create function%' then 'CREATE Function'
when ltrim([value]) like '%alter table%' then 'Alter Table'
when ltrim([value]) like '%create table%' then 'Create Table'
when ltrim([value]) like '%drop table%' then 'Drop Table'
when ltrim([value]) like '%create%index%' then 'Create Index'
when ltrim([value]) like '%drop%index%' then 'Drop Index'
end command
from master.[dbo].[Separator](@ddl_script,@sep))a
where command is not null)b)c)d
where command = @command
and is_table_exist = @is_table_exist
and is_column_exist = @is_column_exist
and is_index_exist = @is_index_exist
and is_function_exist = @is_function_exist
and is_main_function_exist = @is_main_function_exist
end
