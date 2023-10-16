use master
go
exec dbo.XEvent_errors @@spid
go
exec [dbo].[kill_sessions_before_restore] 'database','T24Prod'
RESTORE DATABASE [T24Prod] FROM  DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP_2023\FULL\2023\March\D1T24DBSQPWV4_2023_T24Prod_FullBackup_20230310190000.bak' WITH  FILE = 1,
MOVE 'T24PROD_data' To 'J:\SQLSERVER\Data\T24PRODdata.mdf',
MOVE 'T24PROD1_data' To 'J:\SQLSERVER\Data\T24PRODdata1.ndf',
MOVE 'T24PROD2_data' To 'J:\SQLSERVER\Data\T24PRODdata2.ndf',
MOVE 'T24PROD3_data' To 'J:\SQLSERVER\Data\T24PRODdata3.ndf',
MOVE 'T24PROD4_data' To 'J:\SQLSERVER\Data\T24PRODdata4.ndf',
MOVE 'T24PROD5_data' To 'K:\SQLSERVER\Data\T24PRODdata5.ndf',
MOVE 'T24PROD6_data' To 'K:\SQLSERVER\Data\T24PRODdata6.ndf',
MOVE 'T24PROD7_data' To 'K:\SQLSERVER\Data\T24PRODdata7.ndf',
MOVE 'T24PROD8_data' To 'K:\SQLSERVER\Data\T24PRODdata8.ndf',
MOVE 'T24PROD10_data' To 'L:\SQLSERVER\Data\T24PRODdata10.ndf',
MOVE 'T24PROD11_data' To 'L:\SQLSERVER\Data\T24PRODdata11.ndf',
MOVE 'T24PROD12_data' To 'L:\SQLSERVER\Data\T24PRODdata12.ndf',
MOVE 'T24PROD9_data' To 'L:\SQLSERVER\Data\T24PRODdata9.ndf',
MOVE 'T24PROD13_data' To 'M:\SQLSERVER\Data\T24PRODdata13.ndf',
MOVE 'T24PROD14_data' To 'M:\SQLSERVER\Data\T24PRODdata14.ndf',
MOVE 'T24PROD15_data' To 'M:\SQLSERVER\Data\T24PRODdata15.ndf',
MOVE 'T24PROD16_data' To 'M:\SQLSERVER\Data\T24PRODdata16.ndf',
MOVE 'T24PROD_ARCH' To 'N:\SQLSERVER\Data\T24PRODdata18.ndf',
MOVE 'T24PROD_log' To 'T:\SQLSERVER\Data\T24PRODlog.ldf',
NOUNLOAD, NORECOVERY, REPLACE, STATS = 1
go
select * from master..[error_message](@@spid)
go
--exec dbo.XEvent_errors @@spid,0
