declare 
@db_name varchar(500), 
@sql varchar(max)
declare @table table (database_name varchar(500), name varchar(50), hasdbaccess int)
declare db_cursor cursor fast_forward
for
select name from sys.databases
where database_id > 4

open db_cursor
fetch next from db_cursor into @db_name
while @@FETCH_STATUS = 0
begin

set @sql = 'use ['+@db_name+']
SELECT '+''''+@db_name+''''+' db_name, su.name, su.hasdbaccess 
FROM sysusers su
WHERE su.name = ''guest'''
insert into @table
exec(@sql)

fetch next from db_cursor into @db_name
end
close db_cursor
deallocate db_cursor

select *, case hasdbaccess when 1 then 'use ['+database_name+'] REVOKE CONNECT FROM GUEST' end revoke_script
from @table
--GRANT CONNECT TO GUEST
--use [AdventureWorks2017] REVOKE CONNECT FROM GUEST
