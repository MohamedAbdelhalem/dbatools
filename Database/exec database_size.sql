declare @database_name_like varchar(300) = 'bab_mis'
declare @dbs varchar(max)
select @dbs = isnull(@dbs+',','')+name
from sys.databases
where name like '%'+@database_name_like+'%'

Exec [master].[dbo].[database_size]
@databases		= 'T24PROD_UAT',
--@databases		= @dbs, 
@with_system	= 1,
@threshold_pct	= 85,
--@volumes		= 'O',
@datafile		= 'data',
@report			= 3,
@sorted_by      = 'size'
--@shrink_data	= 0,
--@free			= 100

exec [Data_Hub_Cortex_2021].dbo.sp_table_size '*',''

Exec [master].[dbo].[database_size]
@databases		= '*',
--@databases		= @dbs, 
@with_system	= 1,
@threshold_pct	= 80,
@volumes		= '*',
--@datafile		= 'data',
@report			= 3,
@sorted_by      = 'size'
--@shrink_data	= 0,
--@free			= 100



L to R
Data_Hub_SMS_GW_2019	Data_Hub_SMS_GW_2019	L:\MSSQL_DATA\Data_Hub_SMS_GW_2019.mdf	221.32 GB

--DBCC TRACEON(4029,-1)
--DBCC TRACEOFF(4029,-1)

----old version under 2012
--declare @table table (
--database_name varchar(500), logical_name varchar(500), file_type varchar(20), disk_letter char(3), Physical_name varchar(3000), file_total_space varchar(30), file_used_space varchar(30), file_free_space varchar(30))
--insert into @table
--exec sp_MSforeachdb USE [?]
--select db_name(database_id) db_name, 
--name, 
--case type_desc when ROWS then data when log then log end type_desc,
--left(physical_name,3) disk_letter,
--physical_name, 
--master.dbo.numberSize(size * 8.0,kb) file_total_space, 
--master.dbo.numberSize(FILEPROPERTY(name, spaceused) *8.0,kb) file_used_space, 
--master.dbo.numberSize(size * 8.0 -FILEPROPERTY(name, spaceused)*8.0,kb) file_free_space
--from sys.master_files
--where database_id = db_id()

--select * 
--from @table
--where disk_letter = C:\
--order by master.dbo.ToNumberSize(file_free_space) desc
--exec [sys].[xp_fixeddrives]
