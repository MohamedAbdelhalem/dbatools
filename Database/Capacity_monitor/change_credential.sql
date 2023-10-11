if object_id('dbo.triggers_status') is not null
begin
drop table dbo.triggers_status 
end
go
create table dbo.triggers_status (name varchar(500), is_disable bit)
insert into triggers_status 
select name, is_disabled from sys.server_triggers
go

declare @name varchar(500), @is_disable bit, @sql varchar(1000)
declare t cursor fast_forward
for
select name, is_disable
from dbo.triggers_status
where is_disable = 0

open t
fetch next from t into @name, @is_disable
while @@FETCH_STATUS = 0
begin
set @sql = 'DISABLE TRIGGER '+@name+' ON ALL SERVER'
exec(@sql)
fetch next from t into @name, @is_disable
end
close t
deallocate t
go

USE [master]
GO
if (select count(*) from sys.credentials where name = 'Credential_admin') > 0 
begin
ALTER CREDENTIAL [Credential_admin] WITH IDENTITY = N'ALBILAD\C904529', SECRET = N'them!!triX1644'
end
GO
use master
go

declare @name varchar(500), @is_disable bit, @sql varchar(1000)
declare t cursor fast_forward
for
select name, is_disable
from dbo.triggers_status
where is_disable = 0
open t
fetch next from t into @name, @is_disable
while @@FETCH_STATUS = 0
begin
set @sql = 'ENABLE TRIGGER '+@name+' ON ALL SERVER'
exec(@sql)
fetch next from t into @name, @is_disable
end
close t
deallocate t

--select * from disks 
