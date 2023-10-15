use [T24Prod]
go
declare @table table (id int, table_name varchar(1000), index_name varchar(1000), activity_name varchar(100), before datetime, after datetime, table_size varchar(20), size bigint, time_elapsed varchar(30), table_time_elapsed varchar(30))
insert into @table
select ROW_NUMBER() over(order by [before], table_name) id,
[table_name], index_name, activity_name, [before], [after], 
master.dbo.numberSize(table_size * 8.0, 'k') table_size,
table_size size,
master.dbo.duration('s', DATEDIFF(s, [before], isnull([after],getdate()))) time_elapsed,
master.dbo.duration('s', sum(DATEDIFF(s, [before], isnull([after],getdate()))) over(PARTITION by table_name order by [before])) all_time_elapsed
from (
select ac.[table_name]
      ,ac.[index_name]
      ,ac.[activity_status]
      ,ac.[activity_name]
      ,ac.[action_time]
      ,cl.[table_size]
from [dbo].[activity_convert_var_to_nvar_log] ac inner join clustered_indexes_of_converted_tables cl
on ac.table_name = cl.table_name) a
pivot (max(action_time) for activity_status in ([before],[after]))p
order by id


select b.table_name, b.index_name, t.table_size,
[drop primary key], 
[column convert], 
[create primary key],
t.table_time_elapsed
from (
select * 
from (
select top 100 percent table_name, index_name, activity_name, time_elapsed 
from @table
order by id) a pivot (max(Time_elapsed) for activity_name in ([drop primary key],[column convert],[create primary key]))p)b
left outer join (select max(id)id, max(table_time_elapsed) table_time_elapsed, table_name, table_size from @table group by table_name, table_size) t
on b.table_name = t.table_name
order by id desc



--select count(*), table_name 
--from [dbo].[activity_convert_var_to_nvar_log] 
--group by table_name 
--order by count(*) 
