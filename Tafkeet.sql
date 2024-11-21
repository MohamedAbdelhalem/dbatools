USE [Consolidation]
GO
/****** Object:  UserDefinedFunction [dbo].[Tafkeet]    Script Date: 11/22/2024 1:38:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[Tafkeet](@Number int, @currency varchar(5))
returns nvarchar(250)
as
Begin
declare 
@len int, 
@result nvarchar(100), 
@loop int, 
@trans nvarchar(100),
@currency_char nvarchar(50)
set @loop = 0
set @len = len(@number)
set @result = ''

select @currency_char = currency_long_arabic
from currency
where currency_short_arabic = @currency

if @len = 1 begin
  select @result = trans
    from Arb_numbers
   where number = @number
     and cat = '0'
end

if @len = 2
begin
    while @loop < @len begin
      set @loop = @loop +1
	  if @loop = 1 begin
	    select @trans = trans
          from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)),2,1) as int)
           and cat = case cast(substring(cast(@number as varchar(100)),1,1) as int) when 1 then
		  case cast(substring(cast(@number as varchar(100)),2,1) as int) 
          when 2 then 6 when 1 then 2 else 0 end else 0 end
      end
      if @loop = 2 begin
	    select @trans = trans
          from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)), 1, 1) as int) * 10
           and cat = case cast(substring(cast(@number as varchar(100)), 1, 1) as int) when 1 then 
		   case cast(substring(cast(@number as varchar(100)),2,1) as int)  
		   when 0 then '0' else '+' end else '0' end
      end
    if @trans != N'صفر' and @loop != 2 begin 
	  set @result = @result+ N' '+@trans 
	end
    if @trans != N'صفر' and @loop = 2 begin 
	  if cast(substring(cast(@number as varchar(100)), @loop-1, 1) as int) = 1 begin
	    set @result = @result+ N' '+@trans
	    set @result = substring(@result, 1, len(@result))
	  end
	  if cast(substring(cast(@number as varchar(100)), @loop-1, 1) as int) > 1 begin
	    set @result = @result+ N' و '+@trans
	    set @result = substring(@result, 2, len(@result))
	  end
    end
--select 	cast(substring(cast(30 as varchar(100)), 1-1, 1) as int) 
end
end

if @len = 3 begin
  while @loop < @len begin
    set @loop = @loop +1
	if @loop = 1 begin
	  select @trans = trans
        from Arb_numbers
       where number = cast(substring(cast(@number as varchar(100)), 1, 1) as int) * 100
         and cat = 0
	end
	if @loop = 2 begin
	  select @trans = trans
        from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)),3,1) as int)
           and cat = case cast(substring(cast(@number as varchar(100)),2,1) as int) when 1 then
		  case cast(substring(cast(@number as varchar(100)),3,1) as int) 
          when 2 then 6 when 1 then 2 else 0 end else 0 end
    end
    if @loop = 3 begin
	  select @trans = trans
       from Arb_numbers
       where number = cast(substring(cast(@number as varchar(100)), 2, 1) as int) * 10
         and cat = case cast(substring(cast(@number as varchar(100)), 2, 1) as int) when 1 then
		 case 
		 when cast(substring(cast(@number as varchar(100)), 3, 1) as int) = 0 then '0'
		 when cast(substring(cast(@number as varchar(100)), 3, 1) as int) > 0 then '+' end
		 else '0' end
    end
    if @trans != N'صفر' and @loop != 3 begin 
	  set @result = @result+ N' و '+@trans 
	end
    if @trans != N'صفر' and @loop = 3 begin 
	  if cast(substring(cast(@number as varchar(100)), @loop-1, 1) as int) = 1 and cast(substring(cast(@number as varchar(100)), @loop, 1) as int) between 1 and 9 begin
	    set @result = @result+ N' '+@trans
	    set @result = substring(@result, 1, len(@result))
	  end
	  if cast(substring(cast(@number as varchar(100)), @loop-1, 1) as int) = 1 and cast(substring(cast(@number as varchar(100)), @loop, 1) as int) = 0 begin
	    set @result = @result+ N' و '+@trans
	    set @result = substring(@result, 1, len(@result))
	  end
	  if cast(substring(cast(@number as varchar(100)), @loop-1, 1) as int) > 1 begin
	    set @result = @result+ N' و '+@trans
	    set @result = substring(@result, 2, len(@result))
	  end
    end
  end
end

if @len = 4 begin
  while @loop < @len begin
      set @loop = @loop +1
      if @loop = 1 begin
        select @trans = trans + case when cast(substring(cast(@number as varchar(100)), 1, 1) as int) in (1,2) then N'' else (
	       select N' '+trans 
             from Arb_numbers 
            where number = 1000
              and cat = '+') end
          from Arb_numbers
         where number = case when cast(substring(cast(@number as varchar(100)), 1, 1) as int) in (1,2) then cast(substring(cast(@number as varchar(100)), 1, 1) as int) * 1000 
						else cast(substring(cast(@number as varchar(100)), 1, 1) as int) end
           and cat = '0'
      end
      if @loop = 2 begin
        select @trans = trans
          from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)), 2, 1) as int) * 100
           and cat = 0
      end
      if @loop = 3 begin
        select @trans = trans
          from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)), 4, 1) as int)
           and cat = case when cast(substring(cast(@number as varchar(100)), 3, 1) as int) = 1 then 
                     case cast(substring(cast(@number as varchar(100)), 4, 1) as int) 
                     when 2 then 6 when 1 then 2 else 0 end else 0 end
      end
      if @loop = 4 begin
        select @trans = trans
          from Arb_numbers
         where number = cast(substring(cast(@number as varchar(100)), 3, 1) as int) * 10
         and cat = case cast(substring(cast(@number as varchar(100)), 3, 1) as int) when 1 then
		 case 
		 when cast(substring(cast(@number as varchar(100)), 4, 1) as int) = 0 then '0'
		 when cast(substring(cast(@number as varchar(100)), 4, 1) as int) > 0 then '+' end
		 else '0' end
      end
      if @trans != N'صفر' and @loop != 4 begin 
        set @result = @result+ N' و '+@trans 
      end
      if @trans != N'صفر' and @loop = 4 begin 
        if cast(substring(cast(reverse(@number) as varchar(100)), @loop-2, 1) as int) = 1 and cast(substring(cast(reverse(@number) as varchar(100)), @loop-3, 1) as int) = 0 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
        if cast(substring(cast(reverse(@number) as varchar(100)), @loop-2, 1) as int) = 1 and cast(substring(cast(reverse(@number) as varchar(100)), @loop-3, 1) as int) != 0 begin
          set @result = @result+ N' '+@trans
          set @result = substring(@result, 1, len(@result))
        end
        if cast(substring(cast(reverse(@number) as varchar(100)), @loop-2, 1) as int) > 1 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
      end
  end
end

if @len = 5 begin
  while @loop < @len 
  begin
    set @loop = @loop +1
      if @loop = 1 begin
	    select @trans = trans 
	      from Arb_numbers
	     where number = cast(substring(cast(@number as varchar(100)),2,1) as int) 
		   and cat = case when cast(substring(cast(@number as varchar(100)),1,1) as int) = 1 then 
                     case cast(substring(cast(@number as varchar(100)),2,1) as int) 
                     when 2 then 6 when 1 then 2 else 0 end else 0 end
	  end
      if @loop = 2 begin
	    select @trans = trans +N' '+ (
	      select trans 
	        from Arb_numbers 
	       where number = 1000 
	         and cat = case when substring(cast(@number as varchar(100)),1,1) = 1 then 
	                   case when substring(cast(@number as varchar(100)),2,1) = 0 then '+' else '0' end else '0' end)
	      from Arb_numbers
	     where number = substring(cast(@number as varchar(100)),1,1) * 10
	       and cat = case when substring(cast(@number as varchar(100)),1,1) = 1 then 
	                 case when substring(cast(@number as varchar(100)),2,1) = 0 then '0' else '+' end else '0' end
	  end
	  if @loop = 3 begin
	    select @trans = trans
	      from Arb_numbers
	      where number = cast(substring(cast(@number as varchar), 3, 1) as int)* 100
	        and cat = '0'
	  end
      if @loop = 4 begin
	    select @trans = trans
	      from Arb_numbers
	     where number = cast(substring(cast(@number as varchar), 5,1) as int)
		   and cat = case when cast(substring(cast(@number as varchar), 4,1) as int) = 1 then 
                     case cast(substring(cast(@number as varchar), 5,1) as int) 
                     when 2 then 6 when 1 then 2 else 0 end else 0 end
	  end
      if @loop = 5 begin
	    select @trans = trans
	      from Arb_numbers
	     where number = cast(substring(cast(@number as varchar), 4,1) as int) * 10
	       and cat = case when cast(substring(cast(@number as varchar), 4,1) as int) = 1 then 
	                 case when cast(substring(cast(@number as varchar), 5,1) as int) = 0 then '0' else '+' end else '0' end
	  end
      if @trans != N'صفر' and @loop not in (2,5) begin 
        set @result = @result+ N' و '+@trans 
	  end
      if @trans != N'صفر' begin 
	    if @loop = 2 begin
          if  cast(substring(reverse(substring(cast(@number as varchar(100)),1,2)),@loop,1) as int) = 1 
		  and cast(substring(reverse(substring(cast(@number as varchar(100)),1,2)),@loop-1,1) as int) = 0 begin
            set @result = @result+ N' و '+@trans
            set @result = substring(@result, 1, len(@result))
          end
          if  cast(substring(reverse(substring(cast(@number as varchar(100)),1,2)),@loop,1) as int) = 1 
		  and cast(substring(reverse(substring(cast(@number as varchar(100)),1,2)),@loop-1,1) as int) != 0 begin
            set @result = @result+ N' '+@trans
            set @result = substring(@result, 1, len(@result))
          end
          if  cast(substring(reverse(substring(cast(@number as varchar(100)),1,2)),@loop,1) as int) > 1 begin
            set @result = @result+ N' و '+@trans
            set @result = substring(@result, 1, len(@result))
          end
	    end

	    if @loop = 5 begin
          if  cast(substring(cast(reverse(@number) as varchar), @loop-3,1) as int) = 1 
		  and cast(substring(cast(reverse(@number) as varchar), @loop-4,1) as int) = 0 begin
            set @result = @result+ N' و '+@trans
            set @result = substring(@result, 1, len(@result))
          end
          if  cast(substring(cast(reverse(@number) as varchar), @loop-3,1) as int) = 1 
		  and cast(substring(cast(reverse(@number) as varchar), @loop-4,1) as int) != 0 begin
            set @result = @result+ N' '+@trans
            set @result = substring(@result, 1, len(@result))
          end
          if  cast(substring(cast(reverse(@number) as varchar), @loop-3,1) as int) > 1 begin
            set @result = @result+ N' و '+@trans
            set @result = substring(@result, 1, len(@result))
          end
		end
      end
   end
end

if @len = 6 begin
  while @loop < @len begin
    set @loop = @loop +1
    if @loop = 1 begin
     select @trans = trans 
	   from Arb_numbers
	  where number = cast(substring(cast(@number as varchar(100)),1,1) as int) * 100 
	    and cat = '0'
	end
    if @loop = 2 begin
	  select @trans = trans 
	    from Arb_numbers 
	   where number = cast(substring(cast(@number as varchar(100)),3,1) as int) *1
	     and cat = case cast(substring(cast(@number as varchar(100)),2,1) as int) when 1 then
	               case cast(substring(cast(@number as varchar(100)),3,1) as int) 
	               when 2 then 6 when 1 then 2 else 0 end else 0 end	  
	end
    if @loop = 3 begin 
	  select @trans=trans
	    from Arb_numbers
	   where number = cast(substring(cast(@number as varchar(100)),2,1) as int) *10
	     and cat = case when cast(substring(cast(@number as varchar(100)),3,1) as int) = 1 then 
	               case when cast(substring(cast(@number as varchar(100)),2,1) as int) = 0 then '0' else '+' end else '0' end
	end
    if @loop = 4 begin
	  select @trans = trans 
	    from Arb_numbers
	   where number = cast(substring(cast(@number as varchar(100)),4,1) as int) * 100 
	     and cat = '0'
	end
    if @loop = 5 begin 
	  select @trans = trans 
	    from Arb_numbers 
	   where number = cast(substring(cast(@number as varchar(100)),6,1) as int) *1
	     and cat = case cast(substring(cast(@number as varchar(100)),5,1) as int) when 1 then
	               case cast(substring(cast(@number as varchar(100)),6,1) as int) 
	               when 2 then 6 when 1 then 2 else 0 end else 0 end	  
	end
	if @loop = 6 begin 
	  select @trans=trans
	    from Arb_numbers
	   where number = cast(substring(cast(@number as varchar(100)),5,1) as int) *10
	     and cat = case when cast(substring(cast(@number as varchar(100)),5,1) as int) = 1 then 
	               case when cast(substring(cast(@number as varchar(100)),6,1) as int) = 0 then '0' else '+' end else '0' end
	end
    if @trans != N'صفر' and @loop not in (3,6) begin 
      set @result = @result+ N' و '+@trans 
	end
    if @trans != N'صفر' begin 
	  if @loop = 3 begin
        if  cast(substring(reverse(substring(cast(@number as varchar(100)),2,2)),@loop-1,1) as int) = 1 
	    and cast(substring(reverse(substring(cast(@number as varchar(100)),2,2)),@loop-2,1) as int) = 0 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
        if  cast(substring(reverse(substring(cast(@number as varchar(100)),2,2)),@loop-1,1) as int) = 1 
		and cast(substring(reverse(substring(cast(@number as varchar(100)),2,2)),@loop-2,1) as int) != 0 begin
          set @result = @result+ N' '+@trans
          set @result = substring(@result, 1, len(@result))
		end
        if cast(substring(reverse(substring(cast(@number as varchar(100)),2,2)),@loop-1,1) as int) > 1 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
	  end
	  if @loop = 6 begin
        if  cast(substring(reverse(substring(cast(@number as varchar(100)),5,2)),@loop-4,1) as int) = 1 
		and cast(substring(reverse(substring(cast(@number as varchar(100)),5,2)),@loop-5,1) as int) = 0 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
        if  cast(substring(reverse(substring(cast(@number as varchar(100)),5,2)),@loop-4,1) as int) = 1 
		and cast(substring(reverse(substring(cast(@number as varchar(100)),5,2)),@loop-5,1) as int) != 0 begin
          set @result = @result+ N' '+@trans
          set @result = substring(@result, 1, len(@result))
		end
        if cast(substring(reverse(substring(cast(@number as varchar(100)),5,2)),@loop-4,1) as int) > 1 begin
          set @result = @result+ N' و '+@trans
          set @result = substring(@result, 1, len(@result))
        end
	  end
	end
    if @loop = 3 begin
	  set @result = @result + (select N' '+trans from arb_numbers where number = 1000 and cat = case cast(substring(cast(@number as varchar(100)),2,1) as int) when 1 then '+' else '0' end)
	end
  end
end


if @len in (1,2) begin
 if substring(cast(@number as varchar(100)) ,2,1) = 0 and @number > 10 begin
  set @result = substring(rtrim(ltrim(@result)), 2, len(rtrim(ltrim(@result))))
 end
 else begin
  set @result = substring(rtrim(ltrim(@result)), 1, len(rtrim(ltrim(@result))))
 end
end
else begin
set @result = substring(rtrim(ltrim(@result)), 2, len(rtrim(ltrim(@result))))
end
set @result = N'فقط '+@result+' '+@currency_char+N' لا غير'
return @result
END
