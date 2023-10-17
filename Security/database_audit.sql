USE [T24PROD_UAT]

GO

ALTER DATABASE AUDIT SPECIFICATION [T24ProdDb_schema_obj_change_grp]
FOR SERVER AUDIT [UserServerAudit]

GO

USE [T24PROD_UAT]

GO
ALTER DATABASE AUDIT SPECIFICATION [T24ProdDb_schema_obj_change_grp]
ADD (UPDATE ON SCHEMA::[dbo] BY [dbo]),
ADD (UPDATE ON SCHEMA::[dbo] BY [SITR19]),
ADD (UPDATE ON SCHEMA::[dbo] BY [etl_sit]),
ADD (UPDATE ON SCHEMA::[dbo] BY [ALBILAD\Mailgroup DBA]),
ADD (DELETE ON SCHEMA::[dbo] BY [dbo]),
ADD (DELETE ON SCHEMA::[dbo] BY [SITR19]),
ADD (DELETE ON SCHEMA::[dbo] BY [etl_sit]),
ADD (DELETE ON SCHEMA::[dbo] BY [ALBILAD\Mailgroup DBA])
GO


