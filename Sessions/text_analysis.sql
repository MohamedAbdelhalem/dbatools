USE [master]
GO
/****** Object:  UserDefinedFunction [dbo].[text_analysis]    Script Date: 6/8/2022 6:00:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON

go

create function [dbo].[text_analysis] (@sql_text varchar(max))
returns @table table (syntax varchar(max), snap_action varchar(200), command varchar(100), sub_command varchar(100), table_name varchar(350), column_name varchar(350), fn_name varchar(350), index_name varchar(350))
as
begin

insert into @table 
select syntax, substring(syntax, 1, 100), command, sub_command, table_name, 
case command
when 'Alter Table' then ltrim(rtrim(substring(column_name, 1, charindex(' ',column_name)-1)))
when 'Create Index' then ltrim(rtrim(substring(replace(replace(column_name,' ASC',''),' DESC',''), 1, charindex(')',replace(replace(column_name,' ASC',''),' DESC',''))-1))) 
end
column_name, 
fn_name,index_name
from (
select syntax, command, sub_command, 
case 
when substring(table_name, 1, charindex(' ',table_name)-1) like '%(%' then substring(table_name, 1, charindex('(',table_name)-1)
else substring(table_name, 1, charindex(' ',table_name)-1) end
table_name, 
case when fn_name != 'not a compute column' then 
case 
when substring(fn_name, 1, charindex(' ',fn_name)-1) like '%(%' then substring(fn_name, 1, charindex('(',fn_name)-1)
else substring(fn_name, 1, charindex(' ',fn_name)-1) end
else fn_name end
fn_name, 
case 
when command = 'Alter Table' and sub_command = 'Alter Column' then substring(syntax, charindex(' column ',syntax)+8, len(syntax)) 
when command = 'Alter Table' and sub_command = 'Add Column' then substring(syntax, charindex(' column ',syntax)+8, len(syntax)) 
when command = 'Alter Table' and sub_command = 'Drop Column' then substring(syntax, charindex(' drop ',syntax)+6, len(syntax)) 
when command = 'Alter Table' and sub_command = 'Add Constraint' then substring(syntax, charindex(' (',syntax)+2, len(syntax)) 
when command = 'create index' then substring(syntax, charindex('(',syntax)+1, len(syntax)) 
end column_name,
substring(index_name, 1, charindex(' ',index_name)-1) index_name 
from (
select syntax, command,
case 
when command = 'Alter Table' then 
case 
when syntax like '% alter column %' then 'Alter Column'
when syntax like '% add%constraint %' then 'Add Constraint'
when syntax like '% add column %' then 'Add Column'
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
when command = 'Alter Table' then case when charindex(' as ', syntax) > 0 then substring(syntax, charindex(' as ',syntax)+4, len(syntax)) else 'not a compute column' end 
end fn_name,
case 
when command = 'Create Index' then substring(syntax, charindex(' index ',syntax)+7, len(syntax)) 
when command = 'Drop Index' then substring(syntax, charindex(' index ',syntax)+7, len(syntax)) 
end index_name
from (
select [value] syntax, case 
when ltrim([value]) like '%alter%table%' then 'Alter Table'
when ltrim([value]) like '%create%table%' then 'Create Table'
when ltrim([value]) like '%drop%table%' then 'Drop Table'
when ltrim([value]) like '%create%index%' then 'Create Index'
when ltrim([value]) like '%drop%index%' then 'Drop Index'
end command
from (select @sql_text [value])a_
)a)b)c

return 
end
GO

select * from dbo.text_analysis('ALTER TABLE [dbo].[MailboxBase] ADD  CONSTRAINT [PK_mailboxBase] PRIMARY KEY CLUSTERED ([MailboxId] ASC)')