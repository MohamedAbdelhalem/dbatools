$FormatEnumerationLimit = -1

if (Test-Path variable:name) {rv name}
if (Test-Path variable:productPath) {rv productPath}
if (Test-Path variable:productcode) {rv productcode}
if (Test-Path variable:table) {rv table}
if (Test-Path variable:sqlserivces) {rv sqlserivces}

$path = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\"
$productPath = @(Get-ChildItem -Path "Registry::$path" -recurse  | where {$_.property -like "ProductCode"} | select name)
$table = New-Object System.Collections.ArrayList;
$instances = New-Object System.Collections.ArrayList;
$sqlserivces = get-service -name "*sql*" | where {$_.DisplayName -like "*SQL Server (*"} | select name
$ins = $sqlserivces | foreach-object {if($_.name -like  "*$*"){$_.name.Substring(6,$_.name.Length-6)}else{$_.name}}
$ins  | foreach-object {$instances += [pscustomobject]@{Name = $_}}

for ($pc = 0; $pc -lt $productPath.Count; $pc++)
{
    $name= ($productPath | select name | select-object -index $pc).Name
    $serviceName = $instances | foreach-object {if ($name.Contains("."+$_.name+"\")){$_.name}}
    $productcode = (Get-ItemProperty -Path "Registry::$name" | select productcode).productcode
    $table += [pscustomobject]@{ID = $pc;path = $name; productcode = $productcode; Instance = $serviceName}
}

$table | Format-Table -AutoSize
