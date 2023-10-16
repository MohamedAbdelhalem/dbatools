#Run This Script as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] “Administrator”))
 
{
Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
Break
}
 
#Set Power Plan Options
Write-Host "Start Check Power Plan Best Practice" -ForegroundColor Yellow
if (Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan | Where-Object {$_.ElementName -EQ "High performance" -and $_.IsActive -eq "True"}) 
{
    Write-Host "Power Plan Options is Best Practice" -ForegroundColor Green
}
else 
{
    Write-Host "Setting up Power Plan Options to High Performance" -ForegroundColor Yellow
    Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan | Where-Object {$_.ElementName -like "High performance"} | Invoke-CimMethod -MethodName Activate | Out-Null
}
 
Start-Sleep 5

$User = Read-host -Prompt "Type your BAB user ID example e008666,C903068"


#FIX SMB1 PROTOCOL
$SMB1 = GET-WINDOWSFEATURE -NAME FS-SMB1
IF ($SMB1.INSTALLED) 
{
    WRITE-HOST "START REMOVING SMB1 WINDOWS FEATURE FOR SECURITY ,SERVER NEED TO RESTART " -FOREGROUNDCOLOR YELLOW
    REMOVE-WINDOWSFEATURE -NAME FS-SMB1 | OUT-NULL
}
 
#Install WMF5.1
Write-Host "Checking WMF 5.1" -ForegroundColor Yellow
if ((Get-CimInstance Win32_OperatingSystem).Version -like "10.*") 
{
    $Ver = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Host "Your Os Version is $Ver that mean WMF 5.1 Already Builtin...." -ForegroundColor Green
}
 
if ((Get-CimInstance Win32_OperatingSystem).Version -like "*6.2*") 
{
    if ((Get-HotFix | Where {$_.hotfixid -eq "KB3191565"}) -ne $null) 
    {
    Write-Host "WMF 5.1 Already Installed" -ForegroundColor Green
    }
    else 
    {
        Write-Host "Start Installing WMF 5.1" -ForegroundColor Yellow
        $WUSA = "$env:systemroot\SysWOW64\wusa.exe"
        $UpdatePath = "C:\Users\$User\Desktop\9_install\W2K12-KB3191565-x64.msu"
        $A = @($UpdatePath , '/quiet' , '/norestart')
        Start-Process -FilePath $WUSA -ArgumentList $A -NoNewWindow -Wait
    }
}
 
if ((Get-CimInstance Win32_OperatingSystem).Version -like "*6.3*") 
{
    if ((Get-HotFix | Where {$_.hotfixid -eq "KB3191564"}) -ne $null) 
    {
    Write-Host "WMF 5.1 Already Installed" -ForegroundColor Green
    }
    else 
    {
        Write-Host "Start Installing WMF 5.1" -ForegroundColor Yellow
        $WUSA = "$env:systemroot\SysWOW64\wusa.exe"
        $UpdatePath = "C:\Users\$User\Desktop\SQL019_install\Win8.1AndW2K12R2-KB3191564-x64.msu"
        $A = @($UpdatePath , '/quiet' , '/norestart')
        Start-Process -FilePath $WUSA -ArgumentList $A -NoNewWindow -Wait
    }
}
 
#Check Server if need Reboot 
Write-Host "Start Check if Server Need To Reboot" -ForegroundColor Yellow
 
if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) 
{
    Write-Host "Server need to restart first" -ForegroundColor Yellow 
    Break
}
 
if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) 
{
    Write-Host "Server need to restart first" -ForegroundColor Yellow 
    Break
}
 
if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) 
{
    Write-Host "Server need to restart first" -ForegroundColor Yellow 
    Break
}
 
Write-Host "Server Ok ... No Rebooting Needed" -ForegroundColor Green
 
Start-Sleep 5
 
#Check .Net Framework
Write-Host "Start Check and Install .Net Framework" -ForegroundColor Yellow
$DotNet = Get-WindowsFeature -Name NET-Framework-Core 
$DotNetSource= "C:\Users\$User\Desktop\SQL019_install\dotNet35Framework"
if ($DotNetSource) 
{
 
    IF ($DotNet.Installed)
 
{
    (Write-Host ".Net 3.5 Framework Already Installed" -ForegroundColor Green)
 
}
else
{
        (Write-Host "Installing .Net 3.5 Framework Started" -ForegroundColor Yellow)
        (Install-WindowsFeature NET-Framework-Core -Source $DotNetSource)
}
}
 
Start-Sleep 5
 
#Change CD-DVD to X:\ Drive
Write-Host "Starting Change CD-DVD to X Drive" -ForegroundColor Yellow
Get-WmiObject -Class Win32_Volume -Filter "DriveType=5" | Set-WmiInstance -Arguments @{DriveLetter="X:"} | Out-Null


