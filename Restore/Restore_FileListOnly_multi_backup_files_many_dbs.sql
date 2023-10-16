use master
go
declare @backupfile varchar(max)
declare @backupfile_table table (id int identity(1,1), backupfile varchar(max))
insert into @backupfile_table (backupfile) values 
('\\npci2.d2fs.albilad.com\Datahub_Archive\Datahub_Golden Backup\Data_Hub_BAB_MIS\BAB_MIS_2018_Full_2023_03_07__09_31_am.bak'),
('\\npci2.d2fs.albilad.com\Datahub_Archive\Datahub_Golden Backup\Data_Hub_BAB_MIS\BAB_MIS_2019_Full_2023_03_07__09_41_am.bak'),
('\\npci2.d2fs.albilad.com\Datahub_Archive\Datahub_Golden Backup\Data_Hub_BAB_MIS\BAB_MIS_2020_Full_2023_03_08__16_15_am.bak'),
('\\npci2.d2fs.albilad.com\Datahub_Archive\Datahub_Golden Backup\Data_Hub_T24_2020-Full_Database_Backup_16_02_2023.bak'),
('\\npci2.d2fs.albilad.com\Datahub_Archive\D2DHBDBSQRWV1$DC2PRODDH\Data_Hub_T24_2019_ARC\FULL\D2DHBDBSQRWV1$DC2PRODDH_Data_Hub_T24_2019_ARC_FULL_20220923_100007.bak'),
('\\npci2.d2fs.albilad.com\Datahub_Archive\D2DHBDBSQRWV1$DC2PRODDH\Data_Hub_T24_2018_ARC\FULL\D2DHBDBSQRWV1$DC2PRODDH_Data_Hub_T24_2018_ARC_FULL_20220304_100005.bak')

declare 
@db_name			varchar(1000),
@add_name			varchar(100) = '_Archive',
@option_4_letter	varchar(3) = 'M:\',
@file_id			varchar(10) = 1,
@recovery			bit = 1,
@with_replace		bit = 1,
@show_size_require	bit = 0,
@option				int = 4,
--@option 1 = database already exist and you will restore with the same locations
--@option 3 = use the same location of the backup file - use this one for availability databases 
--@option 4 = manually change the location by using replace function 
@action				int = 3,
--@action 1 = print
--@action 2 = restore
--@action 3 = print + restore
@sql_fileonly varchar(max), @sql_headonly varchar(max), @sql varchar(max), @file_path varchar(3000)

declare db_cursor cursor fast_forward
for
select backupfile 
from @backupfile_table
order by id

open db_cursor 
fetch next from db_cursor into @backupfile
while @@FETCH_STATUS = 0
begin

set @sql = ''
set @sql_fileonly = 'RESTORE FILELISTONLY FROM DISK = '+''''+@backupfile+''''
set @sql_headonly = 'RESTORE HEADERONLY FROM DISK = '+''''+@backupfile+''''

set nocount on

create table #table_header (
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

create table #table (
	col01 varchar(500),col02 varchar(2500),col03 varchar(5),col04 varchar(100),col05 bigint,col06 bigint,
	col07 varchar(max),col08 varchar(max),col09 varchar(max),col10 varchar(max),col11 varchar(max),
	col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),col16 varchar(max),
	col17 varchar(max),col18 varchar(max),col19 varchar(max),col20 varchar(max),col21 varchar(max),
	col22 varchar(max))

if (select cast(master.[dbo].[vertical_array](cast(value_data as varchar(500)),'.',1) as int) from sys.dm_server_registry where cast(value_name as varchar(500)) = 'CurrentVersion') >= 13
begin
insert into #table (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
					col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
					col21,col22)
exec(@sql_fileonly) 
insert into #table_header  (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
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
insert into #table (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
					col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
					col21)
