EXEC sp_addlinkedserver 
@server=N'secondary_db', 
@srvproduct=N'', 
@provider=N'MSOLEDBSQL', 
@provstr=N'ApplicationIntent=ReadOnly',
@datasrc=N'SqlListener', --listener name
@catalog='AdventureWorks2019';
	
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'collation compatible', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'data access', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'dist', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'pub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'rpc', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'rpc out', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'sub', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'connect timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'collation name', @optvalue=null
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'lazy schema validation', @optvalue=N'false'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'query timeout', @optvalue=N'0'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'use remote collation', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'secondary_db', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'secondary_db', @locallogin = NULL , @useself = N'False', @rmtuser = N'sa', @rmtpassword = N'P@$$w0rd'


select * from [secondary_db].AdventureWorks2019.Sales.SalesOrderHeader
select * from [secondary_db].master.sys.servers
SELECT * FROM OPENQUERY([secondary_db], 'SELECT DATABASEPROPERTYEX(''AdventureWorks2019'', ''Updateability'')');
SELECT * FROM OPENQUERY([primary_db], 'SELECT DATABASEPROPERTYEX(''AdventureWorks2019'', ''Updateability'')');
SELECT * FROM OPENQUERY([192.168.100.102], 'SELECT DATABASEPROPERTYEX(''AdventureWorks2019'', ''Updateability'')');

--After remove routing you will see this error
--Msg 979, Level 14, State 1, Line 40
--The target database ('AdventureWorks2019') is in an availability group and currently does not allow read only connections. For more information about application intent, see SQL Server Books Online.




