USE [master]
GO

CREATE Function [dbo].[Separator_2]
(@str nvarchar(max), @sepr nvarchar(100), @length int = 0)
returns @table table (id int identity(1,1), [value] nvarchar(550))
as
begin
declare 
@word   nvarchar(550), 
@len    int, 
@s_ind  int, 
@f_ind  int,
@loop   int = 0

set @len  = LEN(@str)
set @f_ind = 1

if @length > 0 
begin
	while @len > @length
	begin
		set @word = substring(@str, case when @length * @loop = 0 then 1 else (@length * @loop) + 1 end, @length)
		set @str = substring(@str , case when @length * @loop = 0 then 1 else (@length * @loop) + 1 end, len(@str))
		set @len   = len(@str)	
		insert into @table 
		select @word
		set @loop =+1
	end
end
else
begin
	while @f_ind > 0
	begin
		set @f_ind = case when charindex(@sepr,@str)-1 < 0 then 0 else charindex(@sepr,@str)-1 end
		set @s_ind = charindex(@sepr,@str) + len(@sepr)
		set @len   = len(@str)
		set @word  = case when substring(@str , 1, @f_ind) = '' then @str else substring(@str , 1, @f_ind) end
		if len(@sepr) > 1
		begin
			set @word  = case when @loop = 0 then @word else substring(@word, len(@sepr) , len(@word)) end
		end
		set @str   = substring(@str , @s_ind- len(@sepr)+1, len(@str))
		insert into @table 
		select @word
		set @loop =+1
	end
end
return
end
