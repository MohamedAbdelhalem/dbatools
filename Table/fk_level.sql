Create function fk_level (@object_id bigint)
returns int
as
begin
declare @loop int = 0, @object bigint, @currnet_object bigint, @level int
select @object = referenced_object_id from sys.foreign_keys where parent_object_id = @object_id

while @loop < 100
begin
select @object = parent_object_id
from sys.foreign_keys
where referenced_object_id = @object

if isnull(@object,0) = isnull(@currnet_object,0)
begin
break
end
else
begin
set @currnet_object = @object
set @loop = @loop + 1
end
end

select @level = case when @loop - 1 < 0 then 0 else @loop - 1 end
return @level
end
