alter function [dbo].[time_to_complete](@current float, @target float, @start_time datetime)
returns varchar(50)
as
begin
declare @percent_complete float, @time_to_complete varchar(50)
select @percent_complete = (@current / (@target + 0.00001)) * 100.00000
select @time_to_complete = 
dbo.duration('ms',
case when @percent_complete = 0 then 0 else case when 
cast((100.00000 / (round(@percent_complete,10) + .00001)) 
* 
datediff(ms, @start_time, getdate()) as float)
-
datediff(ms, @start_time, getdate())
< 0 then 0 else
cast((100.00000 / (round(@percent_complete,10) + .00001)) 
* 
datediff(ms, @start_time, getdate()) as float)
-
datediff(ms, @start_time, getdate())
end end
) 

return @time_to_complete
end