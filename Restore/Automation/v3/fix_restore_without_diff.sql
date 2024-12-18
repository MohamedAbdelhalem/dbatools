USE [master]
GO
/****** Object:  StoredProcedure [dbo].[automatic_database_restore]    Script Date: 10/2/2022 4:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

declare
@before_date				datetime = '2022-10-01 00:02:00', 
@db_restore_name			varchar(500) = 't24sdc228',
@username					varchar(100) = 't24sdc228',
@SDC_backup_path			varchar(1000) = '\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\',
@PDC_backup_path			varchar(1000) = '\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\',
@continue_after_file_number int = 0,
@dbrecovery					bit = 1,
@action						int = 1
--1 = show backup files
--2 = begin restore 
--3 = 1 + 2

declare @final_table table (id int identity(1,1), backup_type varchar(10), backup_time_from datetime, backup_time_to datetime, 
backup_file_name varchar(1000), with_stopat varchar(100), [recovery] tinyint)

declare @backup_files table (backup_type varchar(10), backup_time datetime, backup_file_name varchar(2000))
declare @full table (output_text varchar(1000), directory varchar(3000))
declare @diff table (output_text varchar(1000), directory varchar(3000))
declare @logs table (output_text varchar(1000), directory varchar(3000))
declare 
@xp_folder_full_f_SDC		varchar(1000),
@xp_folder_full_f_PDC		varchar(1000),
@xp_folder_full_t_SDC		varchar(1000),
@xp_folder_full_t_PDC		varchar(1000),
@xp_folder_diff_f_SDC		varchar(1000),
@xp_folder_diff_f_PDC		varchar(1000),
@xp_folder_diff_t_SDC		varchar(1000),
@xp_folder_diff_t_PDC		varchar(1000),
@xp_folder_logs_f_SDC		varchar(1000),
@xp_folder_logs_f_PDC		varchar(1000),
@xp_folder_logs_t_SDC		varchar(1000),
@xp_folder_logs_t_PDC		varchar(1000),
@month_f					varchar(20),
@month_t					varchar(20),
@year_f						varchar(4),
@year_t						varchar(4),
@date_time_f				datetime,
@date_time_t				datetime,
@directory_map				varchar(2000),
@backup_type				varchar(4),
@backup_time				datetime, 
@backup_time_from			datetime, 
@backup_time_to				datetime, 
@backup_file_name			varchar(2000), 
@stopat						varchar(100),
@recovery					tinyint,
@max_id						int, 
@max_file_name				varchar(2000),
@error						varchar(2000),
@add_username				varchar(2000),
@change_recovery_setting	varchar(1000)
set nocount on

select 
@date_time_f = convert(varchar(10), dateadd(day, -10, @before_date),120), 
@year_f = year(dateadd(day, -10, @before_date)),
@month_f = case month(dateadd(day, -10, @before_date))
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end,
@date_time_t = @before_date,
@year_t = year(@before_date),
@month_t = case month(@before_date)
when 1  then 'January'
when 2  then 'February'
when 3  then 'March'
when 4  then 'April'
when 5  then 'May'
when 6  then 'June'
when 7  then 'July'
when 8  then 'August'
when 9  then 'September'
when 10 then 'October'
when 11 then 'November'
when 12 then 'December'
end

if month(@date_time_f) = month(@date_time_t)
begin 
set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

end
else if month(@date_time_f) != month(@date_time_t)
begin 

set @xp_folder_full_f_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_f_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_full_t_SDC = 'dir cd "'+@SDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_full_t_PDC = 'dir cd "'+@PDC_backup_path+'FULL\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_f_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_f_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_diff_t_SDC = 'dir cd "'+@SDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_diff_t_PDC = 'dir cd "'+@PDC_backup_path+'DIFF\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_f_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_f_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_f+'\'+@month_f+'\"'
set @xp_folder_logs_t_SDC = 'dir cd "'+@SDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'
set @xp_folder_logs_t_PDC = 'dir cd "'+@PDC_backup_path+'LOGs\'+@year_t+'\'+@month_t+'\"'

print(@xp_folder_full_f_SDC)
print(@xp_folder_full_f_PDC)
print(@xp_folder_full_t_SDC)
print(@xp_folder_full_t_PDC)
print(@xp_folder_diff_f_SDC)
print(@xp_folder_diff_f_PDC)
print(@xp_folder_diff_t_SDC)
print(@xp_folder_diff_t_PDC)
print(@xp_folder_logs_f_SDC)
print(@xp_folder_logs_f_PDC)
print(@xp_folder_logs_t_SDC)
print(@xp_folder_logs_t_PDC)

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_SDC
update @full set directory = replace(substring(@xp_folder_full_f_SDC,charindex('\',@xp_folder_full_f_SDC),len(@xp_folder_full_f_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_f_PDC
update @full set directory = replace(substring(@xp_folder_full_f_PDC,charindex('\',@xp_folder_full_f_PDC),len(@xp_folder_full_f_PDC)),'"','') where directory is null

insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_SDC
update @full set directory = replace(substring(@xp_folder_full_t_SDC,charindex('\',@xp_folder_full_t_SDC),len(@xp_folder_full_t_SDC)),'"','') where directory is null
insert into @full (output_text) exec xp_cmdshell @xp_folder_full_t_PDC
update @full set directory = replace(substring(@xp_folder_full_t_PDC,charindex('\',@xp_folder_full_t_PDC),len(@xp_folder_full_t_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_SDC
update @diff set directory = replace(substring(@xp_folder_diff_f_SDC,charindex('\',@xp_folder_diff_f_SDC),len(@xp_folder_diff_f_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_f_PDC
update @diff set directory = replace(substring(@xp_folder_diff_f_PDC,charindex('\',@xp_folder_diff_f_PDC),len(@xp_folder_diff_f_PDC)),'"','') where directory is null

insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_SDC
update @diff set directory = replace(substring(@xp_folder_diff_t_SDC,charindex('\',@xp_folder_diff_t_SDC),len(@xp_folder_diff_t_SDC)),'"','') where directory is null
insert into @diff (output_text) exec xp_cmdshell @xp_folder_diff_t_PDC
update @diff set directory = replace(substring(@xp_folder_diff_t_PDC,charindex('\',@xp_folder_diff_t_PDC),len(@xp_folder_diff_t_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_SDC
update @logs set directory = replace(substring(@xp_folder_logs_f_SDC,charindex('\',@xp_folder_logs_f_SDC),len(@xp_folder_logs_f_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_f_PDC
update @logs set directory = replace(substring(@xp_folder_logs_f_PDC,charindex('\',@xp_folder_logs_f_PDC),len(@xp_folder_logs_f_PDC)),'"','') where directory is null

insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_SDC
update @logs set directory = replace(substring(@xp_folder_logs_t_SDC,charindex('\',@xp_folder_logs_t_SDC),len(@xp_folder_logs_t_SDC)),'"','') where directory is null
insert into @logs (output_text) exec xp_cmdshell @xp_folder_logs_t_PDC
update @logs set directory = replace(substring(@xp_folder_logs_t_PDC,charindex('\',@xp_folder_logs_t_PDC),len(@xp_folder_logs_t_PDC)),'"','') where directory is null

end
--all above are only to get the backup files from which months like it's from july and august on the same year or only on august of this year


insert into @backup_files
(backup_type, backup_time, backup_file_name)
select 'full' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @full
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select 'diff' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @diff
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'
union all
select 'log' type, cast(
convert(varchar(10), cast(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',1))) as datetime),120)+' '+
cast(case when cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) = 12 then 0 else 
cast(master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',1) as int) end +
case ltrim(rtrim(master.dbo.virtical_array(output_text,' ',4))) when 'am' then 0 else 12 end as varchar(10))+':'+
master.dbo.virtical_array(ltrim(rtrim(master.dbo.virtical_array(output_text,' ',3))),':',2)+':00' as datetime) [backup_time],
directory+master.dbo.virtical_array(ltrim(rtrim(substring(output_text,charindex('M',output_text)+1,len(output_text)))),' ',2) backup_file_name
from @logs
where output_text like '%M %'
and output_text not like '%<DIR>%'
and output_text not like '%The system cannot find the file specified.%'

-- here to insert into @backup_files all backup files on the whole chosen month(s)

declare 
@full_backup_start_date datetime, 
@diff_backup_start_date datetime,
@backup_file_full_path varchar(3000)

select @full_backup_start_date = 
max(backup_time)
from @backup_files
where backup_time <= @before_date
and backup_type = 'full'

select @diff_backup_start_date = 
max(backup_time)
from @backup_files
where backup_time between @full_backup_start_date and @before_date 
and backup_type = 'diff'

select @directory_map = directorys_map 
from master.dbo.restore_loction_groups

insert into @final_table
select backup_type, backup_time_from, backup_time_to, backup_file_name, 
case 
when backup_type = 'log' and (@before_date >= backup_time_from and @before_date < backup_time_to) then 'STOPAT = '+''''+convert(varchar(40), @before_date, 120)+''''+'' 
else 'default' end [with_stopat],
case 
when backup_type = 'log' and (@before_date >= backup_time_from and @before_date < backup_time_to) then 1 else 0 end [recovery]
from (
select backup_type, dateadd(HOUR, -1, backup_time) backup_time_from, backup_time backup_time_to, backup_file_name 
from @backup_files 
where backup_time = @full_backup_start_date
and backup_type = 'full'
union all
select backup_type, dateadd(MINUTE, -15, backup_time) backup_time_from, backup_time backup_time_from, backup_file_name 
from @backup_files 
where backup_time = @diff_backup_start_date
and backup_type = 'diff'
union all
select backup_type, backup_time_from, backup_time_to, backup_file_name 
from (
select a.backup_type, convert(datetime,isnull(b.backup_time,a.backup_time),120) backup_time_from, convert(datetime,a.backup_time,120) backup_time_to, a.backup_file_name
from 
(select row_number() over(order by backup_time) id, * from @backup_files where backup_type = 'log')a
left outer join 
(select row_number() over(order by backup_time) id, * from @backup_files where backup_type = 'log')b
on a.id = b.id + 1)c
where 
backup_time_to > isnull(@diff_backup_start_date, @full_backup_start_date)
and 
backup_time_from <= @before_date--################################################################################
)a
order by backup_time_from 

select * from @final_table
