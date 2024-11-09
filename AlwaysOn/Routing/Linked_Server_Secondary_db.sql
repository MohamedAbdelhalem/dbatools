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



