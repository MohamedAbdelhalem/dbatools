$azsql = New-Object System.Collections.ArrayList;
$azserver = az sql server list
$server = $azserver | ConvertFrom-Json
$sqlList = az sql db list --resource-group $server.resourceGroup --server $server.name
$azuresql = $sqlList | ConvertFrom-Json

for($i = 0; $i -lt $azuresql.name.count + 1; $i++)
{
$azsql += [pscustomobject]@{
dbName = $azuresql.name[$i];
status = $azuresql.status[$i];
creation = $azuresql.creationDate[$i];
maxSize = $azuresql.maxSizeBytes[$i]/ 1GB;
maxLogSize = $azuresql.maxLogSizeBytes[$i]/ 1GB;
pauseSec = $azuresql.autoPauseDelay[$i];
#collation = $azuresql.collation[$i];
CBStorageR = $azuresql.currentBackupStorageRedundancy[$i];
CSON = $azuresql.currentServiceObjectiveName[$i];
zoneRedundant = $azuresql.zoneRedundant[$i];
RBakStrogRed = $azuresql.requestedBackupStorageRedundancy[$i];
RSON = $azuresql.requestedServiceObjectiveName[$i];
readScale = $azuresql.readScale[$i];
managedBy = $azuresql.managedBy[$i]}
}

$azsql | format-table 
