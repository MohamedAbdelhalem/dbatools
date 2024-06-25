$files = sqlcmd -S . -E -Q "select physical_name from sys.master_files where database_id in (1,2,3,4)"
$service = @(Get-Service -name "*SQL*" | where {$_.DisplayName -like "SQL Server (*"} | select name).name
$account = (Get-WmiObject Win32_Service -Filter "Name='$service'").StartName
$loop = 2
$folders = [System.Collections.ArrayList]@()
$distinctFolders = [System.Collections.ArrayList]@()
$pos = 0
$indexof = 0
for ($i = 0; $i -lt $files.count - 4; $i++)
{
    while ($pos -gt -1) 
    {
        $pos =+ $files[$loop].indexof("\",$pos+1)
        if ($pos -gt -1)
        {
            $indexof = $pos
        }
    }
    $folders += $files[$loop].substring(0,$indexof +1)
    $pos = 0
    $indexof = 0
$loop += 1
}
$distinctFolders = @($folders | select -Unique)

write-host "The SQL Service " -ForegroundColor Green -NoNewline;
write-host $service -ForegroundColor Red -BackgroundColor Yellow -NoNewline; 
write-host " is running under service account " -ForegroundColor Green -NoNewline;
write-host $account -ForegroundColor Red -BackgroundColor Yellow
write-host "Please check below to see if the correct permissions are missing from these folders." -ForegroundColor Red

for ($f = 0; $f -lt $distinctFolders.count; $f++)
{
    write-host $distinctFolders[$f] -ForegroundColor Green
    Get-ACL -Path $distinctFolders[$f] | Format-Table -Wrap 
}
