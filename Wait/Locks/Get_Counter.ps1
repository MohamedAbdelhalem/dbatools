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

$counterName = "\SQLServer:Memory Manager\Lock Memory (KB)"
$periodMinutes = 2
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
    $portPat = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$v\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
    
    $port = (get-ItemProperty $portPat).TcpPort
    $table += [pscustomobject]@{ID = $in+1;InstanceName = $serviceName[$in].tostring(); ServiceName = $service[$in]; Version = $version; Port = $port}
}

$table | select  * | format-table -auto | Out-Host

$ID = Read-Host -Prompt "Please select an instance ID from the table above to continue"
$chosenInstanceName = @($table | where {$_.id -eq $ID} | select instancename).instancename 
$chosenServiceName = @($table | where {$_.id -eq $ID} | select ServiceName).ServiceName
$hostname = @(hostname)
if ($chosenInstanceName -eq "MSSQLSERVER")
{
    $serverName = $hostname
}
else
{
    $serverName = $hostname+"\"+$chosenInstanceName
}

    $query = "Truncate table master.dbo.counter;"
    Sqlcmd -S $serverName -d master -Q $query;

for ($i = 0; $i -lt ($periodMinutes * 60); $i++) 
{
    $LockMemoryKB = @(get-counter -counter $counterName| select -ExpandProperty countersamples).CookedValue
    $query = "Insert into master.dbo.counter (counterValue) values ($LockMemoryKB);"
    Sqlcmd -S $serverName -d master -Q $query;
}
