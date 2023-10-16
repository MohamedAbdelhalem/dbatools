declare @full_backup_file varchar(max) = '\\npci2.d2fs.albilad.com\DBTEMP\Temp Weekly Backup\D2T24DBSQIWV4\T24PROD_UAT\FULL\T24PROD_UAT__10_38_5_65_FULL_2022_08_21_1145_am.bak'
declare @severname varchar(255)--, @sql varchar(400)
declare @output table (output_text varchar(255))
declare @dm_os_volume_stats table (volume_mount_point varchar(10), total_bytes float, available_bytes float)
declare @sql varchar(max), @sql_host varchar(max), @sql_power varchar(max)
set @sql = 'restore filelistonly from disk = '+''''+@full_backup_file+''''

declare @filelistonly_2016 table (
logical_name varchar(500),
physical_name varchar(max),
type varchar(5),
filegroup varchar(100),
file_size bigint,
used_size bigint,
file_id int,
col01 varchar(max),col02 varchar(max),col03 varchar(max),col04 varchar(max),col05 varchar(max),col06 varchar(max),col07 varchar(max),
col08 varchar(max),col09 varchar(max),col10 varchar(max),col11 varchar(max),col12 varchar(max),col13 varchar(max),col14 varchar(max))
declare @filelistonly_2017 table (
logical_name varchar(500),
physical_name varchar(max),
type varchar(5),
filegroup varchar(100),
file_size bigint,
used_size bigint,
file_id int,
col01 varchar(max),col02 varchar(max),col03 varchar(max),col04 varchar(max),col05 varchar(max),col06 varchar(max),col07 varchar(max),
col08 varchar(max),col09 varchar(max),col10 varchar(max),col11 varchar(max),col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max))

insert into @filelistonly_2017
exec(@sql)

set @sql_host = 'xp_cmdshell ''hostname'''
insert into @output
exec (@sql_host)

select top 1 @severname = output_text from @output where output_text is not null
set @sql_power = 'xp_cmdshell ''powershell.exe -c "Get-WmiObject -ComputerName ''' + QUOTENAME(@severname,'''') + ''' -Class Win32_Volume -Filter ''''DriveType = 3'''' | select name,capacity,freespace | foreach{$_.name+''''|''''+$_.capacity+''''|''''+$_.freespace}"'''
print(@sql_power)

--exec xp_cmdshell 'powershell.exe -c "Get-WmiObject -ComputerName ''D2T24DBSQUWV5'' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity+''|''+$_.freespace}"'

insert @output
EXEC ( @sql_power)

declare @db varchar(1000), @vol varchar(300), @file_0 int, @file_1 int
declare @db_size table (id int identity(1,1), 
database_name varchar(300), file_type int, [file_id] int, logical_name varchar(1000), physical_name varchar(2000), 
size_n int, size varchar(50), growth_n int, growth varchar(50), used_n int, used varchar(50), free_n int, free varchar(50), max_size varchar(50))

insert into @dm_os_volume_stats
select 
master.dbo.virtical_array(output_text,'|',1), 
cast(master.dbo.virtical_array(output_text,'|',2) as float), 
cast(master.dbo.virtical_array(output_text,'|',3) as float)
from @output 
where output_text is not null 
and output_text not like '%\\?\Volume%'
and output_text like '%:\%'

select volume_mount_point, isnull(volume_backup, 'ignore') volume_backup,
master.dbo.numberSize(total_bytes,'byte') volume_total_size, 
master.dbo.numberSize(file_size,'byte') file_total_size, 
master.dbo.numberSize(available_bytes,'byte') volume_free_size, logical_name, physical_name
from @dm_os_volume_stats v full outer join (select left(physical_name,3) volume_backup, * from @filelistonly_2017) t
on v.volume_mount_point = t.volume_backup


select volume_mount_point, isnull(volume_backup, 'ignore') volume_backup,
master.dbo.numberSize(total_bytes,'byte') volume_total_size, 
master.dbo.numberSize(total_file_size,'byte') total_files_size, 
master.dbo.numberSize(available_bytes,'byte') volume_free_size
from @dm_os_volume_stats v full outer join (select left(physical_name,3) volume_backup, sum(file_size) total_file_size from @filelistonly_2017 group by left(physical_name,3)) t
on v.volume_mount_point = t.volume_backup



--USE [master]
--go
--RESTORE DATABASE [T24PROD_MASTER] 
--FROM  DISK = N'\\npci2.d2fs.albilad.com\DBTEMP\Temp Weekly Backup\D2T24DBSQIWV4\T24PROD_UAT\FULL\T24PROD_UAT__10_38_5_65_FULL_2022_08_21_1145_am.bak' WITH  FILE = 1,  
--MOVE N'T24PROD_data' TO N'J:\Data\T24PRODdata.mdf',  
--MOVE N'T24PROD1_data' TO N'J:\Data\T24PRODdata1.ndf',  
--MOVE N'T24PROD2_data' TO N'J:\Data\T24PRODdata2.ndf',  
--MOVE N'T24PROD3_data' TO N'J:\Data\T24PRODdata3.ndf',  
--MOVE N'T24PROD4_data' TO N'J:\Data\T24PRODdata4.ndf',  
--MOVE N'T24PROD5_data' TO N'K:\Data\T24PRODdata5.ndf',  
--MOVE N'T24PROD6_data' TO N'K:\Data\T24PRODdata6.ndf',  
--MOVE N'T24PROD7_data' TO N'K:\Data\T24PRODdata7.ndf',  
--MOVE N'T24PROD8_data' TO N'K:\Data\T24PRODdata8.ndf',  
--MOVE N'T24PROD9_data' TO N'G:\Data\T24PRODdata9.ndf',  
--MOVE N'T24PROD10_data' TO N'G:\Data\T24PRODdata10.ndf',  
--MOVE N'T24PROD11_data' TO N'G:\Data\T24PRODdata11.ndf',  
--MOVE N'T24PROD12_data' TO N'G:\Data\T24PRODdata12.ndf',  
--MOVE N'T24PROD13_data' TO N'H:\Data\T24PRODdata13.ndf',  
--MOVE N'T24PROD14_data' TO N'H:\Data\T24PRODdata14.ndf',  
--MOVE N'T24PROD15_data' TO N'H:\Data\T24PRODdata15.ndf',  
--MOVE N'T24PROD16_data' TO N'H:\Data\T24PRODdata16.ndf',  
--MOVE N'T24PROD_ARCH' TO N'E:\Data\T24PRODdata18.ndf',  
--MOVE N'T24PROD_log' TO N'F:\Data\T24PRODlog.ldf',  
--NOUNLOAD,  REPLACE, STATS = 1

--select * from sys.master_files

--GO

