--run this query from the R/W instance
use [master]
go
declare @rank int = 2, @min_id bigint, @waitfor_mins int = 5

select @min_id = min(id) from [10.36.1.212,17120].master.dbo.middleware_requests_summary2 where deleted = 0

select deleted, master.dbo.format(total,-1) total, 100 - cast(total / cast(sum(total) over() as float) * 100.0 as numeric(10,2)) percent_complete, time_to_complete
from (
select cast(count(*) as float) total, deleted, master.dbo.duration('s',cast(case when deleted = 1 then 0 else count(*) end as float) * @waitfor_mins) time_to_complete
from master.dbo.middleware_requests_summary2 
where id > (select id 
			   from (select row_number() over(partition by from_id order by id) rank_id, id 
					   from master.dbo.middleware_requests_summary2 
					  where from_id = 1)a 
			  where rank_id = @rank) 
and unique_id =1
and id >= @min_id
group by deleted)b

select 
j.name job_name, 
case when ja.stop_execution_date is null then 1 else 0 end is_running, 
ja.last_executed_step_date, 
case when ja.stop_execution_date is null then 'RUNNING' else master.dbo.duration('s',datediff(s, ja.last_executed_step_date, getdate())) end last_execution_since,
master.dbo.duration('s',case when ja.stop_execution_date is null then datediff(s, ja.last_executed_step_date, getdate()) else 0 end) duration
from msdb.dbo.sysjobs j left outer join msdb.dbo.sysjobactivity ja
on j.job_id = ja.job_id
where last_executed_step_date in  (select last_executed_step_date from
								(select max(last_executed_step_date) last_executed_step_date, name 
																from msdb.dbo.sysjobactivity jja inner join msdb.dbo.sysjobs jj 
																on jja.job_id = jj.job_id group by jj.name)a)
and j.name in ('PRODmfreportsdbBAB - Purge Monthly')
order by job_name
