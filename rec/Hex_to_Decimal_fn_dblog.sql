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
go
CREATE FUNCTION [dbo].[Hex_to_Decimal]
(@Hexadecimal varchar(1000))
returns decimal(34)
as
begin
declare 
@convert	char(3),
@result		decimal(34) = 0,
@loop		bigint = 0

select @Hexadecimal = 
case when @Hexadecimal like '0x%' then substring(ltrim(rtrim(@Hexadecimal)),3,len(@Hexadecimal)) else ltrim(rtrim(@Hexadecimal)) end
while @loop < len(@Hexadecimal)
begin
select @convert = substring(reverse(@Hexadecimal),@loop+1,1)
select @convert = case @convert 
when 'A' then 10
when 'B' then 11
when 'C' then 12
when 'D' then 13
when 'E' then 14
when 'F' then 15
else @convert end
select @result = @result + (@convert * (dbo.InPower(16,@loop)))
set @loop = @loop + 1
end
return @result
end
go
create  FUNCTION [dbo].[Hex_to_Decimal_fn_dblog]
(@Hexadecimal varchar(1000))
returns decimal(34)
as
begin
declare 
@convert	varchar(50),
@decimal	varchar(50),
@result		decimal(34) = 0,
@loop		int = 0

select @Hexadecimal = 
case when @Hexadecimal like '0x%' then substring(ltrim(rtrim(@Hexadecimal)),3,len(@Hexadecimal)) else ltrim(rtrim(@Hexadecimal)) end
while @loop < len(@Hexadecimal)
begin
select @convert = substring(@Hexadecimal,@loop+1,2)+ isnull(@convert,'')
set @loop = @loop + 2
end
select @result = dbo.Hex_to_Decimal(@convert)
return @result
end
