$resourceGroupList = Get-AzureRmResourceGroup
$server = Get-AzureRmSqlServer
$azureSql = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupList.ResourceGroupName -ServerName $server.ServerName
$azureSql | select DatabaseName, Location, Edition,@{N='MaxSizeGB';E={[string]($_.MaxSizeBytes/1GB) + " GB"}}, Status,
currentServiceObjectiveName,zoneRedundant,readScale,managedBy  | format-table
