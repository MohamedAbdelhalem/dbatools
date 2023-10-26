use master
go
select 
row_number() over(order by j.name) [#],
j.name job_name, max(j.enabled) job_enable, isnull(max(s.enabled),0) schedule_enable,
replace(isnull(
case 
	when max(s.freq_type) = 1					then 'One time only'
	when max(s.freq_type) = 4 and max(s.freq_subday_type) = 1	then 'Once a Day'
	when max(s.freq_type) = 4 and max(s.freq_subday_type) > 1	then 'Daily'
	when max(s.freq_type) = 8					then 'Weekly'
	when max(s.freq_type) in (16,32)				then 'Monthly'
	when max(s.freq_type) = 64					then 'Runs when the SQL Server Agent service starts'
	when max(s.freq_type) = 128					then 'Runs when the computer is idle'
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
when max(s.freq_type) in (32) then	
	case max(s.freq_interval)
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
, 'No schedule'), 'between 00:00:00 and 23:59:59','- The whole day') schedule_time
from msdb.dbo.sysjobs j left outer join  msdb.dbo.sysjobhistory h
on h.job_id = j.job_id
left outer join msdb.dbo.sysjobschedules js
on j.job_id = js.job_id
left outer join msdb.dbo.sysschedules s
on js.schedule_id = s.schedule_id
--where j.name in ('Var_to_nVarchar','Continue_Restore','Var_to_nVarchar_non_clustered_indexes')
group by j.name, j.job_id
order by j.name