#TEST Installation Paths With Renaming Disks

$disks = get-volume | Select-Object DriveLetter, FileSystemLabel
$v_data = $disks | Where-Object {$_.FileSystemLabel -eq "data"} | select -First 1
$v_logs = $disks | Where-Object {$_.FileSystemLabel -eq "logs"} | select -First 1
$v_sysdb = $disks | Where-Object {$_.FileSystemLabel -eq "sysdb"} | select -First 1
$v_tempdb = $disks | Where-Object {$_.FileSystemLabel -eq "tempdb"} | select -First 1
 
#GET Drivers information's
Write-Host "Drive information for $env:ComputerName" -ForegroundColor Yellow
Get-WmiObject -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5} |
    Sort-Object -Property Name | 
    Select-Object Name, VolumeName, FileSystem, Description, VolumeDirty, `
        @{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
        @{"Label"="FreeSpace(GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}}, `
        @{"Label"="%Free";"Expression"={"{0:N}" -f ($_.FreeSpace/$_.Size*100) -as [float]}} |
    Format-Table -AutoSize
 
#Build SQL Instance Name
Write-Host "Building Instance Name by completing below answers "
$DC = Read-host -Prompt "Type App Name DC1,DC2"
$UsageofServer = Read-host -Prompt "Choose One From Prod,Dev,UAT,SIT"
$UsageofAPP = Read-host -Prompt "Type App Name ICorp,T24"
$NamedInstance = "$DC$UsageofServer$UsageofAPP"
    
#Build SQL Paths
$Sysdb     = $v_sysdb.DriveLetter + ":\"
$Data      = $v_data.DriveLetter + ":\MSSQL15.$NamedInstance.Data"
$Logs      = $v_logs.DriveLetter + ":\MSSQL15.$NamedInstance.Log"
$Tempdb    = $v_tempdb.DriveLetter + ":\MSSQL15.$NamedInstance.TempDB"
$Tempdblog = $v_tempdb.DriveLetter + ":\MSSQL15.$NamedInstance.TempLog"
$Backup    = $v_logs.DriveLetter + ":\MSSQL15.$NamedInstance.Backup"
$SQLSysAdmin = "Albilad\DBA Admins"  #Change later to Albilad\DBA Admins
 
#Report Before installation
Write-Host "Your Instance Name will be $NamedInstance 
System Database files will be here $SYSDB
TempDB files will be here $TEMPDB , $TEMPDBLOG
SQL user files will be here $Data
SQL user files will be here $Log
" -ForegroundColor Yellow
 
Start-Sleep 5
 
#Build Configuration File
Write-Host "Start Build Configuration ini file for sql installation" -ForegroundColor Yellow
$ConfigurationFilePath = "C:\SQLInstallationConfig"
 
if (Test-Path "$ConfigurationFilePath")
{
    write-host "The folder '$ConfigurationFilePath' already exists, will not recreate it."
} 
else 
{
    New-item "$ConfigurationFilePath" -ItemType Directory | Out-Null
}
if (Test-Path "$ConfigurationFilePath\ConfigurationFile.ini")
{
    write-host "The file '$ConfigurationFilePath\ConfigurationFile.ini' already exists, removing..."
    Remove-Item -Path "$ConfigurationFilePath\ConfigurationFile.ini" -Force | Out-Null
} 
else 
{
    # Create file:
    write-host "Creating '$ConfigurationFilePath\ConfigurationFile.ini'..."
    New-Item -Path "$ConfigurationFilePath\ConfigurationFile.ini" -ItemType File | Out-Null
}
 
