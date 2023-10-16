SELECT
[Current LSN], Operation, Context, [Transaction ID], AllocUnitId,
[RowLog Contents 0],
RECID
--master.dbo.Hex_to_Text(substring([RowLog Contents 0],26 + 1, charindex('DFFF',[RowLog Contents 0])-4 - 26 + 1)) Deleted_RECID
FROM master.dbo.TLOG_tracking_delete_stmt with (nolock)

set statistics profile off
alter table master.dbo.TLOG_tracking_delete_stmt add RECID as (dbo.Hex_to_Text_255(substring([RowLog Contents 0],26 + 1, charindex('DFFF',[RowLog Contents 0])-4 - 26 + 1)))
alter table master.dbo.TLOG_tracking_delete_stmt add constraint pk2_id_tlt primary key (ID)
create index idx_recid_h_tlt on master.dbo.TLOG_tracking_delete_stmt (RECID)

select * 
from master.dbo.TLOG_tracking_delete_stmt 
where RECID like 'AML.TRN.REC%'

SELECT 
[Current LSN], Operation, Context, [Transaction ID], AllocUnitId, [Transaction SID], [Begin Time], [Transaction Name]
from
sys.fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'\\npci2.d2fs.albilad.com\T24_BACKUP_2023\LOGs\2023\April\D1T24DBSQPWV4_2023_T24Prod_LogBackup_20230420014000.Trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
where [Transaction ID] in (
select [Transaction ID]
from master.dbo.TLOG_tracking_delete_stmt 
where id in (
select id
from master.dbo.TLOG_tracking_delete_stmt 
where RECID like 'AML.TRN.REC%'))
and Operation = 'LOP_BEGIN_XACT'
