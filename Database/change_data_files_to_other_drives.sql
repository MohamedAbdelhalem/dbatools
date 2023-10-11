declare 
@database_name			varchar(max) = 'Tfs_Warehouse', 
@except_db				varchar(max) = '0',
@file_type				varchar(10)  = 'data',
@drive_letter_original	varchar(1)	 = 'E',
@drive_letter_new		varchar(1)	 = 'F',
@action					varchar(30)	 = 'HADR_Secondary_add'
--0- HADR_Primary_remove
--1- mkdir
--2- alter
--3- offline
--4- copy data file to the new drives
--5- online
--6- HADR_Primary_add
--7- HADR_Secondary_add

declare @sql varchar(max)
declare @dbs table (database_id bigint)

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

declare alter_cursor cursor fast_forward
for
select distinct case @action 
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
'ALTER DATABASE ['+db_name(mf.database_id)+'] set HADR AVAILABILITY GROUP = ['+isnull(a.ag_name,'')+'];' --ALTER DATABASE [ReportServerTempDB] SET HADR AVAILABILITY GROUP = [TFS_HAG];
end
from sys.master_files mf left outer join (select database_id, ag.name ag_name 
										 from sys.availability_groups ag inner join sys.dm_hadr_database_replica_states dbrs 
										 on ag.group_id = dbrs.group_id
										 where dbrs.is_local = 1) a
on mf.database_id = a.database_id
where mf.database_id > 4
and mf.database_id in (select database_id from @dbs)
and case when @action in ('offline','online') then '0' else type_desc end = case when @action in ('offline','online') then '0' else case @file_type when 'data' then 'rows' when 'log' then 'log' end end
and case when @action in ('offline','online') then '0' else left(physical_name,1) end = case when @action in ('offline','online') then '0' else @drive_letter_original end

open alter_cursor
fetch next from alter_cursor into @sql
while @@FETCH_STATUS = 0
begin

print(@sql)

fetch next from alter_cursor into @sql
end
close alter_cursor 
deallocate alter_cursor 

set nocount off


