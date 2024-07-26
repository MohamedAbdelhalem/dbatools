$azsql = New-Object System.Collections.ArrayList;
$azserver = az sql server list
$server = $azserver | ConvertFrom-Json
$sqlList = az sql db list --resource-group $server.resourceGroup --server $server.name
$azuresql = $sqlList | ConvertFrom-Json

$azsql += [pscustomobject]@{
database_name = $azuresql.name;
status = $azuresql.status;
creationDate = $azuresql.creationDate;
minCapacity = $azuresql.minCapacity;
maxSizeBytes = $azuresql.maxSizeBytes;
maxLogSizeBytes = $azuresql.maxLogSizeBytes;
autoPauseDelay = $azuresql.autoPauseDelay;
collation = $azuresql.collation;
createMode = $azuresql.createMode;
currentBackupStorageRedundancy = $azuresql.currentBackupStorageRedundancy;
currentServiceObjectiveName = $azuresql.currentServiceObjectiveName;
zoneRedundant = $azuresql.zoneRedundant;
type = $azuresql.type;
manualCutover = $azuresql.manualCutover;
requestedBackupStorageRedundancy = $azuresql.requestedBackupStorageRedundancy;
requestedServiceObjectiveName = $azuresql.requestedServiceObjectiveName;
readScale = $azuresql.readScale;
managedBy = $azuresql.managedBy;
}

$azsql | format-table 
