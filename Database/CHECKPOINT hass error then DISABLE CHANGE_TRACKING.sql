USE [Data_Hub_T24_2014]   CHECKPOINT   DBCC SHRINKFILE (N'Data_Hub_T24_2014_log' , 39)
--error
--then 

USE [Data_Hub_T24_2014]
go
select 'ALTER TABLE ['+schema_name(schema_id)+'].['+name+'] DISABLE CHANGE_TRACKING'  
from sys.tables
where object_id in (select object_id from sys.change_tracking_tables)

--copy and paste here

ALTER TABLE [dbo].[FBNK_RE_CRF_BABGL] DISABLE CHANGE_TRACKING
ALTER TABLE [dbo].[FOMS_RE_CRF_BABGL] DISABLE CHANGE_TRACKING
ALTER TABLE [dbo].[FMFI_RE_CRF_BABGL] DISABLE CHANGE_TRACKING
ALTER TABLE [dbo].[SWITCH_MERGE_LOG] DISABLE CHANGE_TRACKING
ALTER TABLE [dbo].[DAILY_CHANGE_TRACKING] DISABLE CHANGE_TRACKING
go

use [master]
go
ALTER DATABASE [Data_Hub_T24_2014] SET CHANGE_TRACKING = OFF 
GO
