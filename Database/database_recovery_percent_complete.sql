declare @table table (id int identity(1,1), logDate datetime, ProcessInfo varchar(200), Text varchar(max))
insert into @table
exec [sys].[sp_readerrorlog] 0

select 
database_name, state_desc, log_reuse_wait_desc, user_access_desc,
convert(varchar(10),dateadd(s,cast(substring(remaining_time,1, charindex(' ',remaining_time)-1) as bigint),'2000-01-01'),108) remain_formatted, 
substring(remaining_time,1,len(remaining_time)-1) remaining_time, 
full_Text
from (
select replace(substring(Text,1,charindex(' ',Text)-1),'''','') database_name, ltrim(rtrim(substring(Text,charindex('approximately',Text)+14,len(Text)))) remaining_time, full_Text
from (
select ltrim(rtrim(substring(Text,1, charindex('.',Text)-1))) Text, full_Text
from (
select substring(Text,charindex('database',Text)+9, len(Text)) Text, Text full_Text
from @table
where text like 'Recovery%approximately%'
and id in (select max(id) from @table where text like 'Recovery%approximately%'))a)b)c
inner join sys.databases db
on c.database_name = db.name

select session_id, percent_complete, command, status, start_time, master.dbo.duration('s',datediff(s,start_time,getdate())) 
from sys.dm_exec_requests
where command = 'db startup'

select count(*), object_name from sys.dm_os_performance_counters
group by object_name
order by object_name



