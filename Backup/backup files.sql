

D1T24DBSQPWV1_t24prod_FullBackup_20170331213000.bak
2017-03-31 21:30:00
D1T24DBSQPWV1_t24prod_DiffBackup_20170402213001.bak
2017-04-02 21:30:01

select DatabaseName, BackupType, BackupTypeDescription, master.dbo.numbersize(BackupSize,'byte') BackupSize, Compressed, master.dbo.numbersize(CompressedBackupSize,'byte') CompressedBackupSize, FirstLSN, LastLSN, CheckpointLSN, DatabaseBackupLSN, BackupStartDate, BackupFinishDate, BackupName,  CompatibilityLevel, Collation, RecoveryModel, Position, DeviceType, UserName, ServerName, DifferentialBaseLSN, IsSnapshot, IsReadOnly, IsSingleUser, HasBackupChecksums, IsDamaged, BeginsLogChain, HasIncompleteMetaData, IsForceOffline, IsCopyOnly, backup_file_name, backup_file_loc
from [dbo].[backup_files_headeronly]
where BackupStartDate between '2017-04-02 21:29:01' and '2017-04-03 23:59:59'
and DatabaseName = 'T24PROD'
order by BackupStartDate


select --256 & 
@@OPTIONS
select power(cast(@@options as float),256)

select power(256,2)
select 6008 / 256
