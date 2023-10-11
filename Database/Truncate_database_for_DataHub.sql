use [beye]

declare @sql varchar(1000)
declare i cursor fast_forward
for
select 'Truncate Table ['+schema_name(schema_id)+'].['+name+'];' 
from sys.tables

open i
fetch next from i into @sql
while @@FETCH_STATUS = 0
begin
--exec (@sql)
print (@sql)
fetch next from i into @sql
end
close i
deallocate i


