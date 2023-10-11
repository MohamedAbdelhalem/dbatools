select * from sys.databases


CREATE Procedure compatibility_level_upgrade 2014
(@version int)
as
begin
declare @level int, @db_name varchar(400), @sql varchar(1500)
select @level = case @version 
when 2008 then 100
when 2012 then 110
when 2014 then 120
when 2016 then 130
when 2017 then 140
when 2019 then 150
end

declare i cursor fast_forward
for 
select name
from sys.databases 
where compatibility_level < @level

open i
fetch next from i into @db_name
while @@FETCH_STATUS = 0
begin

set @sql = 'ALTER DATABASE ['+@db_name+'] SET COMPATIBILITY_LEVEL = '+cast(@level as varchar)
print('DATABASE ['+@db_name+'] compatibility has been changed')
exec(@sql)

fetch next from i into @db_name
end
close i
deallocate i

end
