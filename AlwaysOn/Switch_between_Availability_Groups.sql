declare 
@ag_old			varchar(500) = 'AG_Dev',
@ag_new			varchar(500) = 'AG_Prod',
@instance_P		varchar(50) = '10.10.10.1',
@instance_S		varchar(50) = '10.10.10.2',
@db_name		varchar(max) = 'db1,db2,db3,db14'

declare 
@sql varchar(max),
@database_name varchar(500)

declare db_cursor cursor fast_forward
for
select value
from master.dbo.Separator(@db_name,',')
order by value

open db_cursor
fetch next from db_cursor into @database_name
while @@FETCH_STATUS = 0
begin

--primary
set @sql = ':CONNECT '+@instance_P
print(@sql)
print('GO')
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_old+'] REMOVE DATABASE ['+@database_name+'];'
print(@sql)
print('GO')

--primary
set @sql = 'ALTER AVAILABILITY GROUP ['+@ag_new+'] ADD DATABASE ['+@database_name+'];'
print(@sql)
print('GO')

--secondary
set @sql = ':CONNECT '+@instance_S
print(@sql)
print('GO')
print('WAITFOR DELAY ''00:00:10''')
print('GO')
set @sql = 'ALTER DATABASE ['+@database_name+'] SET HADR AVAILABILITY GROUP = ['+@ag_new+'];'
print(@sql)
print('GO')

fetch next from db_cursor into @database_name
end
close db_cursor 
deallocate db_cursor 

--Open new query with CMD MODE
--then past the print statements above and then Execute


