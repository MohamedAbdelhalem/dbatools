CREATE Function [dbo].[String_Postion]
(@string nvarchar(max),@separator varchar(10), @postion int)
returns nvarchar(max)
as
begin

declare @result nvarchar(max), @pos1 int, @pos2 int, @loop int = 0
while @loop < @postion
begin

set @pos1 = isnull(charindex(@separator,@string,(@pos1+1)),0)
set @pos2 = case when charindex(@separator,@string,@pos1+2) = 0 then LEN(@string)+1 else charindex(@separator,@string,@pos1+2) end
select @result = substring(@string, @pos1+1, @pos2-@pos1-1)

if charindex(@separator,@string,@pos1+1) = 0
begin
break
end
set @loop +=1
end
return @result
end