#Create INI File
$ini = @"
[OPTIONS]
ACTION="Install"
SUPPRESSPRIVACYSTATEMENTNOTICE="False"
IACCEPTROPENLICENSETERMS="False"
IAcceptSQLServerLicenseTerms="True"
ENU="True"
QUIET="True"
QUIETSIMPLE="False"
UpdateEnabled="False"
ERRORREPORTING="False"
USEMICROSOFTUPDATE="False"
FEATURES=SQLENGINE
UpdateSource="MU"
HELP="False"
INDICATEPROGRESS="True"
X86="False"
INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"
INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"
INSTANCENAME="$NamedInstance"
SQMREPORTING="False"
INSTANCEID="$NamedInstance"
INSTANCEDIR=D:\
AGTSVCACCOUNT="NT AUTHORITY\SYSTEM"
AGTSVCSTARTUPTYPE="Automatic"
COMMFABRICPORT="0"
COMMFABRICNETWORKLEVEL="0"
COMMFABRICENCRYPTION="0"
MATRIXCMBRICKCOMMPORT="0"
SQLSVCSTARTUPTYPE="Automatic"
FILESTREAMLEVEL="0"
ENABLERANU="False"
SQLCOLLATION="SQL_Latin1_General_CP1_CI_AS"
SQLSVCACCOUNT="NT AUTHORITY\SYSTEM"
SQLSVCINSTANTFILEINIT="True"
SQLSYSADMINACCOUNTS="$SQLSysAdmin"
SECURITYMODE="SQL"
SQLTEMPDBFILECOUNT="8"
SQLTEMPDBFILESIZE="8"
SQLTEMPDBFILEGROWTH="64"
SQLTEMPDBLOGFILESIZE="8"
SQLTEMPDBLOGFILEGROWTH="64"
SQLBACKUPDIR="$Backup"
SQLUSERDBDIR="$data"
SQLUSERDBLOGDIR="$logs"
SQLTEMPDBDIR="$tempdb"
SQLTEMPDBLOGDIR="$tempdblog"
ADDCURRENTUSERASSQLADMIN="False"
TCPENABLED="1"
NPENABLED="0"
BROWSERSVCSTARTUPTYPE="Automatic"
"@
 
$Config="$ConfigurationFilePath\ConfigurationFile.ini"
Add-Content -Path $Config -Value $ini | Out-Null
 
#Install SQL Server
$SQLsource = "C:\Users\$User\Desktop\SQL019_install\SW_DVD9_NTRL_SQL_Svr_Ent_Core_2019Dec2019_64Bit_English_OEM_VL_X22-22120"
if (Test-Path $SQLsource) 
{
    Write-Host "Starting install SQL Server ..." -ForegroundColor Yellow
    $Arg = "/ConfigurationFile=$Config"
    Start-Process -FilePath "C:\Users\$User\Desktop\SQL019_install\SW_DVD9_NTRL_SQL_Svr_Ent_Core_2019Dec2019_64Bit_English_OEM_VL_X22-22120\setup.exe" -ArgumentList @('/ACTION="Install"', '/SkipRules=HasSecurityBackupAndDebugPrivilegesCheck',$Arg ,'/SAPWD="Aa123456"') -NoNewWindow -Wait
}
else 
{
    Write-Host "Can't install SQL Check SQL Server Setup Log Files %programfiles%\Microsoft SQL Server\150\Setup Bootstrap\Log " -ForegroundColor Red
    Break
}
 
#Remove Installation Configuration Folder
Remove-Item -Path "C:\SQLInstallationConfig" -Recurse -Confirm:$false -Verbose

#Install SQL Server Powershell Module Offline
Copy-Item -Path "C:\Users\$User\Desktop\SQL019_Install\SqlServer" -Destination "C:\Program Files\WindowsPowerShell\Modules\SqlServer" -Recurse -Force -Verbose
Import-Module -Name SQLServer
Get-Command -Module SQLServer

#Install DBATools Powershell Module Offline
Copy-Item -Path "C:\Users\$User\Desktop\SQL019_Install\dbatools" -Destination "C:\Program Files\WindowsPowerShell\Modules\dbatools" -Recurse -Force -Verbose
Import-Module -Name dbatools
Get-Command -Module dbatools
 
$CoreServer = (Get-ItemProperty "hklm:/software/microsoft/windows nt/currentversion").InstallationType -eq "Server Core"
$GUIServer = (Get-ItemProperty "hklm:/software/microsoft/windows nt/currentversion").InstallationType -eq "Server"
 
if ($CoreServer) 
{
    Write-Host "You Can't Install SSMS on Server Core , You can Manage From Jump Server or Other WorkStation" -ForegroundColor Yellow
}
 
if ($GUIServer)
{
    Write-Host "Starting Install SSMS 18.6 and installation logs will be in %Temp%" -ForegroundColor Yellow
    $P = " /install /Passive /norestart"
    Start-Process -FilePath "C:\Users\$User\Desktop\SQL019_install\SSMS-Setup-ENU.exe" -ArgumentList $P -NoNewWindow -Wait
 
    #Start SSMS
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"
}
 
#Get SQL Port
Get-ChildItem -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.$NamedInstance\MSSQLServer\SuperSocketNetLib\Tcp" | Where-Object {$_.PSChildName -eq "IPAll"}
$port = "17120"
$PortSetting = Get-WmiObject -Namespace root/Microsoft/SqlServer/ComputerManagement13 -Class ServerNetworkProtocolProperty -Filter "InstanceName='$NamedInstance' and IPAddressName='IPAll' and PropertyType=1 and ProtocolName='Tcp'" 
$PortSetting.SetStringValue($port)

                
 
 
