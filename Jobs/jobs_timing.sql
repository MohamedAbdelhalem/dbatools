use master
go
select 
row_number() over(order by j.name) [#],
j.name job_name, max(j.enabled) job_enable,
case when datediff(s, getdate(),case when (max(s.freq_type) in (1) 
--or (max(s.freq_type) = 4 and max(s.freq_subday_type) = 1)
) and max(s.enabled) = 1 and max(j.enabled) = 1 then 
substring(cast(max(js.next_run_date) as varchar(50)),1,4)+'-'+
substring(cast(max(js.next_run_date) as varchar(50)),5,2)+'-'+
substring(cast(max(js.next_run_date) as varchar(50)),7,2)+' '+
case 
	when len(max(js.next_run_time)) = 1 then '00:00:0'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(js.next_run_time)) = 2 then '00:00:'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(js.next_run_time)) = 3 then '00:0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)
	when len(max(js.next_run_time)) = 4 then '00:'+ substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)
	when len(max(js.next_run_time)) = 5 then '0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),4,2)
	when len(max(js.next_run_time)) = 6 then substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),5,2)
end end) < 0 then 'Running' else master.dbo.duration('s', datediff(s, getdate(),case when (max(s.freq_type) in (1) 
) and max(s.enabled) = 1 and max(j.enabled) = 1 then 
substring(cast(max(js.next_run_date) as varchar(50)),1,4)+'-'+
substring(cast(max(js.next_run_date) as varchar(50)),5,2)+'-'+
substring(cast(max(js.next_run_date) as varchar(50)),7,2)+' '+
case 
	when len(max(js.next_run_time)) = 1 then '00:00:0'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(js.next_run_time)) = 2 then '00:00:'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(js.next_run_time)) = 3 then '00:0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)
	when len(max(js.next_run_time)) = 4 then '00:'+ substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)
	when len(max(js.next_run_time)) = 5 then '0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),4,2)
	when len(max(js.next_run_time)) = 6 then substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),5,2)
end end)) end  Next_time_run,
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
replace(isnull(
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
-----------------------------------------------------------------------------------
when max(s.freq_type) in (1,4,8,16,32) and max(s.freq_subday_type) in (0,1) then ' at '  
																					-----------------------------------------------------------------------------------
																					+ case -- about schedules "Only One-Time"
																					  when max(s.freq_type) = 1 then 
																					  substring(cast(max(active_start_date) as varchar(50)),1,4)+'-'+ 
																					  substring(cast(max(active_start_date) as varchar(50)),5,2)+'-'+
																					  substring(cast(max(active_start_date) as varchar(50)),7,2)+' ' 
																					  else ''
																					  end 
																					-----------------------------------------------------------------------------------
+ case 
	when len(max(s.active_start_time)) = 1 then '00:00:0'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(s.active_start_time)) = 2 then '00:00:'+ cast(max(s.active_start_time) as varchar(50))
	when len(max(s.active_start_time)) = 3 then '00:0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)
	when len(max(s.active_start_time)) = 4 then '00:'+ substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)
	when len(max(s.active_start_time)) = 5 then '0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),4,2)
	when len(max(s.active_start_time)) = 6 then substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),5,2)
end 
+ case 
		when max(s.freq_type) in (8) then case max(s.freq_interval)
											when 1  then ' on Sunday '
											when 2  then ' on Monday '
											when 4  then ' on Tuesday '
											when 8  then ' on Wednesday '
											when 16 then ' on Thursday '
											when 32 then ' on Friday '
											when 64 then ' on Saturday '
											else ' on '+ [dbo].[day_interval](max(s.freq_interval))
											end 
