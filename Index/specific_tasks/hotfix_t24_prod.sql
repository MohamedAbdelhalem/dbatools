USE [T24Prod]
GO

use T24Prod
go

DROP INDEX [ix_FBNK_BAB_476_c3] ON [dbo].[FBNK_BAB_476] 
go
alter table [dbo].[FBNK_BAB_476] DROP COLUMN [LEGAL_ID]
go
ALTER FUNCTION [dbo].[udf_FBNK_BAB_476_c3](@xmlrecord XML) 
RETURNS nvarchar(20)
WITH SCHEMABINDING 
BEGIN
RETURN @xmlrecord.value('(/row/c3/text())[1]', 'nvarchar(20)');
END 
go
alter table [dbo].[FBNK_BAB_476] ADD [LEGAL_ID]  AS ([dbo].[udf_FBNK_BAB_476_c3]([XMLRECORD])) PERSISTED
go
CREATE NONCLUSTERED INDEX [ix_FBNK_BAB_476_c3] ON [dbo].[FBNK_BAB_476] ([LEGAL_ID] ASC)ON [DATAFG]


