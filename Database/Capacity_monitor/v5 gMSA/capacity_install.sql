use master

go

declare

@username varchar(300),

@ip varchar(100), 

@port varchar(10), 

@project varchar(300), 

@cmd varchar(max), 

@powershell varchar(max), 

@file_exist bit

declare @folder_files table (output_text varchar(max))

declare @exist_admin table (output_text varchar(max))
 
if (select top 1 service_account from sys.dm_server_services where servicename like 'SQL Server (%') like '%$'

begin

set @username = (select top 1 service_account from sys.dm_server_services where servicename like 'SQL Server (%')

end
 
set @cmd = 'xp_cmdshell ''net localgroup administrators'''

insert into @exist_admin

exec(@cmd)
 
if not exists (select * from @exist_admin where output_text like '%'+@username+'%')

begin

set @cmd = 'xp_cmdshell ''net localgroup administrators '+@username+' /add'''

exec(@cmd)

print('Open PowerShell as administrator')

print(ltrim(rtrim(replace(replace(@cmd,'''',''),'xp_cmdshell',''))))

end
 
select @ip = server_ip, @port = port, @project = [app_name]

from master.dbo.server_details

set @cmd = 'xp_cmdshell ''dir cd C:\ps_disk_style\'''
 
insert into @folder_files

exec(@cmd)
 
if (select count(*) from @folder_files where output_text = 'The system cannot find the file specified.') = 1

begin

set @cmd = 'xp_cmdshell ''mkdir "C:\ps_disk_style\"'''

exec(@cmd)

end

else

begin

select @file_exist = count(*)

from (

select ltrim(rtrim(substring(output_text,charindex(' ', output_text)+1,len(output_text)))) output_text

from (

select ltrim(rtrim(substring(output_text,charindex('M ', output_text)+2,len(output_text)))) output_text

from @folder_files

where output_text like '%M %'

and output_text not like '%<DIR>%')a)b

where output_text = 'get_volume_style.ps1'
 
if @file_exist > 0

begin

set @cmd = 'xp_cmdshell ''del "C:\ps_disk_style\get_volume_style.ps1"'''

exec(@cmd)

print(@cmd)

end
 
end
 
--set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''''Disks_style''''}; if ($check){$check = ''''Y''''}else{$check = ''''N''''}; if ($check -eq ''''N''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; $action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''''P1D''''; $task.Triggers.Repetition.Interval = ''''PT1H''''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User '+''''''+@username+''''''+' -Password '+''''''+@password+''''''+';  } if ($check -eq ''''Y''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; Unregister-ScheduledTask -TaskName $taskName -Confirm:$false; $action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''''P1D''''; $task.Triggers.Repetition.Interval = ''''PT1H''''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User '+''''''+@username+''''''+' -Password '+''''''+@password+''''''+';  } }"'''

--new gMSA$

set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''''Disks_style''''}; if ($check){$check = ''''Y''''}else{$check = ''''N''''}; if ($check -eq ''''N''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; $action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$principal = New-ScheduledTaskPrincipal -UserId '+''''''+@username+''''''+' -LogonType Password -RunLevel Highest;$task = Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Trigger $trigger;    $task.Triggers.Repetition.Duration = ''''P1D'''';$task.Triggers.Repetition.Interval = ''''PT1H''''} if ($check -eq ''''Y''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; Unregister-ScheduledTask -TaskName $taskName -Confirm:$false;$action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$principal = New-ScheduledTaskPrincipal -UserId '+''''''+@username+''''''+' -LogonType Password -RunLevel Highest; $task = Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Trigger $trigger; $task.Triggers.Repetition.Duration = ''''P1D''''; $task.Triggers.Repetition.Interval = ''''PT1H''''; } }"'''
 
exec(@cmd)

print(@cmd)

set @cmd = '$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''Disks_style''}

if ($check)

{

    $check = ''Y''

}

else

{

    $check = ''N''

}

if ($check -eq ''N'')

{

    $taskName=''Disks_Style''

    $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''

    $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''

    $trigger = New-ScheduledTaskTrigger -Once -At 12am

	$principal = New-ScheduledTaskPrincipal -UserId '+@username+' -LogonType Password -RunLevel Highest

    $task = Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Trigger $trigger 

    $task.Triggers.Repetition.Duration = ''P1D''

    $task.Triggers.Repetition.Interval = ''PT1H''

} 

if ($check -eq ''Y'')

{

    $taskName=''Disks_Style''

    $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''

    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false

    $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''

    $trigger = New-ScheduledTaskTrigger -Once -At 12am

    $principal = New-ScheduledTaskPrincipal -UserId '+@username+' -LogonType Password -RunLevel Highest

    $task = Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Trigger $trigger 

    $task.Triggers.Repetition.Duration = ''P1D''

    $task.Triggers.Repetition.Interval = ''PT1H''

}'

print(@cmd)

 
if (master.dbo.Win_Version(1) in ('2012'))

begin

set @powershell = '$volumes = Get-volume | Where-Object {$_.DriveType -eq ''Fixed''} | Select-Object DriveLetter

$pd = Get-PhysicalDisk;

$query = ''truncate table master.dbo.disks'';

Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;

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

			$id = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object Number | where {$_.DiskNumber -ne $null};

            $pl = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq $id.Number} | select-object PhysicalLocation -First 1

			$scsi = Get-WmiObject -Class Win32_DiskDrive | Where-Object {$_.Index -in $id.Number} | Select-Object SCSITargetId

            $label = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel

            if (@($label.GetType().BaseType).Name -eq ''Array'')

            {

            $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel[0];

            }else{

            $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel;

            }

			$query = ''insert into dbo.disks values (''''''+$volumes[$u].DriveLetter+'''''',''''''+$ds.partitionstyle+'''''',''''''+''SCSI(''+$pl.PhysicalLocation+'':''+$scsi.SCSITargetId+'')'' +'''''',''''''+$id.Number+'''''')'';

			#$query

			Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;

			$loop += 1

            $id = @()

			}

	}'

end

else

begin
 
set @powershell = '$volumes = Get-volume | Where-Object {$_.DriveType -eq ''Fixed''} | Select-Object DriveLetter

$pd = Get-PhysicalDisk;

$query = ''truncate table master.dbo.disks'';

Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;

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

			$id = Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter |Get-Partition | Get-Disk | select-object DiskNumber | where {$_.DiskNumber -ne $null};

            $pl = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq $id.DiskNumber} | select-object PhysicalLocation -First 1

			$scsi = Get-WmiObject -Class Win32_DiskDrive | Where-Object {$_.Index -in $id.DiskNumber} | Select-Object SCSITargetId

            $label = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel

            if (@($label.GetType().BaseType).Name -eq ''Array'')

            {

            $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel[0];

            }else{

            $lbl = @(Get-Volume | where DriveLetter -eq $volumes[$u].DriveLetter | Select-Object FileSystemLabel).FileSystemLabel;

            }

			$query = ''insert into dbo.disks values (''''''+$volumes[$u].DriveLetter+'''''',''''''+$ds.partitionstyle+'''''',''''''+''SCSI(''+$pl.PhysicalLocation.ToString().substring(4,$pl.PhysicalLocation.Length-4)+'':''+$scsi.SCSITargetId+'')'' +'''''',''''''+$id.DiskNumber+'''''')'';

			#$query

			Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;

			$loop += 1

            $id = @()

			}

	}'

