exec msdb.dbo.sp_start_job @job_name = 'capacity_manager_view'

select top 1 job_name, run_status, message, convert(datetime, rundate+' '+substring(runtime,1,2)+':'+substring(runtime,3,2)+':'+substring(runtime,5,2), 120) run_date_time, duration
from (
select step_id, j.name job_name, case run_status 
when 0 then 'Failed'
when 1 then 'Succeeded'
when 2 then 'Retry'
when 3 then 'Canceled'
when 4 then 'In Progress'
end run_status, message, substring(cast(run_date as varchar),1,4)+'-'+substring(cast(run_date as varchar),5,2)+'-'+substring(cast(run_date as varchar),7,2) rundate, 
case 
when len(jh.run_time) = 0 then '000000'
when len(jh.run_time) = 1 then '00000'+cast(run_time as varchar(10))
when len(jh.run_time) = 2 then '0000'+cast(run_time as varchar(10))
when len(jh.run_time) = 3 then '000'+cast(run_time as varchar(10))
when len(jh.run_time) = 4 then '00'+cast(run_time as varchar(10))
when len(jh.run_time) = 5 then '0'+cast(run_time as varchar(10))
when len(jh.run_time) = 6 then cast(run_time as varchar(10))
end runtime, master.dbo.duration('s',jh.run_duration) duration
from msdb.dbo.sysjobhistory jh inner join msdb.dbo.sysjobs j
on jh.job_id = j.job_id
where step_id = 0
and name = 'capacity_manager_view'
)a
order by run_date_time desc

declare @app_name varchar(1000)
select @app_name = [app_name] from dbo.server_details
select @app_name

exec [dbo].[server_disk_state_email] 
@project_name		= @app_name, 
@ccteam				= '', 
@with_cc			= 0,
@threshold			= 85,
@exceed_threshold	= 0  
