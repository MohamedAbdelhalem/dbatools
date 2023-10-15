select 
row_number() over(order by j.name) [#],
j.name job_name, max(j.enabled) job_enable,
convert(datetime,(select 
convert(varchar(10),convert(datetime,cast(run_date as varchar(30)),112),120)+' '+
case 
when len(run_time) = 1 then '00:00:0'+ cast(run_time as varchar(50))
when len(run_time) = 2 then '00:00:'+ cast(run_time as varchar(50))
when len(run_time) = 3 then '00:0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)
when len(run_time) = 4 then '00:'+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)
when len(run_time) = 5 then '0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)+':'+substring(cast(run_time as varchar(50)),4,2)
when len(run_time) = 6 then ''+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)+':'+substring(cast(run_time as varchar(50)),5,2)
end
from msdb.dbo.sysjobhistory where instance_id = (select top 1 max(t.instance_id) from msdb.dbo.sysjobhistory t where step_id = 0 and t.job_id = j.job_id)),120) last_run_time,
(select case 
when len(run_duration) = 1 then '00h:00m:0'+ cast(run_duration as varchar(50))+'s'
when len(run_duration) = 2 then '00h:00m:'+ cast(run_duration as varchar(50))+'s'
when len(run_duration) = 3 then '00h:0'+ substring(cast(run_duration as varchar(50)),1,1)+'m:'+substring(cast(run_duration as varchar(50)),2,2)+'s'
when len(run_duration) = 4 then '00h:'+ substring(cast(run_duration as varchar(50)),1,2)+'m:'+substring(cast(run_duration as varchar(50)),3,2)+'s'
when len(run_duration) = 5 then '0'+ substring(cast(run_duration as varchar(50)),1,1)+'h:'+substring(cast(run_duration as varchar(50)),2,2)+'m:'+substring(cast(run_duration as varchar(50)),4,2)+'s'
when len(run_duration) = 6 then ''+ substring(cast(run_duration as varchar(50)),1,2)+'h:'+substring(cast(run_duration as varchar(50)),3,2)+'m:'+substring(cast(run_duration as varchar(50)),5,2)+'s'
end
from msdb.dbo.sysjobhistory where instance_id = (select max(t.instance_id) from msdb.dbo.sysjobhistory t where step_id = 0 and t.job_id = j.job_id)) last_run_duration,
case 
	when max(s.freq_type) = 1									then 'One time only'
	when max(s.freq_type) = 4 and max(s.freq_subday_type) = 1	then 'Once a Day'
	when max(s.freq_type) = 4 and max(s.freq_subday_type) > 1	then 'Daily'
	when max(s.freq_type) = 8									then 'Weekly'
	when max(s.freq_type) in (16,32)							then 'Monthly'
	when max(s.freq_type) = 64									then 'Runs when the SQL Server Agent service starts'
	when max(s.freq_type) = 128									then 'Runs when the computer is idle'
end + 
case 
	when max(s.freq_type) in (1,4,8,16,32) and max(s.freq_subday_type) = 1 then ' at ' + case 
	when len(max(js.next_run_time)) = 1 then '00:00:0'+ cast(max(js.next_run_time) as varchar(50))
	when len(max(js.next_run_time)) = 2 then '00:00:'+ cast(max(js.next_run_time) as varchar(50))
	when len(max(js.next_run_time)) = 3 then '00:0'+ substring(cast(max(js.next_run_time) as varchar(50)),1,1)+':'+substring(cast(max(js.next_run_time) as varchar(50)),2,2)
	when len(max(js.next_run_time)) = 4 then '00:'+ substring(cast(max(js.next_run_time) as varchar(50)),1,2)+':'+substring(cast(max(js.next_run_time) as varchar(50)),3,2)
	when len(max(js.next_run_time)) = 5 then '0'+ substring(cast(max(js.next_run_time) as varchar(50)),1,1)+':'+substring(cast(max(js.next_run_time) as varchar(50)),2,2)+':'+substring(cast(max(js.next_run_time) as varchar(50)),4,2)
	when len(max(js.next_run_time)) = 6 then ''+ substring(cast(max(js.next_run_time) as varchar(50)),1,2)+':'+substring(cast(max(js.next_run_time) as varchar(50)),3,2)+':'+substring(cast(max(js.next_run_time) as varchar(50)),5,2)
end +		
case 
when max(s.freq_type) in (8) then case max(s.freq_interval)
									when 1  then ' on Sunday '
									when 2  then ' on Monday '
									when 4  then ' on Tuesday '
									when 8  then ' on Wednesday '
									when 16 then ' on Thursday '
									when 32 then ' on Friday '
									when 64 then ' on Saturday '
									else ' on '+
												(select 
												[dbo].[day_interval](max(sub_s.freq_interval))
												from msdb.dbo.sysjobhistory sub_h inner join msdb.dbo.sysjobs sub_j
												on sub_h.job_id = sub_j.job_id
												left outer join msdb.dbo.sysjobschedules sub_js
												on sub_j.job_id = sub_js.job_id
												left outer join msdb.dbo.sysschedules sub_s
												on sub_js.schedule_id = sub_s.schedule_id
												where instance_id = (select top 1 max(sub_t.instance_id) from msdb.dbo.sysjobhistory sub_t where step_id = 0 and sub_t.job_id = j.job_id)) 
												end 
