CREATE
Procedure [dbo].[server_disk_state_HTML](
@html                      varchar(max) output,
@has_over                  int output,
@databases                 varchar(max) = '*',
@with_system               bit = 0,
@threshold_pct             int = 85,
@threshold_Maxfiles_pct    int = 93,
@over                      int = 0
)
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
declare @sql_maxsize varchar(max)
declare @max_table table (drive_letter varchar(5), used_size_PCT_till_max_size varchar(50))

set @sql_maxsize = 'use [T24Prod]
select
left(physical_name,3) drive_letter,
round((sum((FILEPROPERTY(name, ''spaceused'') * 8.0)/1024.0) /
sum((max_size * 8.0)/1024.0)) * 100, 2) used_size_PCT_till_max_size
from sys.database_files
where data_space_id = 2
group by left(physical_name,3)'

insert into @max_table
exec (@sql_maxsize)

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

declare @disk table (id int identity(1,1), output_text varchar(255))
declare @partition table (id int identity(1,1), output_text varchar(255))
declare @disk_table table (id int, DiskNumber int, Path varchar(2000), Partition_Style varchar(10))
declare @partition_table table (id int, Disk_id varchar(2000), DiskNumber int, drive_letter varchar(50), size varchar(50))
declare @sql_disk varchar(1000), @sql_partition varchar(1000), @sql_volume varchar(1000)
declare @partition_table_style table (volume varchar(5), volume_size varchar(20), partition_style varchar(10))

--set @sql_disk = 'powershell.exe -c "get-disk | format-list"'
set @sql_disk = 'type "c:\part\disk_table.txt"'
--set @sql_partition = 'powershell.exe -c "get-partition | format-list"'
set @sql_partition = 'type c:\part\partition_table.txt'

insert @disk EXEC xp_cmdshell @sql_disk
insert @partition EXEC xp_cmdshell @sql_partition

insert into @disk_table
select *
from (
select case when patch_id = 1 then (max(patch_id_2) over() + patch_id) - patch_id_2 else patch_id_2 end id, column_name, column_value
from (
select row_number() over(partition by patch_id order by patch_id) patch_id_2, *
from (
select
row_number() over(order by id, column_name) % 3 patch_id,
id, column_name,  column_value
from (
select id, substring(output_text, 1, charindex(' ',output_text)-1) column_name,  ltrim(rtrim(substring(output_text, charindex(':',output_text)+1, len(output_text)))) column_value
from @disk
where output_text like 'number %'
   or output_text like 'path %'
   or output_text like 'PartitionStyle %') a)b)c)d
pivot (
max(column_value) for column_name in ([Number],[Path],[PartitionStyle])) p

insert into @partition_table
select *
from (
select case when patch_id = 1 then (max(patch_id_2) over() + patch_id) - patch_id_2 else patch_id_2 end id, column_name, column_value
from (
select row_number() over(partition by patch_id order by id) patch_id_2, *
from (
select
row_number() over(order by id, column_name) % 4 patch_id,
id, column_name,  column_value
from (
select id, substring(output_text, 1, charindex(' ',output_text)-1) column_name,  ltrim(rtrim(substring(output_text, charindex(':',output_text)+1, len(output_text)))) column_value
from @partition
where output_text like 'DiskId %'
   or output_text like 'DiskNumber %'
   or output_text like 'size %'
   or output_text like 'DriveLetter %')a)b)c)d
pivot (
max(column_value) for column_name in ([DiskId],[DiskNumber],[DriveLetter],[size])) p
where len(DriveLetter) = 1
and cast(DriveLetter as varbinary) != 0x00

insert into @partition_table_style
select
p.drive_letter+':\' volume,
master.dbo.numberSize(p.size, 'byte') Volume_size,
Partition_Style
from @partition_table p inner join @disk_table d
on p.DiskNumber = d.DiskNumber
where p.DiskNumber > 0
order by p.drive_letter

