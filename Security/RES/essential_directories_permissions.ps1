$service = @(Get-Service -name "*SQL*" | where {$_.DisplayName -like "SQL Server (*"} | select name).name
$ver = (get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$service
$logPth = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\"+$ver+"\CPE"
$parPth = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\"+$ver+"\"+$service+"\Parameters"
$ACL = [System.Collections.ArrayList]@()

#These folders are essential directories to prevent the SQL Server instance from starting up.

$ErrorDumpDir = "-g"+(Get-ItemProperty -path $logPth).ErrorDumpDir
$MasterData = (Get-ItemProperty -path $parPth).SQLArg0
$MasterLog = (Get-ItemProperty -path $parPth).SQLArg2
$ErrorLog = (Get-ItemProperty -path $parPth).SQLArg1
$account = (Get-WmiObject Win32_Service -Filter "Name='$service'").StartName
$folders = [System.Collections.ArrayList]@()

$folders += $ErrorDumpDir
$folders += $MasterData
$folders += $Masterlog
$folders += $ErrorLog

write-host "The SQL Service " -ForegroundColor Green -NoNewline;
write-host $service -ForegroundColor Red -BackgroundColor Yellow -NoNewline; 
write-host " is running under service account " -ForegroundColor Green -NoNewline;
write-host $account -ForegroundColor Red -BackgroundColor Yellow
write-host "Please check below to see if the correct permissions are missing from these folders." -ForegroundColor Red
write-host " " 

for ($f = 0; $f -lt $folders.count; $f++)
{
    if ($folders[$f].substring(0, 2) -eq "-e") 
    {
        write-host "Error file" -ForegroundColor white -BackgroundColor red
    }
    if ($folders[$f].substring(0, 2) -eq "-l") 
    {
        write-host "Master DB Transaction log file" -ForegroundColor white -BackgroundColor red
    }
    if ($folders[$f].substring(0, 2) -eq "-d") 
    {
        write-host "Master DB Data file" -ForegroundColor white -BackgroundColor red
    }
    if ($folders[$f].substring(0, 2) -eq "-g") 
    {
        write-host "Error Log directory" -ForegroundColor white -BackgroundColor red
    }
    write-host $folders[$f].substring(2,$folders[$f].ToString().Length - 2) -ForegroundColor Green
    Get-ACL -Path $folders[$f].substring(2,$folders[$f].ToString().Length - 2) | ForEach-Object { $_.Access  } | where-object {$_.IdentityReference -eq $account}
}
