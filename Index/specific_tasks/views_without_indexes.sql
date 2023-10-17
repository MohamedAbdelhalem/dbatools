select s.value
from sys.all_sql_modules sq cross apply master.dbo.Separator(sq.definition,char(10))s
where object_id = object_id('V_FBNK_TXN_JOURNAL')
order by s.id

exec sp_table_size '','FBNK_TXN_JOURNAL'
select top 10 * from FBNK_TXN_JOURNAL 



,dbo.tafjfield(a.RECID,'*','1', '-2147483648') CONTINGENT_IND
,dbo.tafjfield(a.RECID,'*','2', '-2147483648') COMPANY_CODE
,dbo.tafjfield(a.RECID,'*','3', '-2147483648') PROCESS_DATE
,dbo.tafjfield(a.RECID,'*','4', '-2147483648') APPLICATION_ID
,dbo.tafjfield(a.RECID,'*','5', '-2147483648') TRANSACTION_REF
go
CREATE FUNCTION [dbo].[FBNK_TXN_JOURNAL_CONTINGENT_IND](@RECID nvarchar(255))
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
--RETURN dbo.tafjfield(@RECID,'*','2', '-2147483648')
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < 1
begin
set @pos1 = isnull(charindex('*',@RECID,(@pos1+1)),0)
set @pos2 = case when charindex('*',@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex('*',@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex('*',@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
go
CREATE FUNCTION [dbo].[FBNK_TXN_JOURNAL_COMPANY_CODE](@RECID nvarchar(255))
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
--RETURN dbo.tafjfield(@RECID,'*','2', '-2147483648')
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < 2
begin
set @pos1 = isnull(charindex('*',@RECID,(@pos1+1)),0)
set @pos2 = case when charindex('*',@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex('*',@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex('*',@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
go
CREATE FUNCTION [dbo].[FBNK_TXN_JOURNAL_RECID_Pos](@RECID nvarchar(255), @Pos int)
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
--RETURN dbo.tafjfield(@RECID,'*','2', '-2147483648')
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < @Pos
begin
set @pos1 = isnull(charindex('*',@RECID,(@pos1+1)),0)
set @pos2 = case when charindex('*',@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex('*',@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex('*',@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
go
CREATE FUNCTION [dbo].[FBNK_TXN_JOURNAL_APPLICATION_ID](@RECID nvarchar(255))
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
--RETURN dbo.tafjfield(@RECID,'*','2', '-2147483648')
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < 4
begin
set @pos1 = isnull(charindex('*',@RECID,(@pos1+1)),0)
set @pos2 = case when charindex('*',@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex('*',@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex('*',@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
go
CREATE FUNCTION [dbo].[FBNK_TXN_JOURNAL_TRANSACTION_REF](@RECID nvarchar(255))
RETURNS nvarchar(500)
WITH SCHEMABINDING
BEGIN
--RETURN dbo.tafjfield(@RECID,'*','2', '-2147483648')
declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < 5
begin
set @pos1 = isnull(charindex('*',@RECID,(@pos1+1)),0)
set @pos2 = case when charindex('*',@RECID,@pos1+2) = 0 then LEN(@RECID)+1 else charindex('*',@RECID,@pos1+2) end
select @result = substring(@RECID, @pos1+1, @pos2-@pos1-1)
if charindex('*',@RECID,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
go

ALTER TABLE [dbo].[FBNK_TXN_JOURNAL]
drop column
--[CONTINGENT_IND],
--[COMPANY_CODE],
[PROCESS_DATE],
[APPLICATION_ID],
[TRANSACTION_REF]
go
ALTER TABLE [dbo].[FBNK_TXN_JOURNAL]
ADD
--[CONTINGENT_IND]  AS ([dbo].[FBNK_TXN_JOURNAL_CONTINGENT_IND]([RECID])),
--[COMPANY_CODE]  AS ([dbo].[FBNK_TXN_JOURNAL_COMPANY_CODE]([RECID])),
[PROCESS_DATE]		AS ([dbo].[FBNK_TXN_JOURNAL_RECID_Pos]([RECID],3)),
[APPLICATION_ID]	AS ([dbo].[FBNK_TXN_JOURNAL_RECID_Pos]([RECID],4)),
[TRANSACTION_REF]	AS ([dbo].[FBNK_TXN_JOURNAL_RECID_Pos]([RECID],5))
go
go
ALTER TABLE [dbo].[FBNK_TXN_JOURNAL]
ADD
[CONTINGENT_IND]  AS ([dbo].[FBNK_TXN_JOURNAL_CONTINGENT_IND]([RECID])),
[COMPANY_CODE]  AS ([dbo].[FBNK_TXN_JOURNAL_COMPANY_CODE]([RECID])),
[PROCESS_DATE]  AS ([dbo].[FBNK_TXN_JOURNAL_PROCESS_DATE]([RECID])),
[APPLICATION_ID]  AS ([dbo].[FBNK_TXN_JOURNAL_APPLICATION_ID]([RECID])),
[TRANSACTION_REF]  AS ([dbo].[FBNK_TXN_JOURNAL_TRANSACTION_REF]([RECID]))
go

set statistics profile on
go
create nonclustered index idx_FBNK_TXN_JOURNAL_CONTINGENT_IND on FBNK_TXN_JOURNAL ([CONTINGENT_IND]) with (online=on)
go
create nonclustered index idx_FBNK_TXN_JOURNAL_COMPANY_CODE on FBNK_TXN_JOURNAL ([COMPANY_CODE]) with (online=on)
go
create nonclustered index idx_FBNK_TXN_JOURNAL_PROCESS_DATE on FBNK_TXN_JOURNAL ([PROCESS_DATE]) with (online=on)
go
create nonclustered index idx_FBNK_TXN_JOURNAL_APPLICATION_ID on FBNK_TXN_JOURNAL ([APPLICATION_ID]) with (online=on)
go
create nonclustered index idx_FBNK_TXN_JOURNAL_TRANSACTION_REF on FBNK_TXN_JOURNAL ([TRANSACTION_REF]) with (online=on)





