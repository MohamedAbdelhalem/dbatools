;with recusive_sessions (spid, blocking_session_id, level)
as
(
select spid, blocking_session_id, 0 level
from (
select spid, case when spid in (select blocked from sys.sysprocesses) and blocked = 0 then NULL else blocked end blocking_session_id
from sys.sysprocesses)a
where blocking_session_id is null
union all
select sp.spid, sp.blocked, level + 1
from recusive_sessions rs inner join sys.sysprocesses sp
on rs.spid = sp.blocked
)
select isnull(rs.level,100) level, p.spid, 
case 
when p.status = 'suspended' and blocked > 0  then 1 
when p.status = 'suspended' and blocked = 0  then 2 
when p.status = 'Runnable'					 then 3
when p.status = 'Running'					 then 4		
when p.status = 'Sleeping' and open_tran = 1 then 5 
when p.status = 'Sleeping' and open_tran = 0 then 6 
else 5 end flag_status, percent_complete, DB_NAME(p.dbid), loginame, CPU,p.status,
blocked, waittime, lastwaittype, hostname, client_net_address, cmd, master.dbo.duration('s', datediff(s,start_time,getdate())) duration,
s.text, 
'declare '+ep.bind_variables +' = '+ ep.parameter_values bind_variables,
SUBSTRING(s.text, (stmt_start/2)+1, ((stmt_end/2)+1) - ((stmt_start/2)+1) + 1)
--, program_name
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
inner join sys.dm_exec_connections c
on p.spid = c.session_id
and c.net_transport = 'TCP'
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
--left outer join sys.dm_tran_locks tl
--on p.spid = tl.request_session_id
left outer join recusive_sessions rs 
on p.spid = rs.spid
left outer join (
select r.session_id, ex.*
from sys.dm_exec_requests r 
cross apply sys.dm_exec_query_plan(r.plan_handle)p_lan
cross apply master.dbo.fn_executionPlan_params(p_lan.query_plan) ex)ep
on p.spid = ep.session_id
where lastwaittype not in ('SP_SERVER_DIAGNOSTICS_SLEEP')
and loginame not in ('ALBILAD\SVC_SQLMonitor','ALBILAD\gMSA_SS_T24_19$')
and p.spid != @@SPID
--and text Like '%LOCK%'
order by level, flag_status, CPU desc, datediff(s,start_time,getdate()) desc, p.spid

--rightjustify (@sVal NVARCHAR(MAX))  RETURNS NVARCHAR(MAX) AS BEGIN   DECLARE @ValFinal int = 126;  DECLARE @paddingChar NVARCHAR(2)= '0';  DECLARE @valLength int = 0;  DECLARE @isNumeric bit = 0;  DECLARE @isPoint bit = 0;  DECLARE @dotPos int = 0;  DECLARE @rightJustify NVARCHAR(MAX)='';  DECLARE @pos int = 0;  DECLARE @i int = 1;   if @sVal is null or len(@sVal) = 0  begin   WHILE(@i <= 125)   begin    set @rightJustify = CONCAT(@rightJustify,@paddingChar);    set @i = @i + 1;   end  end  else  begin   set @isNumeric = 0;   set @isPoint = 0;   set @valLength = len(@sVal);   set @dotPos = @valLength;      set @i = @valLength;   while (@i >= 1) -- Reverse loop   begin    --test isnumeric    --test is .    --test is second dot    if SUBSTRING(@sVal,@i,1) = '.' and @isPoint = 0 -- first point    begin     set @isPoint = 1;     set @dotPos = @i;    end    else if dbo.tafjisnumeric(SUBSTRING(@sVal,@i,1)) = 0    begin     -- not a digit     set @isNumeric = 0;     set @dotPos = @valLength;     BREAK; -- no need to continue    end    else    begin     -- its a digit     set @isNumeric = 1;    end    set @i = @i - 1;   end   if @isNumeric = 1   begin    --PAD with 0 until not decimal part put point at 127 characters and put decimal part    set @pos = CHARINDEX('.',@sVal);    if @pos = 1    begin     return CONCAT(RIGHT(REPLICATE('0',@ValFinal)+ '0',@ValFinal),CONCAT('.',SUBSTRING(@sVal,@pos + 1,len(@sVal))));    end    else if @pos > 1    begin     return CONCAT(RIGHT(REPLICATE('0',@ValFinal - @pos + 1) + '0',@ValFinal - @pos + 1),CONCAT(SUBSTRING(@sVal,1,@pos),SUBSTRING(@sVal,@pos + 1,len(@sVal))));     end    else    begin     return RIGHT(REPLICATE('0',@ValFinal) + @sVal, @ValFinal);    end   end   else   begin    return RIGHT(REPLICATE('0',@ValFinal) + @sVal, @ValFinal);   end  end  return @rightJustify; end; 
--D1T24APUXPWV2

--select * from sys.dm_exec_input_buffer(2547,0)
--select * from sys.dm_exec_input_buffer(2402,0)
