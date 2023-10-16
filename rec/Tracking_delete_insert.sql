create table master.dbo.TLOG_tracking_delete_stmt2 (id int identity(1,1), [Current LSN] varchar(100), Operation varchar(100), Context varchar(100), [Transaction ID] varchar(100), AllocUnitId varchar(100),[RowLog Contents 0] varchar(max))
go
declare @table_name_wSchema varchar(500) = '[dbo].[F_BAB_L_GEN_TABLE]' 
declare @LOP varchar(100) = 'delete' -- delete or insert

insert into master.dbo.TLOG_tracking_delete_stmt2 
SELECT
[Current LSN], Operation, Context, [Transaction ID], AllocUnitId,
convert(varchar(max),[RowLog Contents 0],2)
--master.dbo.Hex_to_Text(substring(convert(varchar(max),[RowLog Contents 0],2),26 + 1, charindex('DFFF',convert(varchar(max),[RowLog Contents 0],2))-4 - 26 + 1)) Deleted_RECID,
FROM
fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'\\npci2.d2fs.albilad.com\T24_BACKUP_2023\LOGs\2023\April\D1T24DBSQPWV4_2023_T24Prod_LogBackup_20230420014000.Trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
where AllocUnitId in (
select a.allocation_unit_id 
from sys.allocation_units a inner join sys.partitions p
on (a.type in (1,3) and p.hobt_id = a.container_id)
or (a.type = 2 and p.partition_id = a.container_id)
inner join sys.tables t
on t.object_id = p.object_id 
where t.object_id = object_id(@table_name_wSchema))
and Operation = case @LOP when 'delete' then 'LOP_DELETE_ROWS' when 'insert' then 'LOP_INSERT_ROWS' end
and Context = 'LCX_MARK_AS_GHOST' 
