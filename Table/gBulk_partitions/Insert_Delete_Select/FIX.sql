--Fix
 
declare 
@full_path_of_backup_file  varchar(1000),
@restore_header varchar(1500),
@full_backup_file_name varchar(1000),
@Restore_Type varchar(100)
 
--declare @table_header_full table (
--drop table #table_header_full
create table #table_header_full (
col01 varchar(500),col02 varchar(500),col03 varchar(500),col04 varchar(500),col05 varchar(500),col06 varchar(5),
col07 varchar(max),col08 varchar(100),col09 varchar(500),DatabaseName varchar(500),col11 varchar(max),
col12 varchar(max),col13 varchar(max),col14 varchar(max),col15 varchar(max),CheckpointLSN numeric(25),DatabaseBackupLSN numeric(25),BackupStartDate datetime,
BackupFinishDate datetime,col18 varchar(max),col19 varchar(max),col20 varchar(max),col21 varchar(max),
col22 varchar(max),col23 varchar(max),col24 varchar(max),col25 varchar(max),col26 varchar(max),
col27 varchar(max),col28 varchar(max),col29 varchar(max),col30 varchar(max),col31 varchar(max),
col32 varchar(max),col33 varchar(max),col34 varchar(max),col35 varchar(max),col36 varchar(max),
col37 varchar(max),col38 varchar(max),col39 varchar(max),col40 varchar(max),col41 varchar(max),
col42 varchar(max),col43 varchar(max),col44 varchar(max),col45 varchar(max),col46 varchar(max),
col47 varchar(100),BackupTypeDescription varchar(max),col49 varchar(max),col50 varchar(100),col51 varchar(max),
col52 varchar(max),col53 varchar(max),col54 varchar(max), backup_file_name varchar(max))
 
--select top 1 @full_path_of_backup_file = full_path_of_backup_file, @Restore_Type = restore_type
declare full_diff_cursor cursor fast_forward
for
select top 1 full_path_of_backup_file
from master.dbo.restore_history('T24Prod')
where restore_type in ('Full')
union
select full_path_of_backup_file
from (
select top 1 full_path_of_backup_file, restore_type
from master.dbo.restore_history('T24Prod')
where restore_type in ('Differential')
order by restore_date desc)a
 
open full_diff_cursor
fetch next from full_diff_cursor into @full_path_of_backup_file
while @@FETCH_STATUS = 0
begin
 
set @restore_header = 'restore headeronly from disk ='+''''+@full_path_of_backup_file+''''
insert into #table_header_full
(col01,col02,col03,col04,col05,col06,col07,col08,col09,DatabaseName,col11,col12,col13,col14,col15,CheckpointLSN,DatabaseBackupLSN,BackupStartDate,BackupFinishDate,col18,col19,col20,col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,col41,col42,col43,col44,col45,col46,col47,BackupTypeDescription,col49,col50,col51,col52,col53,col54)
exec(@restore_header)
update #table_header_full set backup_file_name = @full_path_of_backup_file where backup_file_name is null
 
fetch next from full_diff_cursor into @full_path_of_backup_file
end
close full_diff_cursor
deallocate full_diff_cursor
 
 
declare fix_cursor cursor fast_forward
for
select full_backup_file_name 
from dbo.migration_log_files
order by file_datetime
 
open fix_cursor
fetch next from fix_cursor into @full_path_of_backup_file
while @@FETCH_STATUS = 0
begin
 
set @restore_header = 'restore headeronly from disk ='+''''+@full_path_of_backup_file+''''
insert into #table_header_full
(col01,col02,col03,col04,col05,col06,col07,col08,col09,DatabaseName,col11,col12,col13,col14,col15,CheckpointLSN,DatabaseBackupLSN,BackupStartDate,BackupFinishDate,col18,col19,col20,col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,col31,col32,col33,col34,col35,col36,col37,col38,col39,col40,col41,col42,col43,col44,col45,col46,col47,BackupTypeDescription,col49,col50,col51,col52,col53,col54)
exec(@restore_header)
update #table_header_full set backup_file_name = @full_path_of_backup_file where backup_file_name is null
 
fetch next from fix_cursor into @full_path_of_backup_file
end
close fix_cursor
deallocate fix_cursor
 
 
--drop table #table_header_full
 
declare 
@CheckpointLSN numeric(25),
@full_backup_start_date datetime,
@full_backup_end_date datetime, 
@FullLSN		varchar(100),
@DiffLSN		varchar(100),
@before_date	datetime = '2050-12-31',
@diff_backup_end_date datetime,
@logs_backup_start_date datetime,
@first_log_backup_ID    int
 
select top 1 
@full_backup_start_date = BackupStartDate,
@full_backup_end_date = BackupFinishDate, 
@checkpointLSN = CheckpointLSN,
@FullLSN = col15
from #table_header_full
where BackupFinishDate in (
select max(BackupFinishDate) BackupFinishDate
from #table_header_full
where BackupTypeDescription = 'Database')
and BackupTypeDescription = 'Database'
 
select @diff_backup_end_date = 
max(BackupFinishDate)
from #table_header_full
where BackupfinishDate between @full_backup_end_date and @before_date 
and BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN
 
-----new fix-----v9
select @DiffLSN = MAX(col15)
from #table_header_full
where BackupfinishDate between @full_backup_end_date and @before_date 
and BackupTypeDescription = 'Database Differential'
and DatabaseBackupLSN = @checkpointLSN
-----end fix-----v9
 
-----new fix-----v9
if @DiffLSN is not null
begin
select @logs_backup_start_date =
BackupStartDate
from #table_header_full
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate between @full_backup_start_date and @before_date
and @DiffLSN between col14 and col15 
order by BackupstartDate 
end
else
begin
select @logs_backup_start_date =
BackupStartDate
from #table_header_full
where BackupTypeDescription = 'Transaction Log'
and BackupStartDate between @full_backup_start_date and @before_date
and @FullLSN between col14 and col15 
order by BackupstartDate 
end
-----end fix-----v9
 
 
update dbo.migration_log_files
set start_eq_or_af = 0
where file_datetime < @diff_backup_end_date
