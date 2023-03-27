use master
go
create function dbo.is_primary()
returns int
as
begin
declare @result int
select @result = case when count(*) > 0 then 1 else 0 end
from sys.dm_hadr_availability_group_states
where primary_recovery_health = 1
return @result
end

select master.dbo.is_primary()

if master.dbo.is_primary() = 1
begin

print('do something')

end



--IF CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) >= 12 BEGIN --SQL 2014 and higher
--   PRINT 'SQL VERSION => 12'
--	   IF ISNULL([sys].[fn_hadr_is_primary_replica] (DB_NAME()), 1) = 0 BEGIN
--		  PRINT 'RAISEERROR'
--		  declare @logmsg nvarchar(max)=N''
--		  set @logmsg='This is not a primary AlwaysOn SQL Instance --> ServerName:'+@@SERVERNAME+' DB Name :'+DB_NAME()+' This Job will not be executed...'
--		  RAISERROR (@logmsg, 16, 1);
--		END
--	END
