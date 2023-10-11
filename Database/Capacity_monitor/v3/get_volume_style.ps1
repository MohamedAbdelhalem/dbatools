$instance= "10.33.102.17,1433"
$volumes = Get-volume | Where-Object {$_.DriveType -eq 'Fixed'} | Select-Object DriveLetter | Sort-Object DriveLetter
$pd = Get-PhysicalDisk;
$query = "
if object_id('dbo.disks') is not null 
begin 
drop table [master].[dbo].[disks]; 
end
create table [master].[dbo].[disks](disk_letter varchar(10),style varchar(15),vm_physicalLocation varchar(10),os_deviceId varchar(10));"
Invoke-Sqlcmd -ServerInstance $instance -Database master -Query $query;
$v = @()
$id = @()
$loop = 0
for ($u = 0; $u -lt $volumes.count; $u++)
    {
       if ($volumes[$u].DriveLetter.Length -gt 0 -and $volumes[$u].DriveLetter -notin $v)
        {
            $v += $volumes[$u].DriveLetter
            $ds = Get-Volume | where DriveLetter -eq $v[$loop] |Get-Partition | Get-Disk | select-object partitionstyle  -First 1;
            #$ds.PartitionStyle
			$id = Get-Volume | where DriveLetter -eq $v[$loop] |Get-Partition | Get-Disk | select-object DiskNumber | Sort-Object DiskNumber -Descending;
            #Get-Volume | where DriveLetter -eq $v[$loop] |Get-Partition | Get-Disk | select-object DiskNumber | Sort-Object DiskNumber -Descending;            
            $pl = $pd | Where-Object {$_.DeviceId -eq $id[0].DiskNumber} | select-object PhysicalLocation | Sort-Object PhysicalLocation;
			$scsi = Get-WmiObject -Class Win32_DiskDrive | Where-Object {$_.Index -in $id[0].DiskNumber} | Select-Object SCSITargetId;
            #$pl.PhysicalLocation
            #$scsi.SCSITargetId
			$query = 'insert into dbo.disks values ('''+$v[$loop]+''','''+$ds.partitionstyle+''','''+$pl.PhysicalLocation.ToString().substring(0,4)+'('+$pl.PhysicalLocation.ToString().substring(4,$pl.PhysicalLocation.Length-4)+':'+$scsi.SCSITargetId+')' +''','''+$id.DiskNumber+''')';
			$query
			Invoke-Sqlcmd -ServerInstance $instance -Database master -Query $query;
            $loop += 1
            $id = @()
			}
	}
