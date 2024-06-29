$sql = @(get-service -name "*sql*" | where {$_.DisplayName -like "SQL Server (*"} | select Name).name
net stop $sql
net start $sql /f /T3608

sqlcmd -S . -E

dbcc tracestatus
go

select count(*) from sys.server_audits where is_state_enabled = 1
go

declare @audit varchar(500), @sql varchar(1500);
declare audit_cursor cursor fast_forward
for
select name
from sys.server_audits
where is_state_enabled = 1;
open audit_cursor;
fetch next from audit_cursor into @audit;
while @@fetch_status = 0;
begin
set @sql = 'ALTER SERVER AUDIT ['+@audit+'] WITH (STATE=OFF)';
exec(@sql);
fetch next from audit_cursor into @audit;
end
close audit_cursor
deallocate audit_cursor
go
select count(*) from sys.server_audits where is_state_enabled = 1
go

exit

net stop $sql
net start $sql