end
 
declare @value varchar(1000)

declare i cursor fast_forward

for

select value 

from master.dbo.separator(@powershell,char(10))

order by id
 
open i

fetch next from i into @value

while @@FETCH_STATUS = 0

begin
 
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {Add-Content -Path C:\ps_disk_style\get_volume_style.ps1 '+''''''+replace(convert(varbinary(max),replace(convert(varbinary(max),@value),0x0D,'')),0x27,0x27272727)+''''''+'}"'''

exec (@cmd)
 
fetch next from i into @value

end

close i

deallocate i
 
go

if object_id('dbo.triggers_status') is not null

begin

drop table dbo.triggers_status 

end

go

create table dbo.triggers_status (name varchar(500), is_disable bit)

insert into triggers_status 

select name, is_disabled from sys.server_triggers

go
 
declare @name varchar(500), @is_disable bit, @sql varchar(1000)

declare t cursor fast_forward

for

select name, is_disable

from dbo.triggers_status

where is_disable = 0
 
open t

fetch next from t into @name, @is_disable

while @@FETCH_STATUS = 0

begin

set @sql = 'DISABLE TRIGGER '+@name+' ON ALL SERVER'

exec(@sql)

fetch next from t into @name, @is_disable

end

close t

deallocate t

go
 
USE [master]

GO

declare 

@type varchar(30),

@name varchar(300),

@sql varchar(1000)
 
declare i cursor fast_forward

for

select case type 

when 'P'	then 'PROCEDURE' 

when 'V'	then 'VIEW' 

when 'U'	then 'TABLE'

when 'TF'	then 'FUNCTION'

when 'FN'	then 'FUNCTION'

when 'FS'	then 'FUNCTION'

end type, '['+schema_name(schema_id)+'].['+name+']'

from sys.objects

where object_id in (

object_id('[dbo].[disks]'), 

object_id('[dbo].[server_disk_state_HTML]'),

object_id('[dbo].[server_disk_state_email]')

)

union all

select 'JOB', name 

from msdb.dbo.sysjobs

where name = 'capacity_manager_view'

order by type
 
open i

fetch next from i into @type, @name

while @@FETCH_STATUS = 0

begin

if @type = 'JOB'

begin

	set @sql = 'EXEC msdb.dbo.sp_delete_job @job_name=N'+''''+@name+''''+', @delete_unused_schedule=1'

	exec(@sql)

	print(@sql)

end

else

begin

	set @sql = 'DROP '+@type+' '+@name

	exec(@sql)

	print(@sql)

end

fetch next from i into @type, @name

end

close i

deallocate i

GO
 
declare @white_list_users table (

[account_number] [varchar](100) NULL,

[username] [varchar](100) NULL,

[team] [varchar](100) NULL,

[is_allowed] [bit] NULL,

[email] [varchar](300) NULL,

[send_notification] [bit] NULL)

insert into @white_list_users (account_number, username, team, is_allowed, email, send_notification)

values 

('ALBILAD\e008374', 'Fahad Suliman Alqarawi', 'DBA Manager', 1,'FSAlqarawi@bankAlbilad.com',0),

('ALBILAD\e004199', 'Abdulmohsen Ibrahim Bin Abdulwahed', 'DBA', 1,'AI.BinAbdulwahed@Bankalbilad.com',1),

('ALBILAD\c904153', 'Shaik Zubair Fareed', 'DBA', 1, 'SZubairFareed@Bankalbilad.com',1),

('ALBILAD\c904529', 'Mohammed Fawzy AlHaleem', 'DBA', 1, 'MFawzyAlHaleem@Bankalbilad.com',0),

('ALBILAD\e010043', 'Nawaf Abdulrahman Bukhari', 'DBA', 1,'NAbdulrahmanBukhari@Bankalbilad.com',0),

('ALBILAD\e010053',	'Saud Abdullah Al Ballaa','DBA', 1, 'SAbdullahAlBallaa@Bankalbilad.com', 1),

('ALBILAD\e010312',	'Abdullah Saeed Alzahrani','DBA', 1, 'asaeedalzahrani@bankalbilad.com', 1),

('BANKSA', 'System Admin', 'System Admin', 1, NULL, 0)
 
if object_id('dbo.white_list_users') is not null

begin

truncate table dbo.white_list_users
 
insert into master.dbo.white_list_users (account_number, username, team, is_allowed, email, send_notification)

select account_number, username, team, is_allowed, email, send_notification 

from @white_list_users

where is_allowed = 1

--and send_notification = 1

end

else

begin

 
create table white_list_users 

(id int identity(1,1), account_number varchar(100), username varchar(100), team varchar(100), is_allowed bit, email varchar(300), send_notification bit)
 
insert into master.dbo.white_list_users (account_number, username, team, is_allowed, email, send_notification)

select account_number, username, team, is_allowed, email, send_notification 

from @white_list_users

where is_allowed = 1

--and send_notification = 1
 
end

go
 
CREATE TABLE [dbo].[disks](

[disk_letter] [varchar](10),

[style] [varchar](10),

[vm_physicalLocation] [varchar](1000),

[os_deviceId] [varchar](10)

)
 
GO

Create

Procedure [dbo].[server_disk_state_HTML](

@html				varchar(max) output,

@has_over			int output,

@databases			varchar(max) = '*',

@with_system		bit = 0,

@threshold_pct		int,

@over				int)

as

begin
 
declare @server_name varchar(255), @sql varchar(400)

declare @output table (output_text varchar(255))

declare @dm_os_volume_stats table (volume_mount_point varchar(10), total_bytes float, available_bytes float)
 
declare @hostname_table table (output_text varchar(100))

insert into @hostname_table

exec('xp_cmdshell ''hostname''')
 
select @server_name = output_text 

from @hostname_table 

where output_text is not null
 
declare @port varchar(10)

select @port = port 

from sys.dm_tcp_listener_states 

where listener_id = 1
 
set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@server_name,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity+''|''+$_.freespace}"'

