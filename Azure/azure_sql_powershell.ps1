#connect first with your credentials 
#Connect-AzureRmAccount

#Run script (F5)
if (Test-Path variable:resourceGroupList) {rv resourceGroupList}
if (Test-Path variable:azureSql) {rv azureSql}

$resourceGroupList = Get-AzureRmResourceGroup
for ($rg = 0; $rg -lt $resourceGroupList.Count-1; $rg++)
{
    $server = Get-AzureRmSqlServer
    $azureSql += Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupList.ResourceGroupName[$rg] -ServerName $server.ServerName
    $azureSql | select ResourceGroupName, ServerName, DatabaseName, 
    Location, Edition,@{N='MaxSize';E={[string]($_.MaxSizeBytes/1GB) + " GB"}}, 
    Status, currentServiceObjectiveName, zoneRedundant, readScale | format-table
}

