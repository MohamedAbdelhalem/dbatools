declare @session_id int = 280
declare @running int = 1, @sql varchar(150)
declare @blocking_session_id varchar(100), @go int , @status varchar(100), @main_status varchar(100)
--while @running = 1
--begin

select @main_status = status
from sys.sysprocesses
where spid = @session_id

select 
@blocking_session_id = spid, 
@go = case when hostname in ('D1T24APUXPWV1','D1T24APUXPWV2','D1T24APUXPWV3','D1T24APUXPWV4','D2T24APUXPWV2','D2T24APUXPWV3','D2T24APUXPWV4') and status = 'sleeping' then 1 else 0 end, 
@status = status
from sys.sysprocesses 
where spid in (select blocked 
				 from sys.sysprocesses 
				where spid = @session_id)
if @go = 1 and @main_status != 'sleeping'
begin
set @sql = 'KILL '+@blocking_session_id
exec(@sql)
print(@sql)
--waitfor delay '00:00:01'
end
else
if @go = 0 and @main_status != 'sleeping'
begin
--waitfor delay '00:00:01'
print('session '+@blocking_session_id+' is still '+@status)
end
else
if @main_status = 'sleeping'
begin
set @running = 0
print('completed and its now sleeping')
end

--end
