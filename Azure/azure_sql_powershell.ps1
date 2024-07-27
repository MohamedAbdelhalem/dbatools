#connect first with your credentials 
#Connect-AzureRmAccount

#Run script (F5)
$resourceGroupList = Get-AzureRmResourceGroup
$server = Get-AzureRmSqlServer
$azureSql = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupList.ResourceGroupName -ServerName $server.ServerName
$azureSql | select DatabaseName, Location, Edition,@{N='MaxSize';E={[string]($_.MaxSizeBytes/1GB) + " GB"}}, Status,
currentServiceObjectiveName,zoneRedundant,readScale,managedBy  | format-table
