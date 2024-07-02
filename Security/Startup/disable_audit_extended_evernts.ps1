#attention#
#######################################################
#If you have an issue with your instance that prevents you from querying anything from the database e.g. sys.sysprcesses or in your user databases
#and you suspicions about the audit is the root cause, so, choose first the instance ID (if you have multip-instances, if not it's always number 1)
#then "N" for not stop and start the instance 
#if the script couldn't able to query out the audit list
#then "Y" to stop the instance and start it with trace falg 3608
#######################################################
                                                                                         
$service = [System.Collections.ArrayList]@()
$serviceName = [System.Collections.ArrayList]@()
$table = New-Object System.Collections.ArrayList;
$auditTable = New-Object System.Collections.ArrayList;
$service = @(get-service -name "*sql*" | where {$_.DisplayName -like "SQL Server (*"} | select Name | sort DisplayName).name
$audit = [System.Collections.ArrayList]@()

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

$ID = Read-Host -Prompt "Please select an instance ID from the table above to continue."
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

    $audit = @(sqlcmd -S $instance -E -Q "select name from sys.server_audits where is_state_enabled = 1")

    if ($stop_start -eq "Y")
    {
        Stop-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been stopped." -ForegroundColor white -BackgroundColor green
        net Start $chosenServiceName /T3608
        Write-Host "The instance ""$chosenServiceName"", has been initiated with the trace flag 3608." -ForegroundColor white -BackgroundColor green
    }

    for ($loop = 0; $loop -lt $audit.count - 4; $loop++)
    {
        $auditTable += [pscustomobject]@{ID = $loop+1;AuditName = $audit[$loop + 2].Trim(); Status = "Enabled"}
    } 
    $auditTable | select * | Out-Host
    $existAduit = @($auditTable).Count
    if ($existAduit -eq 0)
    {
        Write-Host "In instance ""$chosenInstanceName"", there are no enabled audits to be disabled." -ForegroundColor Green
    }
    elseif ($existAduit -gt 0)
    {
        $confirm = Read-Host -Prompt "Would you like to disable the audit list above? Please type ""Confirm"" to proceed or ""Press any key"" to skip and ignore."
        if ($confirm -eq "Confirm")
        {
            try 
            {
                for ($loop = 0; $loop -lt $audit.count - 4; $loop++)
                {
                    $command = "ALTER SERVER AUDIT ["+$audit[$loop + 2].Trim()+"] WITH (STATE=OFF);"
                    sqlcmd -S $instance -E -Q $command
                }
                Write-Host "The audit list has been successfully disabled." -ForegroundColor Green
             }
             catch 
             {
                Write-Host "There was an issue while trying to disable the audit. Please troubleshoot and try again." -ForegroundColor Red
             }
        }
    }
    if ($stop_start -eq "Y")
    {
        Stop-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been stopped." -ForegroundColor white -BackgroundColor green
        Start-Service -Name $chosenServiceName
        Write-Host "Instance ""$chosenServiceName"" has been started." -ForegroundColor white -BackgroundColor green
    }
}
else
{
    Write-Host "Something went wrong." -ForegroundColor Red
}

#rv confirm
#rv loop
#rv stop_start
#rv instance
#rv chosenServiceName
#rv chosenInstanceName
#rv ID
#rv table

