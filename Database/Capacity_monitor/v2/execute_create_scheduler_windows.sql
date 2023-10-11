use master
go
declare 
@username varchar(300) = 'ALBILAD\C904529',
@password varchar(300) = 'them=triX1644',
@random_n int = 5	   -- put values from 0 to 14

declare @folder_files table (output_text varchar(max))
declare
@ip varchar(100), @port varchar(10), @project varchar(300), @cmd varchar(max), @powershell varchar(max), @file_exist bit
select @ip = server_ip, @port = port, @project = [app_name]
from master.dbo.server_details
set @cmd = 'xp_cmdshell ''dir cd C:\ps_disk_style\'''

select * from master.dbo.server_details

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

set @cmd = 'xp_cmdshell ''del "C:\ps_disk_style\get_volume_style.ps1"'''
exec(@cmd)

end

--set @cmd = N'PowerShell.exe -Command "& {$volumes = Get-volume | Select-Object DriveLetter;$letter = '''';$query = ''truncate table master.dbo.disks'';Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;for($i = 0; $i -lt ($volumes.DriveLetter.Count); $i++){$diskType = Get-Volume | where DriveLetter -eq $volumes[$i].DriveLetter | Get-Partition | Get-Disk | select-object partitionstyle -First 1;$letter = $volumes[$i].DriveLetter;if ($diskType -ne $null -and $letter ){$style = $diskType.PartitionStyle.ToString();$query = ''insert into dbo.disks values (''''''+$letter+'''''',''''''+$style+'''''')'';Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;}}}"'
set @cmd = 'xp_cmdshell ''PowerShell.exe -Command "& {$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''''Disks_style''''}; if ($check){$check = ''''Y''''}else{$check = ''''N''''}; if ($check -eq ''''N''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; $action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''''P1D''''; $task.Triggers.Repetition.Interval = ''''PT1H''''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User ''''ALBILAD\C904529'''' -Password ''''them=triX1644'''';  } if ($check -eq ''''Y''''){$taskName=''''Disks_Style''''; $description=''''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''''; Unregister-ScheduledTask -TaskName $taskName -Confirm:$false; $action= New-ScheduledTaskAction -Execute ''''Powershell.exe'''' -Argument ''''-File C:\ps_disk_style\get_volume_style.ps1''''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''''P1D''''; $task.Triggers.Repetition.Interval = ''''PT1H''''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User '+''''''+@username+''''''+' -Password '+''''''+@password+''''''+';  } }"'''
exec(@cmd)
--print(@cmd)

set @powershell = '$volumes = Get-volume | Select-Object DriveLetter;
$letter = '''';
$query = ''truncate table master.dbo.disks'';
Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;
for($i = 0; $i -lt ($volumes.DriveLetter.Count); $i++){
    $diskType = Get-Volume | where DriveLetter -eq $volumes[$i].DriveLetter | Get-Partition | Get-Disk | select-object partitionstyle -First 1;
    $letter = $volumes[$i].DriveLetter;
    if ($diskType -ne $null -and $letter ){
        $style = $diskType.PartitionStyle.ToString();
        $query = ''insert into dbo.disks values (''''''+$letter+'''''',''''''+$style+'''''')'';
        Invoke-Sqlcmd -ServerInstance '+''''+@ip+','+@port+''''+' -Database master -Query $query;
    }
}'

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
--print(@cmd)
exec (@cmd)

fetch next from i into @value
end
close i
deallocate i


--print(@cmd)
--exec xp_cmdshell @cmd
--exec 
--xp_cmdshell 'PowerShell.exe -Command "& {$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''Disks_style''}; if ($check){$check = ''Y''}else{$check = ''N''}; if ($check -eq ''N''){$taskName=''Disks_Style''; $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''; $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''P1D''; $task.Triggers.Repetition.Interval = ''PT1H''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User ''ALBILAD\C904529'' -Password ''them=triX1644'';  } if ($check -eq ''Y''){$taskName=''Disks_Style''; $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''; Unregister-ScheduledTask -TaskName $taskName -Confirm:$false; $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''P1D''; $task.Triggers.Repetition.Interval = ''PT1H''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User ''ALBILAD\C904529'' -Password ''them=triX1644'';  } }"'
--xp_cmdshell 'PowerShell.exe -Command "& {$check = Get-ScheduledTask | where-object {$_.TaskName -eq ''Disks_style''}; if ($check){$check = ''Y''}else{$check = ''N''}; if ($check -eq ''N''){$taskName=''Disks_Style''; $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''; $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''P1D''; $task.Triggers.Repetition.Interval = ''PT1H''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User ''ALBILAD\C904529'' -Password ''them=triX1644'';  } if ($check -eq ''Y''){$taskName=''Disks_Style''; $description=''Fetch the disks style for database capacity monitor emails to helps DBA team to maintain the database availability''; Unregister-ScheduledTask -TaskName $taskName -Confirm:$false; $action= New-ScheduledTaskAction -Execute ''Powershell.exe'' -Argument ''-File C:\ps_disk_style\get_volume_style.ps1''; $trigger = New-ScheduledTaskTrigger -Once -At 12am;$task = Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -description $description -RunLevel 1;$task.Triggers.Repetition.Duration = ''P1D''; $task.Triggers.Repetition.Interval = ''PT1H''; $task | Set-ScheduledTask; Set-ScheduledTask -TaskName $taskName -User ''ALBILAD\C904529'' -Password ''them=triX1644'';  } }"'

--xp_cmdshell 'PowerShell.exe -Command "& {Add-Content -Path C:\ps_disk_style\test3.txt ''$letter = '''''''';''}"'
--xp_cmdshell 'PowerShell.exe -Command "& {Add-Content -Path C:\ps_disk_style\test3.txt ''Invoke-Sqlcmd -ServerInstance ''''10.0.6.22,17120'''' -Database master -Query $query;''}"'
