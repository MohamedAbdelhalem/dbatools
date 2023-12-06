Create procedure drop_xevents
as
begin
declare @spid varchar(200)
declare drop_xevents cursor fast_forward
for
select reverse(substring(reverse(name),1,CHARINDEX('_',reverse(name))-1))
from sys.dm_xe_sessions 
where name like 'Restore_Error_Handling_spid%'

open drop_xevents
fetch next from drop_xevents into @spid
while @@FETCH_STATUS = 0
begin

exec [dbo].[XEvent_errors] @spid, 0

fetch next from drop_xevents into @spid
end
close drop_xevents
deallocate drop_xevents
end
