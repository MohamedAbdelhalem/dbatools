use master
go
alter procedure [dbo].[monitor_sql_export_files](
@path varchar(1000),
@spid int,
@bulk int)
as
begin
declare @files float, @xp varchar(1000) = 'dir cd "'+@path+'"'
declare @table table (output_text varchar(1000))
insert into @table
exec xp_cmdshell @xp

select @files = count(*) from @table
where output_text like '%M  %'
and output_text not like '%<DIR>%'

select 
master.dbo.format(@files,-1) [exported_files], 
master.dbo.format(count(*),-1) total_files, 
cast(@files / count(*) * 100.0 as numeric(10,2)) percent_complete,
master.[dbo].[time_to_complete](@files, cast(count(*) as float), (select start_time from sys.dm_exec_requests where session_id = @spid)) time_to_complete,
master.[dbo].[duration]('s',datediff(s,(select start_time from sys.dm_exec_requests where session_id = @spid),getdate())) duration,
master.dbo.format(count(*) * @bulk, -1) number_of_records_bulk
from [master].[dbo].[F_BAB_L_GEN_ACCT_STMT_summary]
end
go

exec [dbo].[monitor_sql_export_files]
@path = 'N:\Export\',
@spid = 65,
@bulk = 6000
