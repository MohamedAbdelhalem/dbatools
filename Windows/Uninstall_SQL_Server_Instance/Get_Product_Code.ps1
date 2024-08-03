if (Test-Path variable:name) {rv name}
if (Test-Path variable:productPath) {rv productPath}
if (Test-Path variable:productcode) {rv productcode}
if (Test-Path variable:table) {rv table}

$path = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\"
$productPath = @(Get-ChildItem -Path "Registry::$path" -recurse  | where {$_.property -like "ProductCode"} | select name)
$table = New-Object System.Collections.ArrayList;
$sqlserivces = get-service -name "*sql*" | where {$_.DisplayName -like "*SQL Server (*"} | select name
$sqlserivces | foreach-object {$_.name}

for ($pc = 0; $pc -lt $productPath.Count; $pc++)
{
    
    $name= ($productPath | select name | select-object -index $pc).Name
    $sqlserivces | foreach-object {$name2 = $name | select-string $_.name; $name3 = $_.name}
    $productcode = (Get-ItemProperty -Path "Registry::$name" | select productcode).productcode
    if ($name -eq $name2)
    {
        $table += [pscustomobject]@{ID = $pc;path = $name; productcode = $productcode; Instance = $name3}
    }
    else
    {
        $table += [pscustomobject]@{ID = $pc;path = $name; productcode = $productcode; Instance = "Shared"}
    }
}

$table | Format-Table