-----------------------------------------------------------------------------------
when max(s.freq_type) in (16) then ' on '+  (select 
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
when max(s.freq_type) in (4,8,16,32) and max(s.freq_subday_type) >= 1 then ' every ' + cast(max(s.freq_subday_interval) as varchar(20)) 
																		  + case 
																				max(freq_subday_type)
																				when 2 then case when max(s.freq_subday_interval) = 1 then ' Second' else ' Seconds' end
																				when 4 then case when max(s.freq_subday_interval) = 1 then ' Minute' else ' Minutes' end
																				when 8 then case when max(s.freq_subday_interval) = 1 then ' Hour' else ' Hours' end
																			end
																		  + case
																			when max(s.freq_type) in (4,8) and max(s.freq_subday_type) >= 1 --and max(s.freq_recurrence_factor) in (1) 
																			then ' between ' + 
																			case 
																				when len(max(s.active_start_time)) = 1 then '00:00:0'+ cast(max(s.active_start_time) as varchar(50))
																				when len(max(s.active_start_time)) = 2 then '00:00:'+ cast(max(s.active_start_time) as varchar(50))
																				when len(max(s.active_start_time)) = 3 then '00:0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)
																				when len(max(s.active_start_time)) = 4 then '00:'+ substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)
																				when len(max(s.active_start_time)) = 5 then '0'+ substring(cast(max(s.active_start_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_start_time) as varchar(50)),2,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),4,2)
																				when len(max(s.active_start_time)) = 6 then substring(cast(max(s.active_start_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),3,2)+':'+substring(cast(max(s.active_start_time) as varchar(50)),5,2)
																			end + ' and ' +	
																			case 
																				when len(max(s.active_end_time)) = 1 then '00:00:0'+ cast(max(s.active_end_time) as varchar(50))
																				when len(max(s.active_end_time)) = 2 then '00:00:'+ cast(max(s.active_end_time) as varchar(50))
																				when len(max(s.active_end_time)) = 3 then '00:0'+ substring(cast(max(s.active_end_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_end_time) as varchar(50)),2,2)
																				when len(max(s.active_end_time)) = 4 then '00:'+ substring(cast(max(s.active_end_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_end_time) as varchar(50)),3,2)
																				when len(max(s.active_end_time)) = 5 then '0'+ substring(cast(max(s.active_end_time) as varchar(50)),1,1)+':'+substring(cast(max(s.active_end_time) as varchar(50)),2,2)+':'+substring(cast(max(s.active_end_time) as varchar(50)),4,2)
																				when len(max(s.active_end_time)) = 6 then substring(cast(max(s.active_end_time) as varchar(50)),1,2)+':'+substring(cast(max(s.active_end_time) as varchar(50)),3,2)+':'+substring(cast(max(s.active_end_time) as varchar(50)),5,2)
																			end
																			else ''
																			end 
																		  + case 
																			when max(s.freq_type) in (8) then 
																				case max(s.freq_interval)
																				when 1  then ' on Sunday '
																				when 2  then ' on Monday '
																				when 4  then ' on Tuesday '
																				when 8  then ' on Wednesday '
																				when 16 then ' on Thursday '
																				when 32 then ' on Friday '
																				when 64 then ' on Saturday '
																				else ' on '+ [dbo].[day_interval](max(s.freq_interval)) 
																				end 
																			else ''
																			end
when max(s.freq_type) in (4) and max(s.freq_subday_type)  = 0 then 'mmmmmmmmmmmmm' 
else ''
end
, 'No schedule'), 'between 00:00:00 and 23:59:59','- The whole day') schedule_time,
max(s.enabled) schedule_enable, 
sum(case when h.step_id = 0 and h.run_status = 1 then 1 else 0 end) succes_running_times, 
sum(case when h.step_id = 0 and h.run_status = 0 then 1 else 0 end) failed_running_times, 
master.dbo.duration('s', min(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) min_run_duration,
master.dbo.duration('s', avg(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) avg_run_duration,
master.dbo.duration('s', max(case when h.step_id = 0 then 0 when h.step_id > 0 and h.run_status = 1 then h.run_duration end)) max_run_duration
from msdb.dbo.sysjobs j left outer join  msdb.dbo.sysjobhistory h
on h.job_id = j.job_id
left outer join msdb.dbo.sysjobschedules js
on j.job_id = js.job_id
left outer join msdb.dbo.sysschedules s
on js.schedule_id = s.schedule_id
--where j.name in ('Continue_Restore')
group by j.name, j.job_id
order by j.name


--select freq_type, freq_interval, freq_subday_type, freq_subday_interval, freq_relative_interval, freq_recurrence_factor, active_start_date, active_end_date, active_start_time, active_end_time
--from msdb.dbo.sysschedules where schedule_id = 58

