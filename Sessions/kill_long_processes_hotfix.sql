create procedure kill_long_processes_hotfix 
as
begin
declare @table_kill table (session_id int, spid varchar(100), date_diff int, database_name varchar(350), sql_text nvarchar(max))
insert into @table_kill
select session_id, spid, date_diff, database_name, sql_value
from (
select 'KILL '+cast(session_id as varchar(10)) spid, session_id, datediff(minute, r.start_time, getdate()) date_diff, db_name(p.dbid) [database_name], 
s.text, sep.id, ltrim(rtrim(sep.value)) sql_value
from sys.sysprocesses p inner join sys.dm_exec_requests r 
on p.spid = r.session_id
cross apply sys.dm_exec_sql_text(r.sql_handle)s
cross apply master.dbo.Separator(s.text, char(10))sep)a

declare @kill varchar(100), @spid varchar(100)
declare kill_long_process cursor fast_forward
for
select spid
from @table_kill
where ltrim(rtrim(replace(replace(sql_text,']',''),'[',''))) like '%CREATE PROCEDURE dbo.OUTPUT_FORMATTER%'
and session_id != @@spid
and date_diff >= 5
and database_name = 'POS_BIB_STMNT_PRD'

open kill_long_process
fetch next from kill_long_process into @spid
while @@FETCH_STATUS = 0
begin

exec(@spid)
fetch next from kill_long_process into @spid
end
close kill_long_process 
deallocate kill_long_process 

end
