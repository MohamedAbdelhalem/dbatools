declare @table table (databasename varchar(1000), dbo_login varchar(255), sysdb_login varchar(255))
declare @dbname varchar(1000), @sql varchar(max)
declare db_cursor cursor fast_forward
for
select name from sys.databases
open db_cursor
fetch next from db_cursor into @dbname
while @@FETCH_STATUS = 0
begin
set @sql = 'SELECT '+''''+@dbname+''''+' dbname, sp.name dbo_login, o.name sysdb_login
FROM ['+@dbname+'].sys.database_principals dp
LEFT JOIN master.sys.server_principals sp
ON dp.sid = sp.sid
LEFT JOIN master.sys.databases d
ON DB_ID('+''''+@dbname+''''+') = d.database_id
LEFT JOIN master.sys.server_principals o
ON d.owner_sid = o.sid
WHERE dp.name = ''dbo'';'
insert into @table
exec(@sql)
fetch next from db_cursor into @dbname
end
close db_cursor 
deallocate db_cursor 
select * from @table
