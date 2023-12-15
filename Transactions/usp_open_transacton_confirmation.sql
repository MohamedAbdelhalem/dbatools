CREATE Procedure [dbo].[usp_open_transacton_confirmation]
as
begin
declare 
@exists_flag	int, 
@by_who			int, 
@spid			int,
@tr				varchar(max), 
@th				varchar(max),
@html			varchar(max),
@loop			int = 0,
@release_date	varchar(50),
@duration		varchar(50), 
@tsql			varchar(max)

set nocount on

declare @errorlog table (LogDate datetime, ProcessInfo varchar(50), [Text] varchar(2000))
declare @done_sessions table (session_id int)
declare @confirmation table (id int identity(1,1), row_id int, tr varchar(1000))
Declare @RecepientsPart1 VARCHAR(2000) = 'mailgroup_dba@bankalbilad.com;Data_center@bankalbilad.com;t24_production@bankalbilad.com'
Declare @RecepientsPart2 VARCHAR(2000) = 'MFawzyAlHaleem@bankalbilad.com;sabdullahalballaa@bankalbilad.com;nayedalhajri@bankalbilad.com'
Declare @EmailPart1_subject AS NVARCHAR(500)
SET @EmailPart1_subject = 'Confirmation - T24 Open Transaction by T24 APP Account on DB Server  ' + +( CAST(( SELECT  SERVERPROPERTY('ServerName')) AS NVARCHAR) )
Declare @MailProfile VARCHAR(100) = 'DBAlert'

if exists (select * from dbo.DBmonitor_long_transactions_log where [status] = 0 and [replica_name] = @@SERVERNAME)
begin

	insert into @done_sessions
	select session_id
	from (
	select 
	case 
	when DATEDIFF (minute,isnull(tat.transaction_begin_time, r.[start_time]) , GETDATE()) is null then 1 
	when DATEDIFF (minute,isnull(tat.transaction_begin_time, r.[start_time]) , GETDATE()) < 5    then 1 
	when mlog.[Begin Time] = isnull(tat.transaction_begin_time, r.[start_time]) then 0 end  done,
	mlog.session_id
	from dbo.DBmonitor_long_transactions_log mlog left outer join sys.dm_exec_requests r
	on mlog.session_id = r.session_id
	left outer join sys.dm_tran_session_transactions tst
	on tst.session_id = r.session_id
	left outer join sys.dm_tran_active_transactions tat
	on tat.transaction_id = tst.transaction_id
	where mlog.session_id in (
						select session_id 
						from dbo.DBmonitor_long_transactions_log
						where [status] = 0
						and [replica_name] = @@SERVERNAME
						)
	)a
    where done = 1
	order by session_id, done desc

if exists (select * from @done_sessions)
begin
insert into @errorlog
exec sp_readerrorlog 0

declare conf_cursor cursor fast_forward
for
select by_who, spid, master.dbo.duration('s', datediff(s,[Begin Time], case when by_who = 1 then LogDate else getdate() end)), TSQLCommand
from (
select ROW_NUMBER() over(partition by spid order by by_who desc) id, by_who, spid, LogDate, [Begin Time], TSQLCommand
from (
select 1 by_who, spid, LogDate, dbm.[Begin Time], dbm.TSQLCommand --1 means killed
from (
select LogDate, master.dbo.vertical_array([Text], ' ', 3) spid -- get the spids from the error log
from @errorlog
where [Text] like 'Process ID%was killed%')a inner join dbo.DBmonitor_long_transactions_log dbm
on a.spid = dbm.session_id
where a.spid in (select session_id from @done_sessions)
and dbm.[status] = 0 
and dbm.[replica_name] = @@SERVERNAME 
and LogDate between dateadd(SECOND, -90, getdate()) and getdate()
union all -- for speed i need all results
select 0, session_id, NULL, [Begin Time], TSQLCommand  -- 0 means by itself
from dbo.DBmonitor_long_transactions_log 
where [status] = 0
and [replica_name] = @@SERVERNAME
and session_id in (select session_id from @done_sessions)
)b)c
where id = 1

select @th = isnull(@th+'
','')+'<th style="border:1px solid gray;color: "gray">'+name+'</th>'
from (
select 1 column_id, '#' name
union
select 2, 'Session_Id' name
union
select 3, 'Confirmation_Reason' name
union
select 4, 'Release_Datetime' name
union
select 5, 'Session_Duration' name
union
select 6, 'TSQL_Text' name
)a
order by column_id

select @release_date = CONVERT(varchar(10),getdate(),120)+' '+
case when master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) < 12 then master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) 
else case when len(cast(master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) as int) - 12) = 1 
then '0'+cast(cast(master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) as int) - 12 as varchar(10))
else cast(cast(master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) as int) - 12 as varchar(10)) end end+':'+
master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',2)+':'+
master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',3)+' '+
case when master.dbo.vertical_array(CONVERT(varchar(10),dateadd(hour,0,getdate()),108),':',1) < 12 then 'AM' else 'PM' end

open conf_cursor
fetch next from conf_cursor into @by_who, @spid, @duration, @tsql
while @@FETCH_STATUS = 0
begin
set @loop = @loop + 1
insert into @confirmation
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+cast(@loop as varchar(100))+'</font></td>'
union all 
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+cast(@spid as varchar(100))+'</font></td>'
union all 
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+case @by_who when 1 then 'It was killed.' else 'It was finished by itself.' end+'</font></td>'
union all 
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+@release_date+'</font></td>'
union all 
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+@duration+'</font></td>'
union all 
select @loop, '<td style="border:1px solid gray; text-align: center; vertical-align: middle; font face="Verdana" size="1" color="gray">'+@tsql+'</font></td>'
fetch next from conf_cursor into @by_who, @spid, @duration, @tsql
end
close conf_cursor
deallocate conf_cursor

select @tr = isnull(@tr+'
','') +
case 
when col_position = 1 then
'</tr>
  <tr style="border:1px solid gray; text-align: center; vertical-align: middle;">
  '+tr
when col_position = col_count then
tr+'
</tr>'
else 
tr
end
from (
select top 100 percent row_number() over(partition by row_id order by id) col_position,id,row_id,6 col_count,tr 
from @confirmation
order by id, row_id)a

declare @table varchar(max) = '
<html>
<body>
<p>Dears,</p>

<p>Kindly be informed that the below session(s) has/have been done and is/are no longer a threat for the below reason(s).</p> 

<table style="border:1px solid black;border-collapse:collapse;width: 100%;">
<tr bgcolor="Azure">
'+@th+'
'+@tr+'
'+'</table>

<p>Thanks a lot.<br>Database Team..</br></p>
'

set @html = @table
print(@html)

EXEC msdb.dbo.sp_send_dbmail 
@profile_name = @MailProfile,
@recipients = @RecepientsPart1, 
@body = @html,
@body_format = 'HTML', 
@subject = @EmailPart1_subject	

update dbo.DBmonitor_long_transactions_log 
set 
[status] = 1,
[release_date] = GETDATE()
where [replica_name] = @@SERVERNAME 
and session_id in (select session_id from @done_sessions)

end
end

set nocount off
end
