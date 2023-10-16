use master
go
ALTER PROCEDURE [dbo].[sp_restore_backup_file](
@backupfile			varchar(max) = N'\\npci2.d2fs.albilad.com\DB_Replication_Temp\BABDB-Full Database Backup.bak',
@db_name			varchar(1000) = 'Default',
@file_id			varchar(10) = 1,
@recovery			bit = 0,
@with_replace		bit = 1,
@option				int = 3,
--@option 1 = database already exist and you will restore with the same locations
--@option 2 = use the pathes that you have on table restore_location_groups
--@option 3 = use the same location of the backup file - use this one for availability databases 
--@option 4 = manually change the location by using replace function 
@show_size_require	bit = 0,
@action				int = 3
--@action 1 = print
--@action 2 = restore
--@action 1 = print + restore
)
as
begin
declare
@sql_fileonly		varchar(max) = 'RESTORE FILELISTONLY FROM DISK = '+''''+@backupfile+'''',
@sql_headonly		varchar(max) = 'RESTORE HEADERONLY FROM DISK = '+''''+@backupfile+''''

set nocount on
declare @sql varchar(max)
declare @table_header table (
	col01 varchar(500),col02 varchar(500),col03 varchar(500),col04 varchar(500),col05 varchar(500),col06 varchar(5),
	col07 varchar(max),col08 varchar(100),col09 varchar(500),col10 varchar(500),col11 bigint,
	col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),col16 varchar(max),
	col17 varchar(max),col18 datetime,col19 varchar(max),col20 varchar(max),col21 varchar(max),
	col22 varchar(max),col23 varchar(max),col24 varchar(max),col25 varchar(max),col26 varchar(max),
	col27 varchar(max),col28 varchar(max),col29 varchar(max),col30 varchar(max),col31 varchar(max),
	col32 varchar(max),col33 varchar(max),col34 varchar(max),col35 varchar(max),col36 varchar(max),
	col37 varchar(max),col38 varchar(max),col39 varchar(max),col40 varchar(max),col41 varchar(max),
	col42 varchar(max),col43 varchar(max),col44 varchar(max),col45 varchar(max),col46 varchar(max),
	col47 varchar(100),col48 varchar(max),col49 varchar(max),col50 varchar(100),col51 varchar(max),
	col52 varchar(max),col53 varchar(max),col54 varchar(max),col55 varchar(max),col56 varchar(max))

declare @table table (
	col01 varchar(500),col02 varchar(2500),col03 varchar(5),col04 varchar(100),col05 bigint,col06 bigint,
	col07 varchar(max),col08 varchar(max),col09 varchar(max),col10 varchar(max),col11 varchar(max),
	col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),col16 varchar(max),
	col17 varchar(max),col18 varchar(max),col19 varchar(max),col20 varchar(max),col21 varchar(max),
	col22 varchar(max))

if (select cast(master.[dbo].[vertical_array](cast(value_data as varchar(500)),'.',1) as int) from sys.dm_server_registry where cast(value_name as varchar(500)) = 'CurrentVersion') >= 13
begin
insert into @table (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
					col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
					col21,col22)
exec(@sql_fileonly) 
insert into @table_header  (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
							col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
							col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,
							col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,
							col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,
							col51,col52,col53,col54,col55,col56)
exec(@sql_headonly) 
end
else
if (select cast(master.[dbo].[vertical_array](cast(value_data as varchar(500)),'.',1) as int) from sys.dm_server_registry where cast(value_name as varchar(500)) = 'CurrentVersion') = 12
begin
insert into @table (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
					col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
					col21)
exec(@sql_fileonly) 
insert into @table_header  (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
							col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
							col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,
							col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,
							col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,
							col51,col52,col53,col54,col55,col56)
exec(@sql_headonly) 
end

declare 
@exception_flag bit,
@exception_desc varchar(500)

select 
@exception_flag = case when cast(instance_version as int) < backup_file_version then 1 else 0 end,
@exception_desc = case when cast(instance_version as int) < backup_file_version then 'Lower version, backup file can''t be restore on this instance' else 'Okay' end
from (
select 
master.dbo.vertical_array(cast(@@version as varchar(1000)),' ',4) instance_version, case 
when col11 between 406 and 408	then 6
when col11 = 515				then 7
when col11 = 539				then 2000
when col11 between 611 and 612	then 2005
when col11 = 655				then 2008
when col11 between 684 and 706	then 2012
when col11 = 782				then 2014
when col11 = 852				then 2016
when col11 between 868 and 869	then 2017
when col11 between 895 and 904	then 2019
when col11 >= 950				then 2022
end backup_file_version, col11
from @table_header)a

