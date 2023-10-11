declare @main_ag varchar(200) = 'DH_Maintenance_AG'
declare @instances table (ips varchar(100), role char(1))
insert into @instances values ('10.4.0.41','P'),('10.36.0.41','S')

declare 
@database_name			varchar(max) = 'Data_Hub_Open_Banking', 
@except_db				varchar(max) = '0',
@file_type				varchar(10)  = 'data',
@drive_letter_original	varchar(1)	 = 'U',
@drive_letter_new		varchar(1)	 = 'R'

declare @sql varchar(max), @loop int = 0, @action varchar(100), @action_id int, @action_step varchar(1500)
declare @dbs table (database_id bigint)
declare @actions table (action_id int, action_step varchar(1500))

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
while @loop < 21
begin

set @action = case @loop 
when 1  then 'CONNECT_P'
when 2  then 'HADR_Primary_remove'
when 3  then 'HADR_Primary_add_main'
when 4  then 'CONNECT_S'
when 5  then 'HADR_Secondary_add_main'
when 6  then 'HADR_Failover_main'
when 7  then 'HADR_Primary_remove_main'
when 8  then 'mkdir'
when 9  then 'ALTER'
when 10 then 'OFFLINE'
when 11 then 'Copy'
when 12 then 'ONLINE'
when 13 then 'HADR_Primary_add_main'
when 14 then 'CONNECT_P'
when 15 then 'HADR_Secondary_add_main'
when 16 then 'HADR_Failover_main'
when 17 then 'HADR_Primary_remove_main'
when 18 then 'HADR_Primary_add'
when 19 then 'CONNECT_S'
when 20 then 'HADR_Secondary_add'
end

insert into @actions 
select distinct @loop, 
case @action 
when 'mkdir'						then 'mkdir "'+reverse(substring(reverse(@drive_letter_new+substring(physical_name,2,len(physical_name))),charindex('\',reverse(@drive_letter_new+substring(physical_name,2,len(physical_name)))),len(reverse(@drive_letter_new+substring(physical_name,2,len(physical_name))))))+'"' 
when 'Copy'							then 'Copy /v "'+@drive_letter_original+substring(physical_name,2,len(physical_name))+'" "'+@drive_letter_new+substring(physical_name,2,len(physical_name))+'"' 
when 'ALTER'						then 'ALTER DATABASE ['+db_name(mf.database_id)+'] MODIFY FILE (NAME='+''''+name+''''+', FILENAME='+''''+@drive_letter_new+substring(physical_name,2,len(physical_name))+''''+');' 
when 'OFFLINE'						then 'ALTER DATABASE ['+db_name(mf.database_id)+'] SET OFFLINE WITH ROLLBACK IMMEDIATE;' 
when 'ONLINE'						then 'ALTER DATABASE ['+db_name(mf.database_id)+'] SET ONLINE;' 
when 'HADR_Primary_remove'			then 'ALTER AVAILABILITY GROUP ['+a.ag_name+'] REMOVE DATABASE ['+db_name(mf.database_id)+'];'
when 'HADR_Primary_add'				then 'ALTER AVAILABILITY GROUP ['+a.ag_name+'] ADD DATABASE ['+db_name(mf.database_id)+'];'
when 'HADR_Secondary_add'			then 'ALTER DATABASE ['+db_name(mf.database_id)+'] SET HADR AVAILABILITY GROUP = ['+isnull(a.ag_name,'')+'];'
when 'CONNECT_P'					then ':CONNECT '+(select ips from @instances where role = 'P')
when 'CONNECT_S'					then ':CONNECT '+(select ips from @instances where role = 'S')
when 'HADR_Primary_add_main'		then 'ALTER AVAILABILITY GROUP ['+@main_ag+'] ADD DATABASE ['+db_name(mf.database_id)+'];'
when 'HADR_Primary_remove_main'		then 'ALTER AVAILABILITY GROUP ['+@main_ag+'] REMOVE DATABASE ['+db_name(mf.database_id)+'];'
when 'HADR_Secondary_remove_main'	then 'ALTER AVAILABILITY GROUP ['+@main_ag+'] REMOVE DATABASE ['+db_name(mf.database_id)+'];'
when 'HADR_Secondary_add_main'		then 'ALTER DATABASE ['+db_name(mf.database_id)+'] SET HADR AVAILABILITY GROUP = ['+@main_ag+'];'
when 'HADR_Failover_main'			then 'ALTER AVAILABILITY GROUP ['+@main_ag+'] FAILOVER;'
end
from sys.master_files mf left outer join (select database_id, ag.name ag_name 
										 from sys.availability_groups ag inner join sys.dm_hadr_database_replica_states dbrs 
										 on ag.group_id = dbrs.group_id
										 where dbrs.is_local = 1) a
on mf.database_id = a.database_id
where mf.database_id > 4
and mf.database_id in (select database_id from @dbs)
and case when @file_type = '*' then -1 else type end = case @file_type when 'data' then 0 when 'log' then 1 else -1 end --to work on data or log or both
and case when @action in ('OFFLINE','ONLINE') then '0' else left(physical_name,1) end = case when @action in ('OFFLINE','ONLINE') then '0' else @drive_letter_original end

set @loop = @loop +1
end

declare actions_cursor cursor fast_forward
for
select * 
from @actions
order by action_id

open actions_cursor
fetch next from actions_cursor into @action_id, @action_step
while @@FETCH_STATUS = 0
begin

if @action_id not in (8,11)
begin
print(@action_step)
print('GO')
end
else
begin
set @action_step = case when @action_step like '%Copy %' then '--exec xp_cmdshell '+''''+@action_step+''''+'' else 'exec xp_cmdshell '+''''+@action_step+''''+'' end
print(@action_step)
print('GO')
end

fetch next from actions_cursor into @action_id, @action_step
end

close actions_cursor
deallocate actions_cursor