insert @output

EXEC xp_cmdshell @sql

declare @db varchar(1000), @vol varchar(300), @file_0 int, @file_1 int

declare @db_size table (id int identity(1,1), 

database_name varchar(300), file_type int, [file_id] int, logical_name varchar(1000), physical_name varchar(2000), 

size_n int, size varchar(50), growth_n int, growth varchar(50), used_n int, used varchar(50), free_n int, free varchar(50), max_size varchar(50))
 
if @databases = '*'

begin

	if @with_system = 0

	begin

		select @db = isnull(@db+', ','') + name from sys.databases where database_id > 4 order by name

	end

	else

	begin

		select @db = isnull(@db+', ','') + name from sys.databases order by name

	end

end

else

begin

	set @db = @databases

end
 
if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0

begin
 
insert into @db_size (database_name, file_type, [file_id], logical_name, physical_name, size_n, size, growth_n, growth, used_n, used, free_n, free, max_size)

exec sp_MSforeachdb '

use [?]

select db_name(database_id), case type when 0 then 1 else 2 end file_type, file_id, name, physical_name, 

(cast(size as float) / cast(1024 as float)) * 8.0 size_,

master.dbo.numbersize((cast(size as float) / cast(1024 as float)) * 8.0,''mb'') size,

(cast(growth as float) / cast(1024 as float)) * 8.0 growth_,

