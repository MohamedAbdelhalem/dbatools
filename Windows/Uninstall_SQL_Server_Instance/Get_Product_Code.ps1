if (Test-Path variable:name) {rv name}
if (Test-Path variable:productPath) {rv productPath}
if (Test-Path variable:productcode) {rv productcode}
if (Test-Path variable:table) {rv table}

$path = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\"
$productPath = @(Get-ChildItem -Path "Registry::$path" -recurse  | where {$_.property -like "ProductCode"} | select name)
$table = New-Object System.Collections.ArrayList;

for ($pc = 0; $pc -lt $productPath.Count; $pc++)
{
    $name= ($productPath | select name | select-object -index $pc).Name
    $productcode = (Get-ItemProperty -Path "Registry::$name" | select productcode).productcode
    $table += [pscustomobject]@{ID = $pc;path = $name; productcode = $productcode}
}

$table
