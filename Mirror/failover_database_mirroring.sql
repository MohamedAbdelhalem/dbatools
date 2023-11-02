declare @action int = 1
--1 = only print
--2 = only execute
--3 = print + execute

declare @mirror_database varchar(255), @sql varchar(max), @count_mirror_Safety_OFF int
declare change_to_sync cursor fast_forward
for
select DB_NAME(database_id) 
from sys.database_mirroring
where mirroring_role = 1
and mirroring_safety_level = 1

select @count_mirror_Safety_OFF = count(*)
from sys.database_mirroring
where mirroring_role = 1
and mirroring_safety_level = 1

open change_to_sync
fetch next from change_to_sync into @mirror_database
while @@FETCH_STATUS = 0
begin

set @sql = 'ALTER DATABASE ['+@mirror_database+'] SET SAFETY FULL'

if @action = 1
begin
print(@sql)
end
else
if @action = 2
begin
exec(@sql)
end
else
if @action = 3
begin
exec(@sql)
print(@sql)
end

fetch next from change_to_sync into @mirror_database
end
close change_to_sync
deallocate change_to_sync

if @count_mirror_Safety_OFF > 0
begin
	if @action in (2,3)
	begin
		waitfor delay '00:00:20'
	end
end


declare failover_sync_dbs cursor fast_forward
for
select DB_NAME(database_id) 
from sys.database_mirroring
where mirroring_role = 1
and mirroring_safety_level = 2

open failover_sync_dbs
fetch next from failover_sync_dbs into @mirror_database
while @@FETCH_STATUS = 0
begin

set @sql = 'ALTER DATABASE ['+@mirror_database+'] SET PARTNER FAILOVER'

if @action = 1
begin
print(@sql)
end
else
if @action = 2
begin
exec(@sql)
waitfor delay '00:00:05'
end
else
if @action = 3
begin
exec(@sql)
print(@sql)
waitfor delay '00:00:05'
end


fetch next from failover_sync_dbs into @mirror_database
end
close failover_sync_dbs
deallocate failover_sync_dbs

