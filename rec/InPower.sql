CREATE FUNCTION [dbo].[InPower]
(@number decimal(34), @position int)
returns decimal(34)
as
begin
declare 
@loop int = 0, @result decimal(34) = 1
while @loop < @position 
begin
set @result = @result * @number
set @loop = @loop + 1
end
return case when @result = 0 then 1 else @result end
end