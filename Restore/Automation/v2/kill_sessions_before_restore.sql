USE [master]
GO
CREATE Procedure [dbo].[kill_sessions_before_restore]
(@type varchar(100), @name varchar(400))
as
begin
declare @kill varchar(50)
declare @table table (kill_statement varchar(30))

if @type = 'database'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where dbid = db_id(@name)
end
else
if @type = 'login'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where loginame = @name
end

declare k cursor fast_forward
for
select kill_statement from @table
open k
fetch next from k into @kill
while @@FETCH_STATUS = 0
begin
print(@kill)
exec(@kill)
fetch next from k into @kill
end
close k
deallocate k
end
