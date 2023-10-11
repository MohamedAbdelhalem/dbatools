declare @vol varchar(10) = 'P'
declare @sql varchar(max)= '
select [Disk], min([date]) min_date, max([date]) max_date, datediff(day, min([date]), max([date])) days_diff,
master.dbo.numbersize(min(diff_size_mb),''mb'') diff_size_min,
master.dbo.numbersize(avg(diff_size_mb),''mb'') diff_size_avg,
master.dbo.numbersize(max(diff_size_mb),''mb'') diff_size_max,
master.dbo.numbersize(avg(diff_size_mb) * datediff(day, min([date]), max([date])) ,''mb'') recommended_size_in_day_diff,
master.dbo.numbersize(avg(diff_size_mb) * (30 * 6) ,''mb'') recommended_size_in_day_diff
from (
select id, '+''''+@vol+''''+' [Disk], [date], FORMAT(cast([date] as datetime),''dddd'') week_day, master.dbo.numbersize(isnull(value,0),''mb'') value,
master.dbo.numbersize(case when value - lag(isnull(value,0), 1) over(order by id) < 0 then 0 else value - lag(isnull(value,0), 1) over(order by id) end,''mb'') diff_size,
case when value - lag(isnull(value,0), 1) over(order by id) < 0 then 0 else value - lag(isnull(value,0), 1) over(order by id) end diff_size_mb,
LAG(isnull(value,0), 1) over(order by id) minus_1
from (
select row_number() over(order by convert(varchar(10), date,120)) id, convert(varchar(10), date,120) [date], max([Minimum value]) value
from [dbo].DATAHUB_'+@vol+'$
group by convert(varchar(10), date,120))a --order by
)b group by disk

select id, '+''''+@vol+''''+' [Disk], [date], FORMAT(cast([date] as datetime),''dddd'') week_day, 
master.dbo.numbersize(isnull(value,0),''mb'') value,
master.dbo.numbersize(case when value - lag(isnull(value,0), 1) over(order by id) < 0 then 0 else value - lag(isnull(value,0), 1) over(order by id) end,''mb'') diff_size,
case when value - lag(isnull(value,0), 1) over(order by id) < 0 then 0 else value - lag(isnull(value,0), 1) over(order by id) end diff_size_mb,
LAG(isnull(value,0), 1) over(order by id) minus_1
from (
select row_number() over(order by convert(varchar(10), date,120)) id, convert(varchar(10), date,120) [date], max([Minimum value]) value
from [dbo].DATAHUB_'+@vol+'$
group by convert(varchar(10), date,120))a --order by'

exec (@sql)