when max(s.freq_type) in (16) then ' on '+
										(select 
										'day '+cast(max(sub_s.freq_interval) as varchar(10))+' of every month'
										from msdb.dbo.sysjobhistory sub_h inner join msdb.dbo.sysjobs sub_j
										on sub_h.job_id = sub_j.job_id
										left outer join msdb.dbo.sysjobschedules sub_js
										on sub_j.job_id = sub_js.job_id
										left outer join msdb.dbo.sysschedules sub_s
										on sub_js.schedule_id = sub_s.schedule_id
										where instance_id = (select top 1 max(sub_t.instance_id) from msdb.dbo.sysjobhistory sub_t where step_id = 0 and sub_t.job_id = j.job_id)) 
when max(s.freq_type) in (32) then	case max(s.freq_interval)
										when 1  then ' on Sunday'
										when 2  then ' on Monday'
										when 3  then ' on Tuesday'
										when 4	then ' on Wednesday'
										when 5	then ' on Thursday'
										when 6	then ' on Friday'
										when 7	then ' on Saturday'
										when 8	then ' on '+
															(select 
															case max(sub_s.freq_relative_interval) 
															when 1  then 'the first day of every month'
															when 2  then 'the second day of every month'
															when 4  then 'the third day of every month'
															when 8	then 'the fourth day of every month'
															when 16	then 'the last day of every month'
															end
															from msdb.dbo.sysjobhistory sub_h inner join msdb.dbo.sysjobs sub_j
															on sub_h.job_id = sub_j.job_id
															left outer join msdb.dbo.sysjobschedules sub_js
															on sub_j.job_id = sub_js.job_id
															left outer join msdb.dbo.sysschedules sub_s
															on sub_js.schedule_id = sub_s.schedule_id
															where instance_id = (select top 1 max(sub_t.instance_id) from msdb.dbo.sysjobhistory sub_t where step_id = 0 and sub_t.job_id = j.job_id)) 
										end 
else '' 
end
when max(s.freq_type) in (1,4,8,16,32) and max(s.freq_subday_type) > 1 then ' every ' + cast(max(s.freq_subday_interval) as varchar(20)) +	case max(freq_subday_type)
																																			when 2 then case when max(s.freq_subday_interval) = 1 then ' Second' else ' Seconds' end
																																			when 4 then case when max(s.freq_subday_interval) = 1 then ' Minute' else ' Minutes' end
																																			when 8 then case when max(s.freq_subday_interval) = 1 then ' Hour' else ' Hours' end
																																			end
end schedule_time,
max(s.enabled) schedule_enable, 
sum(case when h.step_id = 0 and h.run_status = 1 then 1 else 0 end) succes_running_times, 
sum(case when h.step_id = 0 and h.run_status = 0 then 1 else 0 end) failed_running_times, 
master.dbo.duration('s', min(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) min_run_duration,
master.dbo.duration('s', avg(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) avg_run_duration,
master.dbo.duration('s', max(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) max_run_duration
from msdb.dbo.sysjobhistory h inner join msdb.dbo.sysjobs j
on h.job_id = j.job_id
left outer join msdb.dbo.sysjobschedules js
on j.job_id = js.job_id
left outer join msdb.dbo.sysschedules s
on js.schedule_id = s.schedule_id
--where j.name in ('T24_Clean_F_BAB_T_ENTRY_TRACK','Monthly delete from F_ENJ_T_O201 table','Delete Schedule','Daily Delete job')
where j.job_id in (select job_id
from msdb.dbo.sysjobsteps
where command like '%delete%'
or command like '%truncate%')
and j.name not in ('AlwaysOn_Latency_Data_Collection')
group by j.name, j.job_id
order by j.name, last_run_time desc

--15	DBA_Update_Stats_DAILY	1	2023-07-30 21:00:00.000	02h:30m:59s	Once a Day at 21:00:00	1	40	0	0d 00h:00m:00s	0d 03h:18m:00s	0d 06h:57m:09s
GO

declare @steps_table table (job_id varchar(100), steps varchar(max))
declare @job_id varchar(100), @steps varchar(max)
declare cursor_steps cursor fast_forward
for
select distinct job_id
from msdb.dbo.sysjobsteps
where command like '%delete%'
or command like '%truncate%'

open cursor_steps 
fetch next from cursor_steps into @job_id
while @@FETCH_STATUS = 0
begin

set @steps = null

select @steps = isnull(@steps+'
--------
','')+command
from msdb.dbo.sysjobsteps
where job_id = @job_id
and command like '%delete%'
or command like '%truncate%'

insert into @steps_table values (@job_id, @steps)
fetch next from cursor_steps into @job_id
end
close cursor_steps 
deallocate cursor_steps 

select j.name job_name, s.value
from @steps_table t cross apply master.dbo.Separator(t.steps,char(10)) s
inner join msdb.dbo.sysjobs j
on t.job_id = j.job_id
where (s.value like '%delete%from%'
or s.value like '%truncate%table%')
and j.name not in ('AlwaysOn_Latency_Data_Collection')
order by job_name, s.id

