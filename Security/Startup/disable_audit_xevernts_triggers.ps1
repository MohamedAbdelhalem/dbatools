#attention#
#######################################################
#If you have an issue with your instance that prevents you from querying anything from the database e.g. sys.sysprcesses or in your user databases
#and you suspicions about the audit is the root cause, so, choose first the instance ID (if you have multip-instances, if not it's always number 1)
#then "N" for not stop and start the instance 
#if the script couldn't able to query out the audit list
#then "Y" to stop the instance and start it with trace falg 3608
#######################################################

if (Test-Path variable:service) {rv service}
if (Test-Path variable:serviceName) {rv serviceName}
if (Test-Path variable:confirm) {rv confirm}
if (Test-Path variable:loop) {rv loop}
if (Test-Path variable:stop_start) {rv stop_start}
if (Test-Path variable:instance) {rv instance}
if (Test-Path variable:chosenServiceName) {rv chosenServiceName}
if (Test-Path variable:chosenInstanceName) {rv chosenInstanceName}
if (Test-Path variable:ID) {rv ID}
if (Test-Path variable:table) {rv table}
if (Test-Path variable:audit) {rv audit}
if (Test-Path variable:trigger) {rv trigger}
if (Test-Path variable:ObjectTable) {rv ObjectTable}

$service = [System.Collections.ArrayList]@() 
$serviceName = [System.Collections.ArrayList]@()
$table = New-Object System.Collections.ArrayList;
$ObjectTable = New-Object System.Collections.ArrayList;
$service += (get-service -name "*sql*" | where {$_.DisplayName -like "SQL Server (*"} | where-object {$_.Status -eq "Running"} | select Name| sort DisplayName).name
$audit = [System.Collections.ArrayList]@()
$trigger = [System.Collections.ArrayList]@()

if ($service.gettype().name -eq "string")
{
    $serviceName.add($service) | out-null
}
else
{
    for ($s = 0; $s -lt $service.count; $s++)
    {
        if ($service -like "*$*")
        {
            $serviceName += $service[$s].tostring().substring($service[$s].tostring().indexof("$")+1,$service[$s].length - $service[$s].tostring().indexof("$")-1)
        }
        else
        {
            $serviceName += $service[$s].tostring()
        }
    }
}

for ($in = 0; $in -lt $serviceName.count; $in++)
{
    $v_instance = $serviceName[$in].tostring()
    $v = (get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$v_instance
    if ($v.substring(0,$v.indexof(".")) -eq "MSSQL16")
    {
        $version = "SQL Server 2022"
    }
    elseif ($v.substring(0,$v.indexof(".")) -eq "MSSQL15")
    {
        $version = "SQL Server 2019"
    }
    elseif ($v.substring(0,$v.indexof(".")) -eq "MSSQL14")
    {
        $version = "SQL Server 2017"
    }
    elseif ($v.substring(0,$v.indexof(".")) -eq "MSSQL13")
    {
        $version = "SQL Server 2016"
    }
    elseif ($v.substring(0,$v.indexof(".")) -eq "MSSQL12")
    {
        $version = "SQL Server 2014"
    }
    elseif ($v.substring(0,$v.indexof(".")) -eq "MSSQL11")
    {
        $version = "SQL Server 2012"
    }
    $table += [pscustomobject]@{ID = $in+1;InstanceName = $serviceName[$in].tostring(); ServiceName = $service[$in]; Version = $version}
}
$table | select  * | Out-Host

$ID = Read-Host -Prompt "Please select an instance ID from the table above to continue"
$chosenInstanceName = @($table | where {$_.id -eq $ID} | select instancename).instancename 
$chosenServiceName = @($table | where {$_.id -eq $ID} | select ServiceName).ServiceName

$exist = @($table | where {$_.id -eq $ID}).Count
if ($exist -eq 0)
{
    Write-Host "Please select the correct instance as there is no instance with ID $ID." -ForegroundColor Red
}
elseif ($exist -eq 1)
{
    $stop_start = Read-Host -Prompt "Would you like to stop the instance $chosenInstanceName and then start it with minimal configuration? (Y or N)"
    if ($chosenInstanceName = "MSSQLSERVER")
    {
        $instance = @(hostname)
    }
    else
    {
        $instance = @(hostname)+"\"+$chosenInstanceName
    }
    if ($stop_start -eq "Y")
    {
        Stop-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been stopped." -ForegroundColor Black -BackgroundColor green
        net Start $chosenServiceName /mSQLCMD /f
        Write-Host "The instance ""$chosenServiceName"", has been initiated with the trace flag 3608." -ForegroundColor Black -BackgroundColor green
    }
    $audit = @(sqlcmd -S $instance -E -Q "select name from sys.server_audits where is_state_enabled = 1")
    $trigger = @(sqlcmd -S $instance -E -Q "select name from sys.server_triggers where is_disabled = 0")
    for ($loop = 0; $loop -lt $audit.count - 4; $loop++)
    {
        $ObjectTable += [pscustomobject]@{ID = $loop + 1;Name = $audit[$loop + 2].Trim(); Type = "Audit"; Status = "Enabled"}
    } 
    $id = $ObjectTable.count
    for ($loop = 0; $loop -lt $trigger.count - 4; $loop++)
    {
        $ObjectTable += [pscustomobject]@{ID = $id + $loop + 1;Name = $trigger[$loop + 2].Trim(); Type = "Trigger"; Status = "Enabled"}
    } 
    $ObjectTable | select * | Out-Host
    $existObject = @($auditTable).Count
    if ($existObject -eq 0)
    {
        Write-Host "In instance ""$chosenInstanceName"", there are no enabled audits or triggers to be disabled." -ForegroundColor Green
    }
    elseif ($existObject -gt 0)
    {
        $confirm = Read-Host -Prompt "what do you want to disable from the above list? Please type ""Trigger"", ""Audit"", or ""ALL"" or ""Press any key"" to skip and ignore."
        if ($confirm -eq "trigger" -or $confirm -eq "all")
        {
            try 
            {
                for ($loop = 0; $loop -lt $trigger.count - 4; $loop++)
                {
                    $command = "DISABLE TRIGGER ["+$trigger[$loop + 2].Trim()+"] ON ALL SERVER;"
                    $command 
                    sqlcmd -S $instance -E -Q $command
                }
                Write-Host "The trigger list has been successfully disabled." -ForegroundColor Green
             }
             catch 
             {
                Write-Host "There was an issue while trying to disable the triggers. Please troubleshoot and try again." -ForegroundColor Red
             }
        }
        if ($confirm -eq "audit" -or $confirm -eq "all")
        {
            try 
            {
                for ($loop = 0; $loop -lt $audit.count - 4; $loop++)
                {
                    $command = "ALTER SERVER AUDIT ["+$audit[$loop + 2].Trim()+"] WITH (STATE=OFF);"
                    $command 
                    sqlcmd -S $instance -E -Q $command
                }
                Write-Host "The audit list has been successfully disabled." -ForegroundColor Green
             }
             catch 
             {
                Write-Host "There was an issue while trying to disable the audits. Please troubleshoot and try again." -ForegroundColor Red
             }
        }
    }
    if ($stop_start -eq "Y")
    {
        Stop-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been stopped." -ForegroundColor Black -BackgroundColor green
        Start-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been started normally." -ForegroundColor Black -BackgroundColor green
    }
}
else
{
    Write-Host "Something went wrong." -ForegroundColor Red
}
