USE [master]
GO
/****** Object:  StoredProcedure [dbo].[server_disk_state_HTML]    Script Date: 9/29/2022 9:01:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER
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

insert into @dm_os_volume_stats
select 
master.dbo.virtical_array(output_text,'|',1), 
cast(master.dbo.virtical_array(output_text,'|',2) as float), 
cast(master.dbo.virtical_array(output_text,'|',3) as float)
from @output 
where output_text is not null 
and output_text not like '%\\?\Volume%'

end

select @vol =  isnull(@vol+', ','') + volume_mount_point 
from (select distinct v.volume_mount_point 
from sys.master_files db cross apply sys.dm_os_volume_stats(db.database_id,db.file_id) v)a

declare @iptable table (id int identity(1,1), output_Text varchar(max))
declare @xp varchar(200), @id int, @IpAddress varchar(50)
set @xp = 'ipconfig'
insert into @iptable
exec xp_cmdshell @xp

select top 1 @id = id 
from (
select id, case when charindex('.',ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))) > 0 then 1 else 0 end has_gateway
from @iptable
where id in (select id + 2
from @iptable
where output_Text like '%IPV4%'))a
where has_gateway = 1

select @IpAddress = ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))-- IP_address
from @iptable
where id = @id - 2

declare @partition_table_style table (volume varchar(10), partition_style varchar(10), warrning_file_growth int )
--***keep these commentted lines***
-------------------------------------
--declare @xp_cmdshell_disks nvarchar(max)
--set @xp_cmdshell_disks = 'xp_cmdshell ''PowerShell.exe -Command "& {$volumes = Get-volume | Select-Object DriveLetter;$letter = '''''''';$query = ''''truncate table master.dbo.disks'''';Invoke-Sqlcmd -ServerInstance '+@IpAddress+','+@port+' -Database master -Query $query;for($i = 0; $i -lt ($volumes.DriveLetter.Count); $i++){$diskType = Get-Volume | where DriveLetter -eq $volumes[$i].DriveLetter | Get-Partition | Get-Disk | select-object partitionstyle -First 1;$letter = $volumes[$i].DriveLetter;if ($diskType -ne $null){$style = $diskType.PartitionStyle.ToString();$query = ''''insert into dbo.disks values (''''''''''''+$letter+'''''''''''',''''''''''''+$style+'''''''''''')'''';Invoke-Sqlcmd -ServerInstance '+@IpAddress+','+@port+' -Database master -Query $query;}}}"'''
--set @xp_cmdshell_disks = 'xp_cmdshell ''PowerShell.exe -Command "& {$volumes = Get-volume | Select-Object DriveLetter;$letter = '''''''';$query = ''''truncate table master.dbo.disks'''';Invoke-Sqlcmd -ServerInstance '+@IpAddress+' -Database master -Query $query;for($i = 0; $i -lt ($volumes.DriveLetter.Count); $i++){$diskType = Get-Volume | where DriveLetter -eq $volumes[$i].DriveLetter | Get-Partition | Get-Disk | select-object partitionstyle -First 1;$letter = $volumes[$i].DriveLetter;if ($diskType -ne $null){$style = $diskType.PartitionStyle.ToString();$query = ''''insert into dbo.disks values (''''''''''''+$letter+'''''''''''',''''''''''''+$style+'''''''''''')'''';Invoke-Sqlcmd -ServerInstance '+@IpAddress+' -Database master -Query $query;}}}"'''
--print(@xp_cmdshell_disks)
--exec (@xp_cmdshell_disks)
--exec xp_cmdshell 'PowerShell.exe -Command "& {$volumes = Get-volume | Select-Object DriveLetter;$letter = '''';$query = ''truncate table master.dbo.disks'';Invoke-Sqlcmd -ServerInstance 10.36.0.139 -Database master -Query $query;for($i = 0; $i -lt ($volumes.DriveLetter.Count); $i++){$diskType = Get-Volume | where DriveLetter -eq $volumes[$i].DriveLetter | Get-Partition | Get-Disk | select-object partitionstyle -First 1;$letter = $volumes[$i].DriveLetter;if ($diskType -ne $null){$style = $diskType.PartitionStyle.ToString();$query = ''insert into dbo.disks values (''''''+$letter+'''''',''''''+$style+'''''')'';Invoke-Sqlcmd -ServerInstance 10.36.0.139 -Database master -Query $query;}}}"'
--truncate table dbo.disks
--select * from dbo.disks
-------------------------------------

--insert into @partition_table_style
--select distinct disk_letter+':\', style 
--from master.dbo.disks
--where cast(disk_letter as varbinary) != 0x00

--handling mirroring databases
---------------------------------------------------------------------------------&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0
begin
insert into @partition_table_style
select
vs.volume_mount_point, ds.style,
case when sum(case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 1 else 0 end) > 0 then 1 else 0 end warrning_file
from sys.master_files mf cross apply sys.dm_os_volume_stats(database_id, file_id) vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
group by vs.volume_mount_point, ds.style

end
else
begin
insert into @partition_table_style
select
vs.volume_mount_point, ds.style,
case when sum(case when ((case when max_size < 0 then available_bytes/1024.0 else max_size * 8.0 end) / (total_bytes/1024.0) * 100.0) > 90.0 and growth != 0 and ds.style = 'MBR' and vs.total_bytes / 1024.0/1024.0/1024.0/1024.0 > 1.95 then 1 else 0 end) > 0 then 1 else 0 end warrning_file
from sys.master_files mf cross apply @dm_os_volume_stats vs
inner join master.dbo.disks ds
on ds.disk_letter+':\' = vs.volume_mount_point
group by vs.volume_mount_point, ds.style

end
---------------------------------------------------------------------------------&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

if object_id('server_disk_state__9870') is not null
begin
drop table server_disk_state__9870
create table server_disk_state__9870(
[volume] varchar(10), [volume_total_size] varchar(10), [volume_free_size] varchar(10), [Partition_Style] varchar(5), [volume_used] varchar(10), [threshold] varchar(10), 
[recommended_extend_size_1] varchar(10),
[recommended_extend_size_2] varchar(10),
[recommended_extend_size_3] varchar(10), warrning_file_growth varchar(5))
end
else
begin
create table server_disk_state__9870(
[volume] varchar(10), [volume_total_size] varchar(10), [volume_free_size] varchar(10), [Partition_Style] varchar(5), [volume_used] varchar(10), [threshold] varchar(10), 
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
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'),
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
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'),
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
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'),
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
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A'),
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

declare @col varchar(300) = 'recommended_extend_size_'
set @col = 'recommended_extend_size_'+cast(@threshold_pct as varchar(10))
exec sp_rename 'server_disk_state__9870.recommended_extend_size_1', @col
set @col = 'recommended_extend_size_'+cast(@threshold_pct-2 as varchar(10))
exec sp_rename 'server_disk_state__9870.recommended_extend_size_2', @col
set @col = 'recommended_extend_size_'+cast(@threshold_pct-5 as varchar(10))
exec sp_rename 'server_disk_state__9870.recommended_extend_size_3', @col

select @has_over = count(*)
from server_disk_state__9870
where volume not in (
select volume
from server_disk_state__9870
where volume_total_size = '2 TB' and Partition_Style = 'MBR')
and cast(volume_used  as float) >= cast(@threshold_pct as float)

declare 
@tr varchar(max), 
@th varchar(max), 
@cursor____columns varchar(max), 
@cursor_vq_columns varchar(max), 
@cursor_vd_columns varchar(max), 
@cursor_vr_columns varchar(max), 
@query_columns_count int, 
@sqlstatement varchar(max),
@border_color varchar(100) = 'gray'

declare @tr_table table (id int identity(1,1), row_id int, tr varchar(1000))

select
@cursor____columns = isnull(@cursor____columns+',
','')+'['+c.name+']',
@cursor_vq_columns = isnull(@cursor_vq_columns+',
','')+'@'+replace(c.name,' ','_'),
@cursor_vd_columns = isnull(@cursor_vd_columns+',
','')+'@'+replace(c.name,' ','_')+' '+case 
when t.name in ('char','nchar','varchar','nvarchar') then t.name+'('+case when c.max_length < 0 then 'max' else cast(c.max_length as varchar(10)) end+')' 
when t.name in ('bit') then 'varchar(5)'
when t.name in ('real','int','bigint','smallint','tinyint','float') then 'varchar(20)'
else '' 
end,
@cursor_vr_columns = isnull(@cursor_vr_columns+'
union all 
select @loop, ','')+''''+'<td style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle; '+
+'background-color: '''+'+'+
case 
when c.name = 'volume_used' then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') and @warrning_file_growth  = ''0'' then ''purple'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') and @warrning_file_growth  = ''1'' then ''black'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size not in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') then ''red'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red'' 
else ''green'' end' 
when c.name = 'volume' then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') and @warrning_file_growth  = ''0'' then ''purple'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') and @warrning_file_growth  = ''1'' then ''black'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size not in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') then ''red''  
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red'' 
else ''green'' end'
--when c.name = 'volume' then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @volume not in (''H:\'') then ''red'' else ''green'' end' 

when c.name = 
'recommended_extend_size_'+cast(@threshold_pct - 0 as varchar) then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''LightGreen'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size not in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') then ''LightGreen''
else ''white'' end' 
when c.name = 
'recommended_extend_size_'+cast(@threshold_pct - 2 as varchar) then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''LightGreen'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size not in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') then ''LightGreen''
else ''white'' end' 
when c.name = 
'recommended_extend_size_'+cast(@threshold_pct - 5 as varchar) then 'case 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''LightGreen'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size not in (''1.95 TB'',''1.96 TB'',''1.97 TB'',''1.98 TB'',''1.99 TB'',''2 TB'') then ''LightGreen''
else ''white'' end' 
when c.name = 'partition_style' then 'case when @partition_style = ''MBR'' then ''purple'' else ''green'' end'
else '' end+'+'+'''; '+
case 
when c.name in ('volume_used','volume','partition_style') then 'color: white' 
else 'color: black' 
end +'">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''

--this line below if you need to highlight all background row in red color.
--+'background-color: '''+'+'+'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' then ''red'' else ''white'' end' +'+'+''';">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''

from sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from sys.tables
where name like 'server_disk_state__9870')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'server_disk_state__9870')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'server_disk_state__9870')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from server_disk_state__9870
order by volume

open i 
fetch next from i into '+@cursor_vq_columns+'
while @@fetch_status = 0
begin
set @loop = @loop + 1
select @loop, '+@cursor_vr_columns+'
fetch next from i into '+@cursor_vq_columns+'
end
close i
deallocate i'

--print(@sqlstatement)
insert into @tr_table
exec(@sqlstatement)

select @tr = isnull(@tr+'
','') +
case 
when col_position = 1 then
'</tr>
  <tr style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle;">
  '+tr
when col_position = col_count then
tr+'
</tr>'
else 
tr
end
from (
select top 100 percent row_number() over(partition by row_id order by id) col_position,id,row_id,@query_columns_count col_count,tr 
from @tr_table
order by id, row_id)a


declare @table varchar(max) = '
<table style="border:1px solid '+@border_color+';border-collapse:collapse;width: 75%">
  <tr bgcolor="YELLOW">
  '+@th+'
  '+@tr+'
'+'</table>'

set @html = @table

drop table server_disk_state__9870
set nocount off
end

