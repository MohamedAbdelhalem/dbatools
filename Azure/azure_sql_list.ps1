$azsql = New-Object System.Collections.ArrayList;
$azserver = az sql server list
$server = $azserver | ConvertFrom-Json
$sqlList = az sql db list --resource-group $server.resourceGroup --server $server.name
$azuresql = $sqlList | ConvertFrom-Json

for($i = 0; $i -lt $azuresql.name.count + 1; $i++)
{
$azsql += [pscustomobject]@{
database_name = $azuresql.name[$i];
status = $azuresql.status[$i];
creationDate = $azuresql.creationDate[$i];
minCapacity = $azuresql.minCapacity[$i];
maxSizeBytes = $azuresql.maxSizeBytes[$i];
maxLogSizeBytes = $azuresql.maxLogSizeBytes[$i];
autoPauseDelay = $azuresql.autoPauseDelay[$i];
collation = $azuresql.collation[$i];
currentBackupStorageRedundancy = $azuresql.currentBackupStorageRedundancy[$i];
currentServiceObjectiveName = $azuresql.currentServiceObjectiveName[$i];
zoneRedundant = $azuresql.zoneRedundant[$i];
type = $azuresql.type[$i];
manualCutover = $azuresql.manualCutover[$i];
requestedBackupStorageRedundancy = $azuresql.requestedBackupStorageRedundancy[$i];
requestedServiceObjectiveName = $azuresql.requestedServiceObjectiveName[$i];
readScale = $azuresql.readScale[$i];
managedBy = $azuresql.managedBy[$i]}
}

$azsql | format-table 