if @show_size_require = 1
begin
select 
logical_name, physical_name, a.disk_letter, 
case disk_part_id when 1 then disk_required_space else '' end disk_required_space,
type, filegroup_name, file_size, 
case disks_part_id when 1 then total_file_size else '' end total_file_size
from (
select 
col01 logical_name, col02 physical_name, 
row_number() over(partition by left(col02,1) order by left(col02,1)) disk_part_id, left(col02,1) disk_letter, 
row_number() over(order by col02) disks_part_id,
col03 type, col04 filegroup_name, 
master.dbo.numbersize(col05,'byte') file_size,
master.dbo.numbersize(sum(col05) over(),'byte') total_file_size
from @table)a inner join (select 
left(col02,1) disk_letter, master.dbo.numbersize(sum(col05),'byte') disk_required_space
from @table
group by left(col02,1))d
on a.disk_letter = d.disk_letter
order by disks_part_id, disk_part_id
end


if @option = 1
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from @table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+col01+''''+' To '+''''+mf.physical_name+''''+','
from @table t inner join sys.master_files mf
on t.col01 = mf.name
where database_id = db_id(@db_name)
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

end
else
if @option = 2
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from @table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+logical_name+''''+' To '+''''+a.server_locations+backup_file_locations+''''+','
--t.[filegroup_id], t.drive, 
--logical_name, backup_file_locations, a.server_locations, physical_datafile_name
from (
select cc.id, cc.[filegroup_id], cc.drive, cc.col01 logical_name,
reverse(substring(reverse(cc.col02), 1, charindex('\',reverse(cc.col02))-1)) physical_datafile_name,
reverse(substring(reverse(cc.col02), charindex('\',reverse(cc.col02)),len(reverse(cc.col02)))) backup_file_locations
from (
select aa.id, aa.drive, col01, [filegroup_id], bb.col02
from (
select row_number() over(partition by [filegroup_id] order by [filegroup_id]) id, *
from (
select  distinct
left(col02,1) drive,col15 [filegroup_id]
from @table)a)aa inner join @table bb
on aa.[filegroup_id] = bb.col15
and aa.drive = left(bb.col02,1))cc)t inner join (select 
							row_number() over(partition by master.dbo.vertical_array(s.value,'-',1) order by id) id, 
							master.dbo.vertical_array(s.value,'-',1) [filegroup_id], 
							master.dbo.vertical_array(s.value,'-',2) [server_locations] 
							from master.dbo.restore_loction_groups lg cross apply master.dbo.Separator(lg.directorys_map,';')s)a
on t.[filegroup_id] = a.[filegroup_id]
and t.id = a.id
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

end
else
if @option = 3
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from @table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+logical_name+''''+' To '+''''+physical_datafile_name+''''+','
from (
select cc.id, cc.[filegroup_id], cc.drive, cc.col01 logical_name,col02 physical_datafile_name
from (
select aa.id, aa.drive, col01, [filegroup_id], bb.col02
from (
select row_number() over(partition by [filegroup_id] order by [filegroup_id]) id, *
from (
select  distinct
left(col02,1) drive,col15 [filegroup_id]
from @table)a)aa inner join @table bb
on aa.[filegroup_id] = bb.col15
and aa.drive = left(bb.col02,1))cc)t 
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

end
else
if @option = 4
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from @table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+col01+''''+' To '+''''+replace(replace(replace(replace(col02,'E:\','N:\'),'F:\','T:\'),'H:\','L:\'),'G:\','M:\')+''''+','
from @table
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

end

if @action = 1 and @exception_flag = 0 and @show_size_require = 0
begin
print(@sql)
end
else
if @action = 2 and @exception_flag = 0 and @show_size_require = 0
begin
exec(@sql)
end
else
if @action = 3 and @exception_flag = 0 and @show_size_require = 0
begin
print(@sql)
exec(@sql)
end
else 
if @exception_flag = 1
begin
print(@exception_desc)
end

set nocount off

end
go

exec [dbo].[sp_restore_backup_file]
@backupfile			= N'\\npci2.d2fs.albilad.com\DB_Replication_Temp\3shmawy\BABmfreportsdbPROD_2023_02_12__11_00_AM__Full.bak',
@db_name			= 'Default',
@file_id			= 1,
@recovery			= 0,
@with_replace		= 1,
@option				= 3,
--@option 1 = database already exist and you will restore with the same locations
--@option 2 = use the pathes that you have on table restore_location_groups
--@option 3 = use the same location of the backup file - use this one for availability databases 
--@option 4 = manually change the location by using replace function 
@show_size_require	= 1,
@action				= 1
--@action 1 = print
--@action 2 = restore
--@action 3 = print + restore
