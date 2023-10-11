declare 
@database_name			varchar(max) = '*', 
@except_db				varchar(max) = '0',
@file_type				varchar(10)  = '*',
@drive_letter_original	varchar(1)	 = 'E',
@drive_letter_new		varchar(1)	 = 'H'

declare @sql varchar(max), @loop int = 0, @action varchar(100), @action_id int, @action_step varchar(1500), @database_id int
declare @dbs table (database_id bigint)
declare @actions table (database_id int, action_id int, action_step varchar(1500))

set nocount on
if @database_name != '*'
begin
insert into @dbs
select db.database_id
from sys.databases db
where database_id > 1 
and db.name in (select ltrim(rtrim(value)) from master.dbo.Separator(@database_name,','))
and db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
end
else
begin
insert into @dbs
select db.database_id
from sys.databases db
where database_id > 1 
and db.name not in (select ltrim(rtrim(value)) from master.dbo.Separator(@except_db,','))
end
while @loop < 8
begin

set @action = case @loop 
when 0 then 'HADR_Primary_remove'
when 1 then 'mkdir'
when 2 then 'alter'
when 3 then 'offline'
when 4 then 'copy'
when 5 then 'online'
when 6 then 'HADR_Primary_add'
when 7 then 'HADR_Secondary_add'
end

insert into @actions 
select distinct mf.database_id, @loop, case @action 
when 'mkdir' then
'mkdir "'+reverse(substring(reverse(@drive_letter_new+substring(physical_name,2,len(physical_name))),charindex('\',reverse(@drive_letter_new+substring(physical_name,2,len(physical_name)))),len(reverse(@drive_letter_new+substring(physical_name,2,len(physical_name))))))+'"' 
when 'copy' then
'Copy /v "'+@drive_letter_original+substring(physical_name,2,len(physical_name))+'" "'+@drive_letter_new+substring(physical_name,2,len(physical_name))+'"' 
when 'alter' then
'ALTER DATABASE ['+db_name(mf.database_id)+'] modify file (name='+''''+name+''''+', filename='+''''+@drive_letter_new+substring(physical_name,2,len(physical_name))+''''+');' 
when 'offline' then
'ALTER DATABASE ['+db_name(mf.database_id)+'] set offline with rollback immediate;' 
when 'online' then
'ALTER DATABASE ['+db_name(mf.database_id)+'] set online;' 
when 'HADR_Primary_remove' then
'ALTER AVAILABILITY GROUP ['+a.ag_name+'] REMOVE DATABASE ['+db_name(mf.database_id)+'];' --ALTER AVAILABILITY GROUP [DH_AG] REMOVE DATABASE [Test_database_for_AGsync];
when 'HADR_Primary_add' then
'ALTER AVAILABILITY GROUP ['+a.ag_name+'] ADD DATABASE ['+db_name(mf.database_id)+'];' --ALTER AVAILABILITY GROUP [DH_AG] REMOVE DATABASE [Test_database_for_AGsync];
when 'HADR_Secondary_add' then
'ALTER DATABASE ['+db_name(mf.database_id)+'] set HADR AVAILABILITY GROUP = ['+a.ag_name+'];' --ALTER DATABASE [ReportServerTempDB] SET HADR AVAILABILITY GROUP = [TFS_HAG];
end
from sys.master_files mf left outer join (select database_id, ag.name ag_name 
										 from sys.availability_groups ag inner join sys.dm_hadr_database_replica_states dbrs 
										 on ag.group_id = dbrs.group_id
										 where dbrs.is_local = 1) a
on mf.database_id = a.database_id
where mf.database_id > 4
and mf.database_id in (select database_id from @dbs)
and case when @file_type = '*' then -1 else type end = case @file_type when 'data' then 0 when 'log' then 1 else -1 end --to work on data or log or both
and case when @action in ('offline','online') then '0' else left(physical_name,1) end = case when @action in ('offline','online') then '0' else @drive_letter_original end

set @loop = @loop +1
end

declare actions_cursor cursor fast_forward
for
select distinct action_id, action_step
from @actions
where action_step is not null
order by action_id

open actions_cursor
fetch next from actions_cursor into @action_id, @action_step
while @@FETCH_STATUS = 0
begin

if @action_id not in (1,4)
begin
print(@action_step)
print('go')
end
else
begin
set @action_step = case when @action_step like '%Copy %' then '--exec xp_cmdshell '+''''+@action_step+''''+'' else 'exec xp_cmdshell '+''''+@action_step+''''+'' end
print(@action_step)
print('go')
end

fetch next from actions_cursor into @action_id, @action_step
end

close actions_cursor
deallocate actions_cursor
