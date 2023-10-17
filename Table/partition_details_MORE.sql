select * from (
select distinct object_name(object_id) table_name, a.data_space_id, fg.name filegroup_nmae, fg.type_desc, mf.name logical_name, mf.physical_name, p.partition_number, master.dbo.format(partition_rows ,-1) partition_rows, master.dbo.numberSize((mf.size * 8.0)/1024.0,'kb') file_size, mf.size
from sys.allocation_units a inner join (
select object_id, partition_id, partition_number, hobt_id, max(rows) partition_rows
from sys.partitions
--where object_id = object_id('[dbo].[ACCT_STMT]')
group by object_id, partition_id, partition_number, hobt_id) p
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.filegroups fg
on a.data_space_id = fg.data_space_id
inner join sys.master_files mf
on fg.data_space_id = mf.data_space_id
and database_id = db_id())a
--order by size desc
--order by table_name, filegroup_nmae --desc
order by size desc

use AccountStatementPRD
go
select table_name, filegroup_nmae, partition_number, logical_name, physical_name, master.dbo.format(file_total_partitions_rows,-1) file_total_partitions_rows, file_size, file_used_size, file_free_size
from (
select table_name, filegroup_nmae, logical_name, physical_name, sum(partition_rows) file_total_partitions_rows, 
file_size, 
master.dbo.numbersize(cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0 ,'kb') file_used_size, 
master.dbo.numbersize(cast(size as float) - (cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) ,'kb') file_free_size, 
size,
(cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) used_size,
cast(size as float) - (cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) free_size,
partition_number
from (
select --distinct 
table_name, a.data_space_id, fg.name filegroup_nmae, fg.type_desc, mf.name logical_name, 
mf.physical_name, p.partition_number, partition_rows, master.dbo.numberSize((mf.size * 8.0),'kb') file_size, mf.size * 8.0 size
from sys.allocation_units a inner join (
select '['+schema_name(schema_id)+'].['+t.name+']' table_name, partition_id, partition_number, hobt_id, max(rows) partition_rows
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
where p.index_id = 1
group by schema_name(schema_id), t.name, partition_id, partition_number, hobt_id) p
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.filegroups fg
on a.data_space_id = fg.data_space_id
inner join sys.master_files mf
on fg.data_space_id = mf.data_space_id
and database_id = db_id()
where a.type = 1)a
group by table_name, filegroup_nmae, partition_number, logical_name, physical_name, file_size, FILEPROPERTY(logical_name, 'SpaceUsed'), size)b
where table_name = '[dbo].[ACCT_STMT_TXN]'
--and filegroup_nmae != 'PRIMARY'
order by partition_number

select table_name, filegroup_nmae, partition_number, logical_name, b.physical_name, file_total_partitions_rows, file_size, file_used_size, file_free_size,
master.dbo.numbersize(mf.growth * 8,'kb') growth , 
case when mf.max_size < 0 then 'unlimited' else master.dbo.numbersize(mf.max_size * 8,'kb') end max_size 
from (
select table_name, filegroup_nmae, partition_number, logical_name, physical_name, master.dbo.format(file_total_partitions_rows,-1) file_total_partitions_rows, file_size, file_used_size, file_free_size
from (
select table_name, filegroup_nmae, logical_name, physical_name, sum(partition_rows) file_total_partitions_rows, 
file_size, 
master.dbo.numbersize(cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0 ,'kb') file_used_size, 
master.dbo.numbersize(cast(size as float) - (cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) ,'kb') file_free_size, 
size,
(cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) used_size,
cast(size as float) - (cast(FILEPROPERTY(logical_name, 'SpaceUsed') as float) * 8.0) free_size,
partition_number
from (
select --distinct 
table_name, a.data_space_id, fg.name filegroup_nmae, fg.type_desc, mf.name logical_name, 
mf.physical_name, p.partition_number, partition_rows, master.dbo.numberSize((mf.size * 8.0),'kb') file_size, mf.size * 8.0 size
from sys.allocation_units a inner join (
select '['+schema_name(schema_id)+'].['+t.name+']' table_name, partition_id, partition_number, hobt_id, max(rows) partition_rows
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
where p.index_id = 1
group by schema_name(schema_id), t.name, partition_id, partition_number, hobt_id) p
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.filegroups fg
on a.data_space_id = fg.data_space_id
inner join sys.master_files mf
on fg.data_space_id = mf.data_space_id
and database_id = db_id()
where a.type = 1)a
group by table_name, filegroup_nmae, partition_number, logical_name, physical_name, file_size, FILEPROPERTY(logical_name, 'SpaceUsed'), size)b
where table_name = '[dbo].[ACCT_STMT_TXN]'
and filegroup_nmae != 'PRIMARY')b inner join sys.master_files mf
on b.logical_name = mf.name
where mf.database_id = db_id()
order by partition_number

alter database CC_StatementArchive_PRD modify file (name ='CC_StatementArchive_PRD', filegrowth=0KB)
alter database AccountStatementPRD modify file (name ='AccountStatementPRD', filegrowth=0KB)
alter database AccountStatementPRD modify file (name ='part201501_stg', filegrowth=0KB)

use master
go
alter database AccountStatementPRD set partner off
GO
alter database AccountStatementPRD add file (name ='AccountStatementPRD_2', filename = 'I:\Data\AccountStatementPRD_stg_2.ndf', size = 1024MB, filegrowth=1024MB) To Filegroup [PRIMARY]
alter database AccountStatementPRD add file (name ='part201501_stg_2', filename = 'I:\Data\part201501_stg_2.ndf', size = 1024MB, filegrowth=1024MB) To Filegroup [part201501]
GO
BACKUP LOG AccountStatementPRD 
TO  DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1ENTDBSQPWV4\AccountStatementPRD\Log\D1ENTDBSQPWV4_AccountStatementPRD_Log_20220906_111111_add_file.trn' WITH NOFORMAT, NOINIT,  
NAME = N'AccountStatementPRD-Log Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 1
GO
ALTER DATABASE AccountStatementPRD SET PARTNER = 'TCP://D2ENTDBSQPWV4.albilad.com:5022'


RESTORE LOG AccountStatementPRD FROM 
DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1ENTDBSQPWV4\AccountStatementPRD\Log\D1ENTDBSQPWV4_AccountStatementPRD_Log_20220906_111111_add_file.trn'
WITH 
Move N'AccountStatementPRD_2' TO N'I:\Data\AccountStatementPRD_stg_2.ndf',
Move N'part201501_stg_2' TO N'I:\Data\part201501_stg_2.ndf',
NORECOVERY, NOUNLOAD, STATS = 10
GO

ALTER DATABASE AccountStatementPRD SET PARTNER = 'TCP://D1ENTDBSQPWV4.albilad.com:5022'
select * from sys.database_mirroring_endpoints
select * from sys.dm_db_mirroring_connections
select * from sys.dm_db_mirroring_past_actions
select * from sys.database_mirroring


--PRIMARY	H:\Data\AccountStatementPRD_stg.mdf
--part201501	H:\Data\part201501_stg.ndf
