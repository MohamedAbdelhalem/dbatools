$service = @(Get-Service -name "*SQL*" | where {$_.DisplayName -like "SQL Server (*"} | select name).name

#If you are encountering issues starting up the SQL server service and need to confirm that the permissions 
#are correctly set, uncomment the line below to open the service in a minimal configuration with a single-user mode. 
#This will allow you to gather the physical locations of the system databases and verify that the issue is not 
#originating from there.


#net start $service /f /T3608

$ver = sqlcmd -S . -E -Q "declare @v varchar(30) select @v = cast(value_data as varchar(30)) from sys.dm_server_registry where value_name = 'CurrentVersion'; select @v"
$logPth = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL"+$ver[2].ToString().Substring(0,$ver[2].IndexOf("."))+"."+$service+"\CPE"
$parPth = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL"+$ver[2].ToString().Substring(0,$ver[2].IndexOf("."))+"."+$service+"\"+$service+"\Parameters"

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

for ($f = 0; $f -lt $folders.count; $f++)
{
    write-host $folders[$f].substring(0, 2) -ForegroundColor Green
    write-host $folders[$f].substring(2,$folders[$f].ToString().Length - 2) -ForegroundColor Green
    Get-ACL -Path $folders[$f].substring(2,$folders[$f].ToString().Length - 2) | Format-Table -Wrap
}

#net stop $service
#net start $service
