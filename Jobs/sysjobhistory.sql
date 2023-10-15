select job_name, step_id, step_name, run_time, run_duration, day_name, run_status
from (
select j.name job_name, step_id, step_name, run_status,
case datepart(weekday, convert(datetime,
convert(varchar(10),convert(datetime,cast(run_date as varchar(30)),112),120)+' '+
case 
when len(run_time) = 1 then '00:00:0'+ cast(run_time as varchar(50))
when len(run_time) = 2 then '00:00:'+ cast(run_time as varchar(50))
when len(run_time) = 3 then '00:0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)
when len(run_time) = 4 then '00:'+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)
when len(run_time) = 5 then '0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)+':'+substring(cast(run_time as varchar(50)),4,2)
when len(run_time) = 6 then ''+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)+':'+substring(cast(run_time as varchar(50)),5,2)
end
,120))
when 1 then 'Sunday'
when 2 then 'Monday'
when 3 then 'Tuesday'
when 4 then 'Wednesday'
when 5 then 'Thursday'
when 6 then 'Friday'
when 7 then 'Saturday'
end day_name,
convert(datetime,
convert(varchar(10),convert(datetime,cast(run_date as varchar(30)),112),120)+' '+
case 
when len(run_time) = 1 then '00:00:0'+ cast(run_time as varchar(50))
when len(run_time) = 2 then '00:00:'+ cast(run_time as varchar(50))
when len(run_time) = 3 then '00:0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)
when len(run_time) = 4 then '00:'+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)
when len(run_time) = 5 then '0'+ substring(cast(run_time as varchar(50)),1,1)+':'+substring(cast(run_time as varchar(50)),2,2)+':'+substring(cast(run_time as varchar(50)),4,2)
when len(run_time) = 6 then ''+ substring(cast(run_time as varchar(50)),1,2)+':'+substring(cast(run_time as varchar(50)),3,2)+':'+substring(cast(run_time as varchar(50)),5,2)
end
,120) run_time,
case 
when len(run_duration) = 1 then '00h:00m:0'+ cast(run_duration as varchar(50))+'s'
when len(run_duration) = 2 then '00h:00m:'+ cast(run_duration as varchar(50))+'s'
when len(run_duration) = 3 then '00h:0'+ substring(cast(run_duration as varchar(50)),1,1)+'m:'+substring(cast(run_duration as varchar(50)),2,2)+'s'
when len(run_duration) = 4 then '00h:'+ substring(cast(run_duration as varchar(50)),1,2)+'m:'+substring(cast(run_duration as varchar(50)),3,2)+'s'
when len(run_duration) = 5 then '0'+ substring(cast(run_duration as varchar(50)),1,1)+'h:'+substring(cast(run_duration as varchar(50)),2,2)+'m:'+substring(cast(run_duration as varchar(50)),4,2)+'s'
when len(run_duration) = 6 then ''+ substring(cast(run_duration as varchar(50)),1,2)+'h:'+substring(cast(run_duration as varchar(50)),3,2)+'m:'+substring(cast(run_duration as varchar(50)),5,2)+'s'
end
run_duration
from msdb..sysjobhistory jh inner join msdb..sysjobs j
on jh.job_id = j.job_id)a
where job_name ='Automatic Restore Job'
--and step_id = 1
--and step_name = 'before update'
--and run_time >= '2023-09-05'
--and day_name = 'Saturday'
order by run_time, job_name, step_id
