$table = New-Object System.Collections.ArrayList;
$asql = az sql server list
$sql = $asql | ConvertFrom-Json
$table += [pscustomobject]@{
sysadmin = $sql.administratorLogin;
serverFQDN = $sql.fullyQualifiedDomainName; 
location = $sql.location; 
databaseName = $sql.name;
publicAccess = $sql.publicNetworkAccess;
resourceGroup = $sql.resourceGroup;
state = $sql.state}
$table | Format-Table