exec(@sql_fileonly) 
insert into #table_header  (col01,col02,col03,col04,col05,col06,col07,col08,col09,col10,
							col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,
							col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,
							col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,
							col41,col42,col43,col44,col45,col46,col47,col48,col49,col50,
							col51,col52,col53,col54,col55,col56)
exec(@sql_headonly) 
end

select @db_name = col10+@add_name from #table_header

select instance_version, backup_file_version,
case when cast(instance_version as int) < backup_file_version then 'backup file can''t be restore on this instance' else 'Okay' end comment,
@option [option], case @option 
when 1 then 'database already exist and you will restore with the same locations'
when 2 then 'use the pathes that you have on table restore_location_groups'
when 3 then 'use the same location of the backup file - use this one for availability databases'
when 4 then 'manually change the location by using replace function'
end options_explanation,
col10 [database_name]
from (
select col10,
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
from #table_header)a

if @show_size_require = 1
begin
select col01 logical_name, col02 physical_name,left(col02,1) disk_letter,
case when row_number() over(partition by left(col02,1) order by left(col02,1)) = 1 then master.dbo.numbersize(sum(col05) over(partition by left(col02,1) order by left(col02,1)),'byte') else '' end disk_required_space,  
dense_rank() over(order by left(col02,1)) DRank, col03 type, col04 file_group, master.dbo.numbersize(col05,'byte') file_size , 
case when row_number() over(order by left(col02,1)) = 1 then master.dbo.numbersize(sum(col05) over(),'byte') else '' end total_file_size 
from #table
order by disk_letter

end

if @option = 1
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from #table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+col01+''''+' To '+''''+mf.physical_name+''''+','
from #table t inner join sys.master_files mf
on t.col01 = mf.name
where database_id = db_id(@db_name)
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

if @action = 1
begin
print(@sql)
end
else
if @action = 2
begin
exec(@sql)
end
else
if @action = 3
begin
print(@sql)
exec(@sql)
end

end
else
if @option = 3
begin

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from #table_header
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
from #table)a)aa inner join #table bb
on aa.[filegroup_id] = bb.col15
and aa.drive = left(bb.col02,1))cc)t 
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

if @action = 1
begin
print(@sql)
end
else
if @action = 2
begin
exec(@sql)
end
else
if @action = 3
begin
print(@sql)
exec(@sql)
end

end
else
if @option = 4
begin

declare path_cursor cursor fast_forward
for
select distinct replace(reverse(substring(reverse(col02),charindex('\',reverse(col02)), len(reverse(col02)))),left(reverse(substring(reverse(col02),charindex('\',reverse(col02)), len(reverse(col02)))),3),@option_4_letter) 
from #table

open path_cursor
fetch next from path_cursor into @file_path
while @@FETCH_STATUS = 0
begin

exec [master].[dbo].[sp_check_dir] @file_path, @action

fetch next from path_cursor into @file_path
end
close path_cursor
deallocate path_cursor

select @sql = isnull(@sql,'') +'
'+syntax_text
from (
select 'RESTORE DATABASE ['+case when @db_name = 'default' then col10 else @db_name end+'] FROM  DISK = N'+''''+@backupfile+''''+' WITH  FILE = '+col06+',' syntax_text
from #table_header
where col06 = @file_id 
union all
select 
'MOVE '+''''+col01+''''+' To '+''''+replace(col02,left(col02,3),@option_4_letter)+''''+','
from #table
union all
select 'NOUNLOAD, '+ 
case when @recovery = 0 then 'NORECOVERY' else 'RECOVERY' end+', '+
case when @with_replace = 1 then 'REPLACE' else '' end+
', STATS = 1')a

if @action = 1
begin
print(@sql)
print('GO')
end
else
if @action = 2
begin
exec(@sql)
end
else
if @action = 3
begin
print(@sql)
exec(@sql)
end
end
set nocount off

drop table #table_header
drop table #table

fetch next from db_cursor into @backupfile
end
close db_cursor 
deallocate db_cursor 



