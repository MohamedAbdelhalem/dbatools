use test
go
--prerequisites 
--1. new custom error message

--new error message
exec sp_addmessage 
199999,
16,
'You have reached the threshold of the transaction log file''s disk used space and that means that the automation process just has created a new log file, please act as a critical matter to solve the long-running transaction that caused this issue and free up the log then remove this temp log file as soon as you can.',
'us_english',
'True',
NULL
go

/*
select * 
from sys.messages
where language_id = 1033
and message_id = 199999
*/
go

--2. alert to fire when the error message logged
	
EXEC msdb.dbo.sp_add_alert @name=N'log_file_threshold', 
		@message_id=199999, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

--3. open port 5985 between all replica servers for Security Considerations for PowerShell Remoting using WinRM

--4.
--Create a job and make it run every 1 minute to execute the below procedure with your threshold and new disk to create the new log file
go
CREATE Procedure [dbo].[usp_add_log_file_critical_behavior](
@threshold_pct	float = 5,
@new_volume		varchar(10) = 'K:\',
@log_size		int = 2
)
as
begin
declare 
@volume				varchar(10),
@disk_size			varchar(20),
@disk_free			varchar(20),
@used_pct			float,
@logical_name		varchar(255),
@physical_name		varchar(2000),
@log_file_size		varchar(20),
@log_file_free		varchar(20),
@log_file_growth	varchar(20),
@log_file_max		varchar(20),
@sql				varchar(max),
@log_file_count		int,
@new_file_name		varchar(max),
@new_path			varchar(max),
@xp_cmdshell		varchar(1000),
@replicas			varchar(max)

declare @Test_Path table (does_exist varchar(10))
select 
@volume				= volume_mount_point, 
@disk_size			= master.dbo.numbersize(v.total_bytes,'b'),
@disk_free			= master.dbo.numbersize(available_bytes,'b'), 
@used_pct			= cast(cast((v.total_bytes - v.available_bytes) as float) / cast(v.total_bytes as float) * 100.0 as numeric(10,3)),
@logical_name		= name, 
@physical_name		= physical_name, 
@log_file_size		= master.dbo.numbersize(size * 8.0, 'k'), 
@log_file_free		= master.dbo.numbersize((size * 8.0)- (fileproperty(name,'spaceused') * 8.0),'k'),
@log_file_growth	= master.dbo.numbersize(growth * 8.0,'k'),
@log_file_max		= master.dbo.numbersize(max_size * 8.0, 'k')
from sys.database_files dbf cross apply sys.dm_os_volume_stats(DB_ID(), file_id) v
where type = 1
and dbf.file_id in (select MIN(file_id) from sys.database_files sdbf where type = 1)
and v.volume_mount_point != @new_volume

select @log_file_count = COUNT(*) 
from sys.database_files 
where type = 1

set @new_path = reverse(SUBSTRING(reverse(@physical_name),charindex('\',reverse(@physical_name)),LEN(@physical_name)))
set @new_path = @new_volume+SUBSTRING(@new_path,4,len(@new_path))
set @new_file_name = reverse(SUBSTRING(reverse(@physical_name),1, charindex('\',reverse(@physical_name))-1))
set @new_file_name = master.dbo.vertical_array(@new_file_name,'.',1)+'_'+CAST(@log_file_count + 1 as varchar(10))+'.'+master.dbo.vertical_array(@new_file_name,'.',2)

if exists (select * from sys.availability_replicas)
begin
select @replicas = ISNULL(@replicas+', ','') + case when charindex('\',replica_server_name) > 0 then substring(replica_server_name,1,charindex('\',replica_server_name)-1) else replica_server_name end
from sys.availability_replicas
end
else
begin
set @replicas = case when charindex('\',@@SERVERNAME) > 0 then substring(@@SERVERNAME,1,charindex('\',@@SERVERNAME)-1) else @@SERVERNAME end
end

select @new_path, @new_file_name, @used_pct, @replicas


--Creating a new log file on the new drive only if: 
--1. the used space % is = or > than 95%.
--2. if there is no log file that exists on the new drive.
if @used_pct >= @threshold_pct 
begin
	if (select COUNT(*) from sys.database_files where type = 1 and left(physical_name,3) = @new_volume) = 0
	begin
		set @xp_cmdshell = 'xp_cmdshell ''PowerShell.exe -Command "& {Test-Path -Path '+@new_path+'}"'''
		insert into @Test_Path
		exec(@xp_cmdshell)

		if (select top 1 does_exist from @Test_Path where does_exist is not null) = 'False'
		begin
			set @xp_cmdshell = 'xp_cmdshell ''PowerShell.exe -Command "& {Invoke-Command -ComputerName '+@replicas+' -ScriptBlock {mkdir -Path '''''+@new_path+'''''}}"'''
			exec(@xp_cmdshell)
			print(@xp_cmdshell)
		end	

		set @sql = 'ALTER DATABASE ['+db_name(DB_ID())+'] ADD LOG FILE (NAME='+''''+@logical_name+'_Emergency'', FILENAME= '+''''+@new_path+@new_file_name+''''+', SIZE= '+cast(@log_size as varchar(10))+'GB, FILEGROWTH= '+replace(@log_file_growth,' ','')+', MAXSIZE=UNLIMITED)'
		print(@sql)
		exec(@sql)
		RAISERROR (199999, -1, -1, @sql);
	end
end
end

--go

----Solution 1 but it doesn't work because the trigger will not work because it will not update the view using UPDATE statement ever happens.
--CREATE View [dbo].[log_files_used_pct]
--as
--select 
--row_number() over(order by dbf.FILE_ID) id,
--v.volume_mount_point,
--used_pct = cast(cast((v.total_bytes - v.available_bytes) as float) / cast(v.total_bytes as float) * 100.0 as numeric(10,3))
--from sys.database_files dbf cross apply sys.dm_os_volume_stats(DB_ID(), file_id) v
--where type = 1
--and dbf.file_id in (select MIN(file_id) from sys.database_files sdbf where type = 1)

--go
--select used_pct
--from dbo.log_files_used_pct
--where id = 1
--go

----the trigger will not run ever because there is no update statement happens on the dbo.log_files_used_pct view
--CREATE Trigger [dbo].[log_file_threshold_monitor_trigger]
--on dbo.log_files_used_pct
--INSTEAD OF update
--as
--begin
--declare @used_pct float
--select @used_pct = used_pct
--from dbo.log_files_used_pct
--where id = 1

--if @used_pct >= 57
--begin
--	RAISERROR (199999, -1, -1, 'Transaction log file threshold exceeds');
--end
--end

