USE [master]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_pos]    Script Date: 3/2/2023 2:02:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select [dbo].[fn_pos]('ef000008f806111554004100',2)
ALTER function [dbo].[fn_pos](@value varchar(500), @type int)
returns varchar(500)
as
begin
--declare @value varchar(500) = 'ef000023f82111103300', @type int = 2
declare @pos varchar(100), @loop int = 2, @loop_iden int = 1, @pos_2 int

--f7f81df606110239003100
--f8f004f51101
--f7f805f0016d00
--type 1 tag
--type 2 value
if charindex('11', substring(@value,1,24)) > 0 and (substring(@value, 1,2) != 'f0')
begin
	if substring(@value, 1, 4) = 'f511'
	begin
		set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 5,2)) when 1 then 7 end
	end
	else
	if substring(@value, 1, 2) = 'ef' and substring(@value, 15, 6) not like 'f8%f6' 
	begin
		select @pos = value 
		from master.dbo.Separator_2(@value,'',2)
		where id in (select max(id) - 1 from master.dbo.Separator_2(@value,'',2)
		where id < case when substring(@value,1,2) = 'ef' then (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00') and id > 4) 
														  else (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00')) end)
		select @pos_2 = (max(id) * 2) + 1 from master.dbo.Separator_2(@value,'',2)
		where id < (case when substring(@value,1,2) = 'ef' then (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00') and id > 4) 
														  else (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00')) end)
	--	while substring(@value,@loop_iden,2) != '11'
	--	begin
	--		set @loop_iden = @loop_iden + 2
	--	end
	--	while substring(@value, (@loop_iden) + @loop + 2, 2) not in ('00','06')
	--	begin
	--		select @pos =  isnull(@pos,'') + substring(@value, (@loop_iden) + @loop, 2)
	--		set @loop = @loop + 2
	--	end
	--select @pos_2 = (@loop_iden) + @loop
	select @pos = case @type when 2 then master.dbo.Hex_to_Decimal(@pos) when 1 then @pos_2 -2 end
	end
	else 
	if substring(@value, 1, 2) = 'ef' and substring(@value, 15, 6) like 'f8%f6' 
	begin
		set @pos = case @type when 2 then 0 when 1 then 20 end
	end
	else
	begin
		select @pos = value 
		from master.dbo.Separator_2(@value,'',2)
		where id in (select max(id) - 1 from master.dbo.Separator_2(@value,'',2)
		where id < case when substring(@value,1,2) = 'ef' then (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00') and id > 4) 
														  else (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00')) end)
		select @pos_2 = (max(id) * 2) + 1 from master.dbo.Separator_2(@value,'',2)
		where id < (case when substring(@value,1,2) = 'ef' then (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00') and id > 4) 
														  else (select min(id) from master.dbo.Separator_2(@value,'',2) where value in ('00','00')) end)
	--	while substring(@value,@loop_iden,2) != '11'
	--	begin
	--		set @loop_iden = @loop_iden + 2
	--	end
	--	while substring(@value, (@loop_iden) + @loop + 2, 2) not in ('00','06')
	--	begin
	--		select @pos =  isnull(@pos,'') + substring(@value, (@loop_iden) + @loop, 2)
	--		set @loop = @loop + 2
	--	end
	--select @pos_2 = (@loop_iden) + @loop
	select @pos = case @type when 2 then master.dbo.Hex_to_Decimal(@pos) when 1 then @pos_2 -2 end
	end
end
else
if charindex('11', substring(@value,1,24)) = 0 and substring(@value, 1,2) = 'ef'
begin
if substring(@value, 15, 6) like 'f8%f6' 
begin
set @pos = case @type when 2 then 0 when 1 then 20 end
end
else
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 15,2)) when 1 then 14 end
end
end

else
if substring(@value,1,2) in ('f0','f5','f6','f7','f8')
begin
set @value = substring(@value, 1, 20)
if 
substring(@value, 1, 2)      in	('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)  not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)  not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 3,2)) when 1 then 5 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)	 not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)	     in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 9,2)) when 1 then 11 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)	 not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)	 not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 5,2)) when 1 then 7 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)	 not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 7,2)) when 1 then 9 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 9,2)) when 1 then 11 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 11,2)) when 1 then 13 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2)	 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 13,2)) when 1 then 15 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)  not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)	 not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 11,2)) when 1 then 13 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)	 not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)  not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2)	 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 13,2)) when 1 then 15 end
end
else
if 
substring(@value, 1, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 3, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 5, 2)		 in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 7, 2)	 not in ('f0','f5','f6','f7','f8','11') and
substring(@value, 9, 2)		 in ('f0','f5','f6','f7','f8','11') and
substring(@value, 11, 2) not in ('f0','f5','f6','f7','f8','11') and 
substring(@value, 13, 2) not in ('f0','f5','f6','f7','f8','11') 
begin
set @pos = case @type when 2 then master.dbo.Hex_to_Decimal(substring(@value, 11,2)) when 1 then 13 end
end
end
return @pos
end

