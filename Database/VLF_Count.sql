CREATE Function dbo.VLF_Count (
@intial_size_gb float = 1,
@growth_size_mb float = 512,
@target_size_gb float = 200) 
returns int
as
begin
declare @vlf int

if cast(master.dbo.vertical_array(@@VERSION,' ',4) as int) < 2014
begin

select @vlf =
case 
when @growth_size_mb between 1    and 64   then (((@target_size_gb - @intial_size_gb) * 1024.0) / @growth_size_mb) * 4
when @growth_size_mb between 65   and 1024 then (((@target_size_gb - @intial_size_gb) * 1024.0) / @growth_size_mb) * 8
when @growth_size_mb >= 1025			   then (((@target_size_gb - @intial_size_gb) * 1024.0) / @growth_size_mb) * 16
end 
+
case 
when @intial_size_gb * 1024.0 between 1    and 64   then 4
when @intial_size_gb * 1024.0 between 65   and 1024 then 8
when @intial_size_gb * 1024.0 >= 1025		 	    then 16
end

end
else 
if cast(master.dbo.vertical_array(@@VERSION,' ',4) as int) >= 2014
begin

select @vlf = case 
when @intial_size_gb * 1024.0 between 1    and 64   then 4
when @intial_size_gb * 1024.0 between 65   and 1024 then 8
when @intial_size_gb * 1024.0 >= 1025		 	    then 16
end 

while @intial_size_gb < @target_size_gb
begin

set @vlf = @vlf + IIF((@growth_size_mb / 1024.0) < @intial_size_gb/8.0, 1, case when @growth_size_mb between 1 and 64 then 4 when @growth_size_mb between 65 and 1024 then 8 when @growth_size_mb > 1024 then 16 end)
set @intial_size_gb = @intial_size_gb + (@growth_size_mb / 1024.0)

end
end

return @vlf 
end

