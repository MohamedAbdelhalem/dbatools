declare 
@serverName varchar(200) = 'EHSAN-DB1-N',
@from		varchar(200) = '2024-04-02 10:30:00',
@to			varchar(200) = '2024-04-02 11:30:00',
@id			int = 1
declare @sysprocesses table (id int, 
CollectDate	varchar(30), session_id int, sql_text nvarchar(max), 
wait_info varchar(100), 
waittime bigint, lastwaittype varchar(100),
waiting_key varchar(200), 
blocking_session_id int, 
CPU bigint, reads bigint, writes bigint, physical_reads bigint, status varchar(100), host_name varchar(300), program_name varchar(300))

declare @sysprocesses2 table (id int, level bigint, session_id int, blocking_session_id int, collectdate datetime, flag_status int, CPU int, status varchar(100),
wait_info varchar(100), waittime int, lastwaittype varchar(100),
waiting_key varchar(200), 
host_name varchar(300), sql_text varchar(max), program_name varchar(300))

insert into @sysprocesses
select b.id, a.*
from (
select 
convert(varchar(25),[CollectDate],121) CollectDate
,[session_id]
,[sql_text], wait_info
,cast(replace(replace(replace(substring([wait_info],1,CHARINDEX(')',[wait_info])-1),'(',''),'ms',''),',','') as float) waittime
,substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), 1, CHARINDEX(' ', substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))-1) lastwaittype
,ltrim(rtrim(substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), CHARINDEX(' ',substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))+1,LEN(wait_info)))) waiting_key
,blocking_session_id
,sum([CPU])[CPU]
,sum([reads])[reads]
,sum([writes])[writes]
,sum([physical_reads])[physical_reads]
,[status]
,[host_name]
,[program_name]
FROM [MonitoringDB].[dbo].[TBL2_M_WhoIsActive]
where InstanceID = (select InstanceID from META2_M_InstanceInfo where ServerName = @serverName)
and collectdate between @from and @to
and LEN(wait_info) > 5
and sql_text not in ('sp_server_diagnostics','COMMIT TRAN')
group by convert(varchar(25),[CollectDate],121)
,[session_id]
,[sql_text]
,blocking_session_id, wait_info
,[status]
,[host_name]
,[program_name])a
inner join (
select row_number() over(order by convert(varchar(25),[CollectDate],121)) id,
count(*) c, convert(varchar(25),[CollectDate],121) [CollectDate]
FROM [MonitoringDB].[dbo].[TBL2_M_WhoIsActive]
where InstanceID = (select InstanceID from META2_M_InstanceInfo where ServerName = @serverName)
and collectdate between @from and @to
and LEN(wait_info) > 5
and sql_text not in ('sp_server_diagnostics','COMMIT TRAN')
group by convert(varchar(25),[CollectDate],121)
)b
on a.CollectDate = b.CollectDate
order by a.[CollectDate], a.session_id

while @id < (select max(id)
from (
select row_number() over(order by convert(varchar(25),[CollectDate],121)) id,
count(*) c, convert(varchar(25),[CollectDate],121) [CollectDate]
FROM [MonitoringDB].[dbo].[TBL2_M_WhoIsActive]
where InstanceID = (select InstanceID from META2_M_InstanceInfo where ServerName = @serverName)
and collectdate between @from and @to
and LEN(wait_info) > 5
and sql_text not in ('sp_server_diagnostics','COMMIT TRAN')
group by convert(varchar(25),[CollectDate],121))a
)
begin

;with recusive_sessions (spid, blocking_session_id, level)
as
(
select session_id, blocking_session_id, 0 level
from (
select session_id, case when 
session_id in (select blocking_session_id from @sysprocesses where id = @id) 
and blocking_session_id = 0 then NULL else blocking_session_id end blocking_session_id
from @sysprocesses
where id = @id)a
where blocking_session_id is null
union all
select sp.session_id, sp.blocking_session_id, level + 1
from recusive_sessions rs inner join @sysprocesses sp
on rs.spid = sp.blocking_session_id
where id = @id
)
insert into @sysprocesses2
select distinct @id, isnull(rs.level,10000) level, p.session_id, p.blocking_session_id, collectdate,
case 
when p.status = 'suspended' and p.blocking_session_id > 0  then 1 
when p.status = 'suspended' and p.blocking_session_id = 0  then 2 
when p.status = 'Runnable'					 then 3
when p.status = 'Running'					 then 4		
else 5 end flag_status,
--percent_complete, DB_NAME(p.dbid), loginame, 
CPU,p.status, wait_info, waittime, lastwaittype, waiting_key,
host_name, 
sql_text, program_name
from @sysprocesses p left outer join recusive_sessions rs 
on p.session_id = rs.spid
where id = @id
order by level, flag_status, p.session_id, CPU desc

--select * from TBL2_M_WhoIsActive
--where InstanceID = 4
--and convert(varchar(16),CollectDate,120) = '2024-04-02 10:50'
set @id += 1
end

select * from @sysprocesses2
where sql_text not like '%backup%'
and status not in ('background')
and level != 10000
order by id, level
