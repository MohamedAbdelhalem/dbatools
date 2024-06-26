USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_killing_sleeping_sessions]    Script Date: 9/3/2023 3:58:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter procedure [dbo].[sp_killing_sleeping_sessions_all]
(@mins int = 60)
as
begin

declare @sql varchar(max), @status varchar(100), @sql_text varchar(max), @cmd varchar(100),@sec bigint, @duration varchar(100), @hostname varchar(100)
declare kill_sleeping_sessions cursor fast_forward
for
select kill_spid, status, cmd,sec, sql_text, duration, hostname 
from (
select spid, status, cmd, s.text sql_text, master.dbo.duration('s',(datediff(s,last_batch,getdate()))) duration,hostname,datediff(s,last_batch,getdate()) sec,
'KILL '+CAST(spid as varchar(20)) kill_spid
from sys.sysprocesses  p cross apply sys.dm_exec_sql_text(p.sql_handle)s
where status = 'sleeping' 
and spid > 50
and db_name(p.dbid) = 'T24prod'
and loginame= 't24prod'
and datediff(s,last_batch,getdate()) >= (@mins * 60))a
where kill_spid is not null
order by a.sec desc

open kill_sleeping_sessions
fetch next from kill_sleeping_sessions into @sql, @status, @cmd, @sec, @sql_text, @duration, @hostname
while @@FETCH_STATUS = 0
begin

insert into sleeping_sessions 
(killed_spid, hostname, status, cmd, sec, sql_text, duration)
values (@sql, @hostname, @status, @cmd, @sec, @sql_text, @duration)

exec(@sql)

fetch next from kill_sleeping_sessions into @sql, @status, @cmd, @sec, @sql_text, @duration, @hostname
end
close kill_sleeping_sessions
deallocate kill_sleeping_sessions

end

select * from sleeping_sessions
