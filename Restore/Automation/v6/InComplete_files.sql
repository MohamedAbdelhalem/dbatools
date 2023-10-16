--/****** Script for SelectTopNRows command from SSMS  ******/
--select 
--	   [col01]
--	  ,master.[dbo].[date_yyyymmddhhmiss](date_time) date_time
--	  ,datename(weekday,master.[dbo].[date_yyyymmddhhmiss](date_time)) [day_name]
--	  ,master.dbo.[virtical_array]([backup_file_name],'\',5)
--      ,[DatabaseName]
--      ,[CheckpointLSN]
--      ,[DatabaseBackupLSN]
--      ,[BackupStartDate]
--      ,[BackupFinishDate]
--      ,[BackupTypeDescription]
--      ,[backup_file_name]
--from (
--SELECT [col01]
--      ,[DatabaseName]
--      ,[CheckpointLSN]
--      ,[DatabaseBackupLSN]
--      ,[BackupStartDate]
--      ,[BackupFinishDate]
--      ,[BackupTypeDescription]
--      ,[backup_file_name]
--      ,reverse(substring(reverse([backup_file_name]),charindex('.',reverse([backup_file_name]))+1, charindex('_',reverse([backup_file_name]))-1-charindex('.',reverse([backup_file_name])))) date_time
--FROM [master].[dbo].[table_header]
--where backup_file_name in (
--SELECT [backup_file_name]
--FROM [master].[dbo].[table_header]
--where [col01] = '*** INCOMPLETE ***'))a
--order by date_time, backup_file_name


select *
from (
select *, case when col01 = '*** INCOMPLETE ***' then case when backup_file_name = LAG_col then 1 else 0 end end InComplete_files
from (
select *, case when col01 = '*** INCOMPLETE ***' then LAG(backup_file_name,1,1) over(order by backup_file_name, [col01] desc) else null end LAG_col
from (
select count(*) files,
master.[dbo].[date_yyyymmddhhmiss](date_time) date_time,
datename(weekday,master.[dbo].[date_yyyymmddhhmiss](date_time)) [day_name],
master.dbo.[virtical_array]([backup_file_name],'\',5) backup_type, 
[col01], [backup_file_name]
from (
SELECT [col01], [DatabaseName], [CheckpointLSN], [DatabaseBackupLSN]
      ,[BackupStartDate], [BackupFinishDate], [BackupTypeDescription], [backup_file_name]
      ,reverse(substring(reverse([backup_file_name]),charindex('.',reverse([backup_file_name]))+1, charindex('_',reverse([backup_file_name]))-1-charindex('.',reverse([backup_file_name])))) date_time
FROM [master].[dbo].[table_header]
where backup_file_name in (
SELECT [backup_file_name]
FROM [master].[dbo].[table_header]
where [col01] = '*** INCOMPLETE ***'))a
group by [col01], date_time, [backup_file_name])b)c)d
where InComplete_files = 0

go
create view backup_metadata_view
as
select top 100 percent
	   [col01] backup_file_description
	  ,master.[dbo].[date_yyyymmddhhmiss](date_time) date_time
	  ,datename(weekday,master.[dbo].[date_yyyymmddhhmiss](date_time)) [day_name]
	  ,master.dbo.[virtical_array]([backup_file_name],'\',5) folder
      ,[DatabaseName]
      ,[CheckpointLSN]
      ,[DatabaseBackupLSN]
 	  ,FirstLSN	
	  ,LastLSN
     ,[BackupStartDate]
      ,[BackupFinishDate]
      ,[BackupTypeDescription]
      ,[backup_file_name]
from (
SELECT [col01]
      ,[DatabaseName]
      ,[CheckpointLSN]
      ,[DatabaseBackupLSN]
	  ,[col14] FirstLSN	
	  ,[col15] LastLSN
      ,[BackupStartDate]
      ,[BackupFinishDate]
      ,[BackupTypeDescription]
      ,[backup_file_name]
      ,reverse(substring(reverse([backup_file_name]),charindex('.',reverse([backup_file_name]))+1, charindex('_',reverse([backup_file_name]))-1-charindex('.',reverse([backup_file_name])))) date_time
FROM [master].[dbo].[table_header]
where DatabaseBackupLSN in (
SELECT [CheckpointLSN]
FROM [master].[dbo].[table_header]
where [BackupStartDate] = (select max([BackupStartDate]) from [master].[dbo].[table_header] where [BackupTypeDescription] = 'Database'))
union
SELECT [col01]
      ,[DatabaseName]
      ,[CheckpointLSN]
      ,[DatabaseBackupLSN]
	  ,[col14] FirstLSN	
	  ,[col15] LastLSN
      ,[BackupStartDate]
      ,[BackupFinishDate]
      ,[BackupTypeDescription]
      ,[backup_file_name]
      ,reverse(substring(reverse([backup_file_name]),charindex('.',reverse([backup_file_name]))+1, charindex('_',reverse([backup_file_name]))-1-charindex('.',reverse([backup_file_name])))) date_time
FROM [master].[dbo].[table_header]
where [BackupStartDate] = (select max([BackupStartDate]) from [master].[dbo].[table_header] where [BackupTypeDescription] = 'Database'))a
order by date_time




SELECT [col01]
      ,[DatabaseName]
      ,[CheckpointLSN]
      ,[DatabaseBackupLSN]
	  ,[col14] FirstLSN	
	  ,[col15] LastLSN
      ,[BackupStartDate]
      ,[BackupFinishDate]
      ,[BackupTypeDescription]
      ,[backup_file_name]
      ,reverse(substring(reverse([backup_file_name]),charindex('.',reverse([backup_file_name]))+1, charindex('_',reverse([backup_file_name]))-1-charindex('.',reverse([backup_file_name])))) date_time
FROM [master].[dbo].[table_header]
where DatabaseBackupLSN in (
SELECT [CheckpointLSN]
FROM [master].[dbo].[table_header]
where [BackupStartDate] = (select max([BackupStartDate]) from [master].[dbo].[table_header] where [BackupTypeDescription] = 'Database'))
order by BackupStartDate



-- to identify the chane is locked or some files are missing
select date_time, folder, CheckpointLSN,
FirstLSN, LastLSN, 
case when BackupTypeDescription not in ('Transaction Log') then null else
LAG(LastLSN,1,1) over(order by date_time) end previous_LastLSN, 
BackupTypeDescription,
case when FirstLSN = 
case 
when BackupTypeDescription not in ('Transaction Log') then null 
else case 
when LAG(BackupTypeDescription,1,1) over(order by date_time) = 'Database Differential' then LAG(LastLSN,2,1) over(order by date_time)
else 
LAG(LastLSN,1,1) over(order by date_time) end end then 1 else 0 end chaneLSNStatus,
DatabaseBackupLSN, backup_file_name 
from dbo.backup_metadata_view
order by date_time
