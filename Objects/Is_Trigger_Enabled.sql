use master
go
Create  FUNCTION [dbo].[Is_Trigger_Enabled]
(@trigger_name varchar(50))
returns bit
as
begin
declare @status bit

select @status = case is_disabled when 0 then 1 when 1 then 0 end
from sys.triggers
where name = @trigger_name

return @status
end
