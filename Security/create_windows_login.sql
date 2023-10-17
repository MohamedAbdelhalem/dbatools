declare @windowa_loginame varchar(200) = '[ALBILAD\e010204]'
select value from (
select top 100 percent b.value
from (select 'USE [master]
GO
CREATE LOGIN '+@windowa_loginame+' FROM WINDOWS WITH DEFAULT_DATABASE = [master]
GO' syntax)a
cross apply master.dbo.Separator(syntax, char(10)) b
order by id)a
union all
select value from (
select top 100 percent b.value
from (
select database_id, 'USE ['+name+']
go
CREATE USER '+@windowa_loginame+' FOR LOGIN '+@windowa_loginame+'
go
USE ['+name+']
go
ALTER ROLE [db_datareader] ADD MEMBER '+@windowa_loginame+'
go' syntax
from sys.databases
where database_id > 4)a
cross apply master.dbo.Separator(syntax, char(10)) b
order by database_id, id)c