if object_id('server_disk_state__9870') is not null
begin
drop table server_disk_state__9870
create table server_disk_state__9870(
[volume] varchar(10),
[volume_total_size] varchar(10),
[volume_free_size] varchar(10),
[Partition_Style] varchar(5),
[volume_used] varchar(10),
[threshold] varchar(10),
files_total_space varchar(10),
files_used_space varchar(10),
files_free_space varchar(10),
[threshold_maxfile] varchar(10),
files_max_space                varchar(10),
[recommended_extend_size_1] varchar(10),
[recommended_extend_size_2] varchar(10),
[recommended_extend_size_3] varchar(10))
end
else
begin
create table server_disk_state__9870(
[volume] varchar(10), [volume_total_size] varchar(10), [volume_free_size] varchar(10), [Partition_Style] varchar(5), [volume_used] varchar(10), [threshold] varchar(10),
files_total_space varchar(10),
files_used_space varchar(10),
files_free_space varchar(10),
[threshold_maxfile] varchar(10),
files_max_space                varchar(10),
[recommended_extend_size_1] varchar(10),
[recommended_extend_size_2] varchar(10),
[recommended_extend_size_3] varchar(10))
end

 
if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0
begin
    if @over = 1
    begin
		insert into server_disk_state__9870
        select
        volume, volume_total_size, volume_free_size, style, [volume_used %], [threshold %],                files_total_space,files_used_space,files_free_space,
        @threshold_Maxfiles_pct, used_size_PCT_till_max_size files_max_space,
        [recommended_extend_size_1], [recommended_extend_size_2], [recommended_extend_size_3]
        from (
        select distinct
        volume_mount_point volume,
        master.dbo.numbersize(total_bytes ,'byte') volume_total_size,
        master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A') style,
        cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte')
        recommended_extend_size_1,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte')
        recommended_extend_size_2,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte')
        recommended_extend_size_3
        ,isnull(cast(used_size_PCT_till_max_size as decimal(10,2)),0) used_size_PCT_till_max_size
        from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
        left outer join @partition_table_style ps
        on v.volume_mount_point = ps.volume
        left outer join @max_table mt
        on v.volume_mount_point = mt.drive_letter
        where volume_mount_point in (select ltrim(rtrim(value)) from master.dbo.Separator(@vol,','))
        and cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) >= @threshold_pct)a
        inner join (select left(physical_name,3) disk_letter,
        master.dbo.numbersize(sum(size_n), 'mb') files_total_space,
        master.dbo.numbersize(sum(used_n), 'mb') files_used_space,
        master.dbo.numbersize(sum(free_n), 'mb') files_free_space
        from @db_size
        group by left(physical_name,3)) d
        on a.volume = d.disk_letter
        order by a.volume
    end
    else
    begin
		insert into server_disk_state__9870
		select
		volume, volume_total_size, volume_free_size, style, [volume_used %], [threshold %],                files_total_space,files_used_space,files_free_space,
		@threshold_Maxfiles_pct, used_size_PCT_till_max_size files_max_space,
		[recommended_extend_size_1], [recommended_extend_size_2], [recommended_extend_size_3]
		from (
		select distinct
		volume_mount_point volume,
		master.dbo.numbersize(total_bytes ,'byte') volume_total_size,
		master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A') style,
		cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte')
		recommended_extend_size_1,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte')
		recommended_extend_size_2,
		master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
		then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte')
		recommended_extend_size_3
		,isnull(cast(used_size_PCT_till_max_size as decimal(10,2)),0) used_size_PCT_till_max_size
		from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
		left outer join @partition_table_style ps
		on v.volume_mount_point = ps.volume
		left outer join @max_table mt
		on v.volume_mount_point = mt.drive_letter
		where volume_mount_point in (select ltrim(rtrim(value)) from master.dbo.Separator(@vol,',')))a
		inner join (select left(physical_name,3) disk_letter,
		master.dbo.numbersize(sum(size_n), 'mb') files_total_space,
		master.dbo.numbersize(sum(used_n), 'mb') files_used_space,
		master.dbo.numbersize(sum(free_n), 'mb') files_free_space
		from @db_size
		group by left(physical_name,3)) d
		on a.volume = d.disk_letter
		order by a.volume
    end
end
else
begin
    if @over = 0
    begin
        insert into server_disk_state__9870
        select
        volume, volume_total_size, volume_free_size, style, [volume_used %], [threshold %],                files_total_space,files_used_space,files_free_space,
        @threshold_Maxfiles_pct, used_size_PCT_till_max_size files_max_space,
        [recommended_extend_size_1], [recommended_extend_size_2], [recommended_extend_size_3]
        from (
        select
        volume_mount_point volume,
        master.dbo.numbersize(total_bytes ,'byte') volume_total_size,
        master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A') style,
        cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte')
        recommended_extend_size_1,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte')
        recommended_extend_size_2,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte')
        recommended_extend_size_3
        ,isnull(cast(used_size_PCT_till_max_size as decimal(10,2)),0) used_size_PCT_till_max_size
        from @dm_os_volume_stats v left outer join @partition_table_style ps
        on v.volume_mount_point = ps.volume
        left outer join @max_table mt
        on v.volume_mount_point = mt.drive_letter
        ) a inner join (select left(physical_name,3) disk_letter,
        master.dbo.numbersize(sum(size_n), 'mb') files_total_space,
        master.dbo.numbersize(sum(used_n), 'mb') files_used_space,
        master.dbo.numbersize(sum(free_n), 'mb') files_free_space
        from @db_size
        group by left(physical_name,3)) d
        on a.volume = d.disk_letter
        order by a.volume
    end
    else
    begin
        insert into server_disk_state__9870
        select
        volume, volume_total_size, volume_free_size, style, [volume_used %], [threshold %],                files_total_space,files_used_space,files_free_space,
        @threshold_Maxfiles_pct, used_size_PCT_till_max_size files_max_space,
        [recommended_extend_size_1], [recommended_extend_size_2], [recommended_extend_size_3]
        from (
        select
        volume_mount_point volume,
        master.dbo.numbersize(total_bytes ,'byte') volume_total_size,
        master.dbo.numbersize(available_bytes ,'byte') volume_free_size, isnull(ps.Partition_Style,'N/A') style,
        cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte')
        recommended_extend_size_1,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 2)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 2)) / 100 else 0 end ,'byte')
        recommended_extend_size_2,
        master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > (@threshold_pct - 5)
        then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - (@threshold_pct - 5)) / 100 else 0 end ,'byte')
        recommended_extend_size_3
        ,isnull(cast(used_size_PCT_till_max_size as decimal(10,2)),0) used_size_PCT_till_max_size
        from @dm_os_volume_stats v left outer join @partition_table_style ps
        on v.volume_mount_point = ps.volume
        left outer join @max_table mt
        on v.volume_mount_point = mt.drive_letter
        where cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct) a inner join (select left(physical_name,3) disk_letter,
        master.dbo.numbersize(sum(size_n), 'mb') files_total_space,
        master.dbo.numbersize(sum(used_n), 'mb') files_used_space,
        master.dbo.numbersize(sum(free_n), 'mb') files_free_space
        from @db_size
        group by left(physical_name,3)) d
        on a.volume = d.disk_letter
        order by a.volume 
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
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size   = ''2 TB'' then ''purple''
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size  != ''2 TB'' then ''red''
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red''
else ''green'' end'
when c.name = 'volume' then 'case
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size  = ''2 TB'' then ''purple'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''MBR'' and @volume_total_size != ''2 TB'' then ''red'' 
when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''red''
else ''green'' end'

when c.name = 'files_max_space' then 'case when cast(@files_max_space as float) > '+cast(@threshold_Maxfiles_pct as varchar)+' then ''red'' else ''green'' end'

when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 0 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end'
when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 2 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end'
when c.name = 'recommended_extend_size_'+cast(@threshold_pct - 5 as varchar) then 'case when cast(@volume_used as float) > '+cast(@threshold_pct as varchar)+' and @partition_style = ''GPT'' then ''yellow'' else ''white'' end'
when c.name = 'partition_style' then 'case when @partition_style = ''MBR'' then ''purple'' else ''green'' end'
else '' end+'+'+'''; '+
case
when c.name in ('volume_used','volume','partition_style','files_max_space') then 'color: white'
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

 

 
