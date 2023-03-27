declare @backup_file_name nvarchar(1000), @location nvarchar(2000), @sql nvarchar(max)
declare bak cursor fast_forward
for
select backup_file_name, [location] 
from [dbo].[PDC_TO_SDC_Files]
order by id

open bak
fetch next from bak into @backup_file_name, @location
while @@FETCH_STATUS = 0
begin

set @sql = 'restore headeronly from disk = '+''''+@location+'\'+@backup_file_name+''''

insert into [dbo].[PDC_TO_SDC_HeaderOnly](
[BackupName], [BackupDescription], [BackupType], [ExpirationDate], [Compressed], 
[Position], [DeviceType], [UserName], [ServerName], [DatabaseName], [DatabaseVersion], 
[DatabaseCreationDate], [BackupSize], [FirstLSN], [LastLSN], [CheckpointLSN], 
[DatabaseBackupLSN], [BackupStartDate], [BackupFinishDate], [SortOrder], [CodePage], 
[UnicodeLocaleId], [UnicodeComparisonStyle], [CompatibilityLevel], [SoftwareVendorId], 
[SoftwareVersionMajor], [SoftwareVersionMinor], [SoftwareVersionBuild], [MachineName], 
[Flags], [BindingID], [RecoveryForkID], [Collation], [FamilyGUID], [HasBulkLoggedData], 
[IsSnapshot], [IsReadOnly], [IsSingleUser], [HasBackupChecksums], [IsDamaged], [BeginsLogChain], 
[HasIncompleteMetaData], [IsForceOffline], [IsCopyOnly], [FirstRecoveryForkID], [ForkPointLSN], 
[RecoveryModel], [DifferentialBaseLSN], [DifferentialBaseGUID], [BackupTypeDescription], 
[BackupSetGUID], [CompressedBackupSize], [containment], [KeyAlgorithm], [EncryptorThumbprint], [EncryptorType])
exec(@sql)

update [dbo].[PDC_TO_SDC_HeaderOnly] 
   set backup_file_name = @backup_file_name, backup_file_loc = @location 
 where backup_file_name is null 
   and backup_file_loc is null

fetch next from bak into @backup_file_name, @location
end
close bak
deallocate bak

