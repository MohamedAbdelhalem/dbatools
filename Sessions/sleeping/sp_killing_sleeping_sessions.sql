USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_killing_sleeping_sessions]    Script Date: 8/31/2023 10:34:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_killing_sleeping_sessions]
as
begin

declare @sql varchar(max), @status varchar(100), @sql_text varchar(max), @cmd varchar(100),@sec bigint, @duration varchar(100), @hostname varchar(100)
declare kill_sleeping_sessions cursor fast_forward
for
select kill_spid, status, cmd,sec, sql_text, duration, hostname 
from (
select spid, status, cmd, s.text sql_text, master.dbo.duration('s',(datediff(s,last_batch,getdate()))) duration,hostname,datediff(s,last_batch,getdate()) sec,
case 
when hostname in (--here put the hosts that you need to kill related sessions between 08:00 AM till 06:00 PM and more than 5 minutes
 'D2T24APUXPWV1') 
and (datediff(s,last_batch,getdate()) / 60.0) >= 60 
and GETDATE() between dateadd(hour, 23,convert(varchar(10),GETDATE(),120)) and dateadd(minute,2,dateadd(hour,23,convert(varchar(10),GETDATE(),120)))
then 'KILL '+CAST(spid as varchar(20))
when hostname in (--here put the hosts that you need to kill related sessions between 08:00 AM till 06:00 PM and more than 5 minutes
 'D1T24APUXPWV1'
,'D1T24APUXPWV2'
,'D1T24APUXPWV3'
,'D1T24APUXPWV4'
,'D2T24APUXPWV2'
,'D2T24APUXPWV3'
,'D2T24APUXPWV4') 
and (datediff(s,last_batch,getdate()) / 60.0) >= 5 
and GETDATE() between dateadd(hour, 8,convert(varchar(10),GETDATE(),120)) and dateadd(hour,18,convert(varchar(10),GETDATE(),120))
then 'KILL '+CAST(spid as varchar(20))
when hostname in (--here put the hosts that you need to kill related sessions all time more than 5 minutes
 'D1T24APCHPWV1'
,'D1T24APCHPWV2'
,'D1T24APCHPWV3'
,'D2T24APCHRWV1'
,'D2T24APCHRWV2'
,'D2T24APCHRWV3') 
and (datediff(s,last_batch,getdate()) / 60.0) >= 5 
then 'KILL '+CAST(spid as varchar(20))
when hostname in (--here put the hosts that you need to kill related sessions between 05:00 AM till 11:45 PM and more than 1 hour
 'D1T24APSEPWV1'
,'D1T24APDWPWV1'
,'D2T24APSEPWV1'
,'D2T24APDWRWV1') 
and (datediff(s,last_batch,getdate()) / 60.0) >= 60 
and GETDATE() between dateadd(hour,5,convert(varchar(10),GETDATE(),120)) and dateadd(minute,45,dateadd(hour, 23,convert(varchar(10),GETDATE(),120)))
then 'KILL '+CAST(spid as varchar(20))
else NULL end kill_spid
from sys.sysprocesses  p cross apply sys.dm_exec_sql_text(p.sql_handle)s
where status = 'sleeping' 
and spid > 50
and db_name(p.dbid) = 'T24prod'
and loginame= 't24prod'
and datediff(s,last_batch,getdate()) >= (5 * 60))a
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


