$service = @(Get-Service -name "*SQL*" | where {$_.DisplayName -like "SQL Server (*"} | select name).name

#If you are encountering issues starting up the SQL server service and need to confirm that the permissions 
#are correctly set, uncomment the line below to open the service in a minimal configuration with a single-user mode. 
#This will allow you to gather the physical locations of the system databases and verify that the issue is not 
#originating from there.


#net start $service /f /T3608

$files = sqlcmd -S . -E -Q "select db_name(database_id)+'_'+case type_desc when 'ROWS' then 'data' else 'log' end+'!'+physical_name from sys.master_files where database_id in (1,2,3,4) order by database_id, file_id"

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
#$distinctFolders = @($folders | select -Unique)

write-host "The SQL Service " -ForegroundColor Green -NoNewline;
write-host $service -ForegroundColor Red -BackgroundColor Yellow -NoNewline; 
write-host " is running under service account " -ForegroundColor Green -NoNewline;
write-host $account -ForegroundColor Red -BackgroundColor Yellow
write-host "Please check below to see if the correct permissions are missing from these folders." -ForegroundColor Red

for ($f = 0; $f -lt $folders.count; $f++)
{
    write-host $folders[$f].substring(0, $folders[$f].IndexOf("!")) -ForegroundColor Green
    write-host $folders[$f].substring($folders[$f].IndexOf("!")+1,$folders[$f].ToString().Length - $folders[$f].IndexOf("!")-1) -ForegroundColor Green
    Get-ACL -Path $folders[$f].substring($folders[$f].IndexOf("!")+1,$folders[$f].ToString().Length - $folders[$f].IndexOf("!")-1) | Format-Table -Wrap
}

#net stop $service
#net start $service
