Function Get-DiskMaps {
$volumes = Get-volume | Where-Object {$_.DriveType -eq "Fixed"} | Select-Object DriveLetter
$pd = Get-PhysicalDisk;
$id = ""
$DeviceId = 1
$v = @()
$table = New-Object System.Collections.ArrayList;
$win = @(Get-WMIObject -Class win32_OperatingSystem | Select-Object version).version
if ($win.substring(0,$win.IndexOf('.',2)) -eq '6.2')
{
    $version = 2012
} Elseif ($win.substring(0,$win.IndexOf('.',2)) -eq '6.3')
{
    $version = 2012
} Elseif ($win -eq '10.0.14393')
{
    $version = 2016
} Elseif ($win -eq '10.0.17763')
{
    $version = 2019
} Elseif ($win -eq '10.0.20348')
{
    $version = 2022
}

for ($u = 0; $u -lt $volumes.count; $u++)
    {
       if ($volumes[$u].DriveLetter.Length -gt 0 -and $volumes[$u].DriveLetter -notin $v)
        {
            if ($version -eq 2012)
            {
                $v += $volumes[$u].DriveLetter
                $ds = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object partitionstyle -First 1;
                $sz = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object size -First 1).size/1024.0/1024.0/1024.0;
			    $id = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object Number -First 1;
                $pl = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq $id.Number} | select-object PhysicalLocation
			    $scsi = Get-WmiObject -Class Win32_DiskDrive | Where-Object {$_.Index -in $id.Number} | Select-Object SCSITargetId
                $label = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel
                if (@($label.GetType().BaseType).Name -eq "Array")
                {
                $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel[0];
                }else{
                $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel;
                }
                $table += [pscustomobject]@{ 
                          DriveLetter = $volumes[$u].DriveLetter;
                          Label = $lbl;
                          Size = $sz.ToString()+' GB'
                          PartitionStyle = $ds.partitionstyle;
                          VM_Controller = 'SCSI('+$pl.PhysicalLocation+':'+$scsi.SCSITargetId+')';
                          OS_DiskNumber = $id.Number}
            }else{
                $v += $volumes[$u].DriveLetter
                $ds = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object partitionstyle -First 1;
                $sz = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object size -First 1).size/1024.0/1024.0/1024.0;
			    $id = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object DiskNumber -First 1;
                $pl = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq $id.DiskNumber} | select-object PhysicalLocation
			    $scsi = Get-WmiObject -Class Win32_DiskDrive | Where-Object {$_.Index -in $id.DiskNumber} | Select-Object SCSITargetId
                $label = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel
                if (@($label.GetType().BaseType).Name -eq "Array")
                {
                $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel[0];
                }else{
                $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel;
                }
                $table += [pscustomobject]@{ 
                          DriveLetter = $volumes[$u].DriveLetter;
                          Label = $lbl;
                          Size = $sz.ToString()+' GB'
                          PartitionStyle = $ds.partitionstyle;
                          VM_Controller = 'SCSI('+$pl.PhysicalLocation.ToString().substring(4,$pl.PhysicalLocation.Length-4)+':'+$scsi.SCSITargetId+')';
                          OS_DiskNumber = $id.DiskNumber}
            }            
        }
    }
@(Get-WMIObject -Class win32_OperatingSystem | Select-Object Caption).Caption
$table | Sort-Object OS_DiskNumber | Format-Table;
}

Get-DiskMaps