master.dbo.numbersize((cast(growth as float)) * 8.0,''kb'') growth,

(cast(fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 used_,

master.dbo.numbersize((cast(fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 ,''Mb'') used_space,

(cast(size - fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 free_,

master.dbo.numbersize((cast(size - fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0,''Mb'') free_space,

case when cast(max_size as float) = -1 then ''unlimited'' collate Arabic_100_CI_AS else master.dbo.numbersize((cast(max_size as float) / cast(1024 as float)) * 8.0,''Mb'') end max_size

from sys.master_files

where database_id = db_id() '
 
end

else

begin
 
insert into @db_size (database_name, file_type, [file_id], logical_name, physical_name, size_n, size, growth_n, growth)

exec('

select db_name(database_id), case type when 0 then 1 else 2 end file_type, file_id, name, physical_name, 

(cast(size as float) / cast(1024 as float)) * 8.0 size_,

master.dbo.numbersize((cast(size as float) / cast(1024 as float)) * 8.0,''mb'') size,

(cast(growth as float) / cast(1024 as float)) * 8.0 growth_,

master.dbo.numbersize((cast(growth as float)) * 8.0,''kb'') growth

from sys.master_files')

 end
else
begin
insert into @partition_table_style
select
vs.volume_mount_point, ds.style, ds.vm_physicalLocation, ds.os_deviceId,  
case when sum(case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 1 else 0 end) > 0 then 1 else 0 end warrning_file
from sys.master_files mf cross apply @dm_os_volume_stats vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
group by vs.volume_mount_point, ds.style, ds.vm_physicalLocation, ds.os_deviceId
order by ds.vm_physicalLocation
 
end
---------------------------------------------------------------------------------&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 
if object_id('server_disk_state__9870') is not null
begin
drop table server_disk_state__9870
create table server_disk_state__9870(
[volume] varchar(10), [volume_total_size] varchar(10), [volume_free_size] varchar(10), [Partition_Style] varchar(5),vm_physicalLocation varchar(1000), os_deviceId varchar(5), [volume_used] varchar(10), [threshold] varchar(10), 
[recommended_extend_size_1] varchar(10),
[recommended_extend_size_2] varchar(10),
[recommended_extend_size_3] varchar(10), warrning_file_growth varchar(5))
end
else
begin
create table server_disk_state__9870(
[volume] varchar(10), [volume_total_size] varchar(10), [volume_free_size] varchar(10), [Partition_Style] varchar(5),vm_physicalLocation varchar(1000), os_deviceId varchar(5), [volume_used] varchar(10), [threshold] varchar(10), 
[recommended_extend_size_1] varchar(10),
[recommended_extend_size_2] varchar(10),
[recommended_extend_size_3] varchar(10), warrning_file_growth varchar(5))
end
 
if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0
begin
	if @over = 1
	begin
	insert into server_disk_state__9870
		select distinct 
		volume_mount_point volume,
		master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'), isnull(ps.vm_physicalLocation ,'N/A') vm_physicalLocation,isnull(ps.os_deviceId,'N/A'),
		cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
		recommended_extend_size_1,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte') 
		recommended_extend_size_2,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte') 
		recommended_extend_size_3, ps.warrning_file_growth
		from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
		left outer join @partition_table_style ps
		on v.volume_mount_point = ps.volume
		where volume_mount_point in (select ltrim(rtrim(value)) from master.dbo.Separator(@vol,','))
		and cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) >= @threshold_pct
		order by v.volume_mount_point
	end
	else
	begin
	insert into server_disk_state__9870
		select distinct 
		volume_mount_point volume,
		master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'), isnull(ps.vm_physicalLocation ,'N/A'),isnull(ps.os_deviceId,'N/A'),
		cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
		recommended_extend_size_1,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte') 
		recommended_extend_size_2,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte') 
		recommended_extend_size_3, ps.warrning_file_growth		
		from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
		left outer join @partition_table_style ps
		on v.volume_mount_point = ps.volume
		where volume_mount_point in (select ltrim(rtrim(value)) from master.dbo.Separator(@vol,','))
		order by v.volume_mount_point
	end
end
else
begin
	if @over = 0
	begin
		insert into server_disk_state__9870
		select 
		volume_mount_point volume,
		master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'), isnull(ps.vm_physicalLocation ,'N/A'),isnull(ps.os_deviceId,'N/A'),
		cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
		recommended_extend_size_1,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2) 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte') 
		recommended_extend_size_2,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte') 
		recommended_extend_size_3, ps.warrning_file_growth		
		from @dm_os_volume_stats v left outer join @partition_table_style ps
		on v.volume_mount_point = ps.volume
		order by v.volume_mount_point
	end
	else
	begin
		insert into server_disk_state__9870
		select 
		volume_mount_point volume,
		master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'), isnull(ps.vm_physicalLocation ,'N/A'),isnull(ps.os_deviceId,'N/A'),
		cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
		recommended_extend_size_1,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2) 
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte') 
		recommended_extend_size_2,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte') 
		recommended_extend_size_3, ps.warrning_file_growth		
		from @dm_os_volume_stats v left outer join @partition_table_style ps
		on v.volume_mount_point = ps.volume
		where cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
		order by v.volume_mount_point
	end
end
