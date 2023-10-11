exec dbo.XEvent_errors @@spid

begin try
RESTORE DATABASE [T24PreProd333333] FROM  DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\FULL\2022\September\D1T24DBSQPWV4_2022_T24Prod_FullBackup_20220930190000.bak' WITH  FILE = 1,
MOVE 'T24PROD_data'		To 'J:\SQLSERVER\Data\T24PRODdata2.mdf',
MOVE 'T24PROD1_data'	To 'J:\SQLSERVER\Data\T24PRODdata12.ndf',
MOVE 'T24PROD2_data'	To 'J:\SQLSERVER\Data\T24PRODdata22.ndf',
MOVE 'T24PROD3_data'	To 'J:\SQLSERVER\Data\T24PRODdata32.ndf',
MOVE 'T24PROD4_data'	To 'J:\SQLSERVER\Data\T24PRODdata42.ndf',
MOVE 'T24PROD5_data'	To 'J:\SQLSERVER\Data\T24PRODdata52.ndf',
MOVE 'T24PROD6_data'	To 'J:\SQLSERVER\Data\T24PRODdata62.ndf',
MOVE 'T24PROD7_data'	To 'K:\SQLSERVER\Data\T24PRODdata72.ndf',
MOVE 'T24PROD8_data'	To 'J:\SQLSERVER\Data\T24PRODdata82.ndf',
MOVE 'T24PROD9_data'	To 'J:\SQLSERVER\Data\T24PRODdata92.ndf',
MOVE 'T24PROD10_data'	To 'J:\SQLSERVER\Data\T24PRODdata102.ndf',
MOVE 'T24PROD11_data'	To 'J:\SQLSERVER\Data\T24PRODdata112.ndf',
MOVE 'T24PROD12_data'	To 'J:\SQLSERVER\Data\T24PRODdata122.ndf',
MOVE 'T24PROD13_data'	To 'L:\SQLSERVER\Data\T24PRODdata132.ndf',
MOVE 'T24PROD14_data'	To 'J:\SQLSERVER\Data\T24PRODdata142.ndf',
MOVE 'T24PROD15_data'	To 'J:\SQLSERVER\Data\T24PRODdata152.ndf',
MOVE 'T24PROD16_data'	To 'J:\SQLSERVER\Data\T24PRODdata162.ndf',
MOVE 'T24PROD_ARCH'		To 'J:\SQLSERVER\Data\T24PRODdata182.ndf',
MOVE 'T24PROD_log'		To 'J:\SQLSERVER\Data\T24PRODlog2.ldf',
NOUNLOAD, RECOVERY, STATS = 1
end try

begin catch

select * from dbo.[error_message](@@spid)
exec [dbo].[XEvent_errors] @@spid, 0
goto abort;
end catch


abort:


