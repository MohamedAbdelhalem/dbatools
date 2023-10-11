use master
go
if object_id('[dbo].[database_size]') is not null
begin
drop procedure [dbo].[database_size]
end
go
create --or alter 
Procedure [dbo].[database_size](
@databases			varchar(max) = '*',
@with_system		bit = 0,
@threshold_pct		int = 85,
@volumes			varchar(300) = '*',
@where_size_gt		int = 0,
@datafile			varchar(10) = '*',
@report				int = 1,
@over_threshold		bit = 0,
@sorted_by			varchar(10) = 'free',
@shrink_data		int = 0,
@force_shrink_log	int = 0,
@free				int = 10
)
as
begin
declare @table_databases table (database_name varchar(500))
declare @loop int = 0

declare @svrName varchar(255), @sql varchar(400)
declare @output table (output_text varchar(255))
declare @dm_os_volume_stats table (volume_mount_point varchar(10), total_bytes float, available_bytes float)

set @svrName = @@SERVERNAME
set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@svrName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity+''|''+$_.freespace}"'

insert @output
EXEC xp_cmdshell @sql
declare @db varchar(max), @vol varchar(300), @file_0 int, @file_1 int
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
	if @databases like '%*%'
	begin
		while @loop < (select count(*) from master.dbo.Separator(@databases,','))
		begin
		set @loop += 1
		insert into @table_databases
		select name from sys.databases where name like (select replace(ltrim(rtrim(value)),'*','%') from master.dbo.Separator(@databases,',') where id = @loop )
		end
		set @databases = null
		select @databases = isnull(@databases + ',','') + database_name 
		from @table_databases
		order by database_name
		set @db = @databases
	end
	else
	begin
		set @db = @databases
	end
end


if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0
begin

insert into @db_size (database_name, file_type, [file_id], logical_name, physical_name, size_n, size, growth_n, growth, used_n, used, free_n, free, max_size)
exec sp_MSforeachdb '
use [?]
select db_name(db_id()), case type when 0 then 1 else 2 end file_type, file_id, name, physical_name, 
(cast(size as float) / cast(1024 as float)) * 8.0 size_,
master.dbo.numbersize((cast(size as float) / cast(1024 as float)) * 8.0,''mb'') size,
(cast(growth as float) / cast(1024 as float)) * 8.0 growth_,
master.dbo.numbersize((cast(growth as float)) * 8.0,''kb'') growth,
(cast(fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 used_,
master.dbo.numbersize((cast(fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 ,''Mb'') used_space,
(cast(size - fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0 free_,
master.dbo.numbersize((cast(size - fileproperty(name, ''spaceused'') as float) / cast(1024 as float)) * 8.0,''Mb'') free_space,
case when cast(max_size as float) = -1 then ''unlimited'' collate Arabic_100_CI_AS else master.dbo.numbersize((cast(max_size as float) / cast(1024 as float)) * 8.0,''Mb'') end max_size
from sys.database_files'

end
else
begin

insert into @db_size (database_name, file_type, [file_id], logical_name, physical_name, size_n, size, growth_n, growth)
exec('
select db_name(db_id()), case type when 0 then 1 else 2 end file_type, file_id, name, physical_name, 
(cast(size as float) / cast(1024 as float)) * 8.0 size_,
master.dbo.numbersize((cast(size as float) / cast(1024 as float)) * 8.0,''mb'') size,
(cast(growth as float) / cast(1024 as float)) * 8.0 growth_,
master.dbo.numbersize((cast(growth as float)) * 8.0,''kb'') growth
from sys.database_files')

select * from  sys.database_files

insert into @dm_os_volume_stats
select 
master.dbo.virtical_array(output_text,'|',1), 
cast(master.dbo.virtical_array(output_text,'|',2) as float), 
cast(master.dbo.virtical_array(output_text,'|',3) as float)
from @output 
where output_text is not null 
and output_text not like '%\\?\Volume%'

end

if @volumes = '*'
begin
	select @vol =  isnull(@vol+', ','') + volume_mount_point from (select distinct v.volume_mount_point from sys.master_files db cross apply sys.dm_os_volume_stats(db.database_id,db.file_id) v)a

end
else
begin
	set @vol = @volumes
end

if @datafile = 'data'
begin
set @file_0 = 1
set @file_1 = 1
end
else if @datafile = 'log'
begin
set @file_0 = 2
set @file_1 = 2
end
else if @datafile = '*'
begin
set @file_0 = 1
set @file_1 = 2
end

if @report in (1,2)
begin
if @over_threshold = 0
begin
	select database_name, file_id, file_type, logical_name, volume, volume_total_size, volume_free_size, [threshold %], [volume_used %], [file % of disk], recommended_extend_size, 
	total_dbf_size,
	total_dbf_used,
	cast(cast(total_dbf_used_n as float) / cast(total_dbf_size_n as float) * 100.0 as numeric(10,2)) pct_total_dbf_used,
	total_dbf_free,
	cast(cast(total_dbf_free_n as float) / cast(total_dbf_size_n as float) * 100.0 as numeric(10,2)) pct_total_dbf_free,
	case when file_type = 2 then log_wait_reuse else '' end log_wait_reuse,
	physical_name, size, growth, used, free, max_size,sum_file_id,
	case 
	when file_type = 2 and log_wait_reuse = 'NOTHING' then 
	'USE ['+database_name+']
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and log_wait_reuse = 'OLDEST_PAGE' then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and log_wait_reuse = 'CHECKPOINT' then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and @force_shrink_log = 1 then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 1 and @shrink_data = 1 then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + @free as varchar(10)) +')' 
	else '' end shrink_script
	from (
	select
	id, database_name, db.log_reuse_wait_desc log_wait_reuse, file_type, s.[file_id], sum(s.file_id) over(partition by database_name order by database_name) sum_file_id, logical_name, 
	volume_mount_point volume,
	master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
	master.dbo.numbersize(available_bytes ,'byte') volume_free_size, @threshold_pct [threshold %],
	cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %],
	cast((size_n / (total_bytes/1024.0/1024.0) * 100) as decimal(36,2)) [file % of disk], 
	master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
	then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
	recommended_extend_size,
	master.dbo.numbersize(sum(size_n) over(partition by database_name order by database_name),'MB') total_dbf_size,
	master.dbo.numbersize(sum(used_n) over(partition by database_name order by database_name),'MB') total_dbf_used,
	master.dbo.numbersize(sum(free_n) over(partition by database_name order by database_name),'MB') total_dbf_free,
	sum(size_n) over(partition by database_name order by database_name) total_dbf_size_n,
	sum(used_n) over(partition by database_name order by database_name) total_dbf_used_n,
	sum(free_n) over(partition by database_name order by database_name) total_dbf_free_n,
	physical_name, size, growth, used, free, max_size, size_n, used_n, free_n
	from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
	left outer join sys.databases db
	on s.database_name = db.name
	where database_name in (select ltrim(rtrim(value)) from master.dbo.Separator(@db,','))
	and volume_mount_point in (select case 
										when ltrim(rtrim(value)) like '%:\' then ltrim(rtrim(value))  
										when ltrim(rtrim(value)) like '%:'  then ltrim(rtrim(value))+'\'  
										when ltrim(rtrim(value)) NOT like ':' then ltrim(rtrim(value))+':\'
										END
										from master.dbo.Separator(@vol,','))
	and file_type between @file_0 and @file_1
	)a
	where total_dbf_size_n > @where_size_gt
	order by case @sorted_by 
				when 'size' then total_dbf_size_n 
				when 'used' then total_dbf_used_n 
				when 'free' then total_dbf_free_n end desc, case @sorted_by 
																when 'size' then size_n 
																when 'used' then used_n 
																when 'free' then free_n end desc, 
				database_name, physical_name
end
else
begin
	select database_name, file_id, file_type, logical_name, volume, volume_total_size, volume_free_size, [threshold %], [volume_used %], [file % of disk], recommended_extend_size, 
	total_dbf_size,
	total_dbf_used,
	cast(cast(total_dbf_used_n as float) / cast(total_dbf_size_n as float) * 100.0 as numeric(10,2)) pct_total_dbf_used,
	total_dbf_free,
	cast(cast(total_dbf_free_n as float) / cast(total_dbf_size_n as float) * 100.0 as numeric(10,2)) pct_total_dbf_free,
	case when file_type = 2 then log_wait_reuse else '' end log_wait_reuse,
	physical_name, size, growth, used, free, max_size,sum_file_id,
	case 
	when file_type = 2 and log_wait_reuse = 'NOTHING' then 
	'USE ['+database_name+']
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and log_wait_reuse = 'OLDEST_PAGE' then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and log_wait_reuse = 'CHECKPOINT' then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 2 and @force_shrink_log = 1 then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + 10 as varchar(10)) +')' 
	when file_type = 1 and @shrink_data = 1 then 
	'USE ['+database_name+']
	CHECKPOINT
	DBCC SHRINKFILE (N'+''''+logical_name+''''+' , '+cast(used_n + @free as varchar(10)) +')' 
	else '' end shrink_script
	from (
	select
	id, database_name, db.log_reuse_wait_desc log_wait_reuse, file_type, s.[file_id], sum(s.file_id) over(partition by database_name order by database_name) sum_file_id, logical_name, 
	volume_mount_point volume,
	master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
	master.dbo.numbersize(available_bytes ,'byte') volume_free_size, @threshold_pct [threshold %],
	cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %],
	cast((size_n / (total_bytes/1024.0/1024.0) * 100) as decimal(36,2)) [file % of disk], 
	master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
	then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
	recommended_extend_size,
	master.dbo.numbersize(sum(size_n) over(partition by database_name order by database_name),'MB') total_dbf_size,
	master.dbo.numbersize(sum(used_n) over(partition by database_name order by database_name),'MB') total_dbf_used,
	master.dbo.numbersize(sum(free_n) over(partition by database_name order by database_name),'MB') total_dbf_free,
	sum(size_n) over(partition by database_name order by database_name) total_dbf_size_n,
	sum(used_n) over(partition by database_name order by database_name) total_dbf_used_n,
	sum(free_n) over(partition by database_name order by database_name) total_dbf_free_n,
	physical_name, size, growth, used, free, max_size, size_n, used_n, free_n
	from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
	inner join sys.databases db
	on s.database_name = db.name
	where database_name in (select ltrim(rtrim(value)) from master.dbo.Separator(@db,','))
	and volume_mount_point in (select ltrim(rtrim(value)) from master.dbo.Separator(@vol,','))
	and file_type between @file_0 and @file_1
	)a
	where total_dbf_size_n > @where_size_gt
	and [volume_used %] > @threshold_pct
	order by case @sorted_by 
				when 'size' then total_dbf_size_n 
				when 'used' then total_dbf_used_n 
				when 'free' then total_dbf_free_n end desc, case @sorted_by 
																when 'size' then size_n 
																when 'used' then used_n 
																when 'free' then free_n end desc, 
				database_name, physical_name
end
end

if @report in (2,3)
begin
	if (select count(*) from sys.database_mirroring where database_id > 4 and mirroring_role = 2 and mirroring_guid is not null) = 0
	begin
		if @over_threshold = 0
		begin
			select distinct 
			volume_mount_point volume, v.logical_volume_name,
			master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
			master.dbo.numbersize(available_bytes ,'byte') volume_free_size,
			cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %], 

			case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) < @threshold_pct then master.dbo.numbersize(available_bytes - (total_bytes - ((total_bytes * @threshold_pct) / 100)),'byte') else '' end max_size_threshold,

			master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
			then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
			recommended_extend_size,
			count(*) over(partition by volume_mount_point) data_files,
			master.dbo.numbersize(sum(s.size_n)	over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') data_files_size,
			master.dbo.numbersize(sum(s.free_n) over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') data_files_free,
			master.dbo.numbersize((cast(v.total_bytes as float)/1024.0/1024.0) - (cast(v.available_bytes as float)/1024.0/1024.0) - sum(s.size_n) 
			over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') used_non_database
			from @db_size s cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
			where volume_mount_point in (select case 
										when ltrim(rtrim(value)) like '%:\' then ltrim(rtrim(value))  
										when ltrim(rtrim(value)) like '%:'  then ltrim(rtrim(value))+'\'  
										when ltrim(rtrim(value)) NOT like ':' then ltrim(rtrim(value))+':\'
										END
										from master.dbo.Separator(@vol,','))
			order by volume
		end
		else
		begin
			select distinct 
			volume_mount_point volume,v.logical_volume_name,
			master.dbo.numbersize(v.total_bytes ,'byte') volume_total_size, 
			master.dbo.numbersize(v.available_bytes ,'byte') volume_free_size,
			cast(100 - cast(v.available_bytes as float)/cast(v.total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
			case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) < @threshold_pct then master.dbo.numbersize(available_bytes - (total_bytes - ((total_bytes * @threshold_pct) / 100)),'byte') else '' end max_size_threshold,
			master.dbo.numbersize(case when cast(100 - cast(v.available_bytes as float)/cast(v.total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
			then v.total_bytes * (cast(100 - cast(v.available_bytes as float)/cast(v.total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
			recommended_extend_size,
			count(*) over(partition by volume_mount_point) data_files,
			master.dbo.numbersize(sum(s.size_n)	over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') data_files_size,
			master.dbo.numbersize(sum(s.free_n) over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') data_files_free,
			master.dbo.numbersize((cast(v.total_bytes as float)/1024.0/1024.0) - (cast(v.available_bytes as float)/1024.0/1024.0) - sum(s.size_n) 
			over(partition by left(s.physical_name,1) order by left(s.physical_name,1)),'mb') used_non_database
			from @db_size s 
			cross apply sys.dm_os_volume_stats(db_id(database_name), [file_id]) v
			where volume_mount_point in (select case 
										when ltrim(rtrim(value)) like '%:\' then ltrim(rtrim(value))  
										when ltrim(rtrim(value)) like '%:'  then ltrim(rtrim(value))+'\'  
										when ltrim(rtrim(value)) NOT like ':' then ltrim(rtrim(value))+':\'
										END
										from master.dbo.Separator(@vol,','))
			and cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
			order by volume
		end
	end
	else
	begin
		if @over_threshold = 0
		begin
			select 
			volume_mount_point volume,
			master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
			master.dbo.numbersize(available_bytes ,'byte') volume_free_size,
			cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
			master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
			then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
			recommended_extend_size
			from @dm_os_volume_stats v
			order by volume
		end
		else
		begin
			select 
			volume_mount_point volume,
			master.dbo.numbersize(total_bytes ,'byte') volume_total_size, 
			master.dbo.numbersize(available_bytes ,'byte') volume_free_size,
			cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) [volume_used %], @threshold_pct  [threshold %],
			master.dbo.numbersize(case when cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct 
			then total_bytes * (cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) - @threshold_pct) / 100 else 0 end ,'byte') 
			recommended_extend_size
			from @dm_os_volume_stats v
			where cast(100 - cast(available_bytes as float)/cast(total_bytes as float) * 100.0 as decimal(5,2)) > @threshold_pct
			order by volume
		end
	end
end
end
go

