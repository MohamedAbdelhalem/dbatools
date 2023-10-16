 --F_BAB_L_GEN_TABLE
--drop table master.dbo.TLog_tracking
--create table master.dbo.TLog_tracking (id int identity(1,1), [Current LSN] varchar(100), Operation varchar(100), Context varchar(100), RECID varchar(1000), backup_file_name varchar(1000))
--create table master.dbo.TLog_tracking_monitor (id int identity(1,1), backup_file_name varchar(1000), start_time datetime, end_time datetime)
declare @backup_file_name nvarchar(1000)
declare i cursor fast_forward
for
select backup_file_name 
from [master].[dbo].[table_header]
where BackupTypeDescription = 'transaction log'
and BackupStartDate between '2023-04-20 03:00:00.000' and '2023-04-20 07:00:00.000'
order by BackupStartDate 

open i
fetch next from i into @backup_file_name
while @@FETCH_STATUS = 0
begin

insert into master.dbo.TLog_tracking_monitor (backup_file_name, start_time) values (@backup_file_name, getdate())

insert into master.dbo.TLog_tracking ([Current LSN], Operation, Context, RECID, backup_file_name)
SELECT [Current LSN],
Operation, Context, --[RowLog Contents 0], 
substring(convert(varchar(max),[RowLog Contents 0],2),26 + 1, charindex('DFFF',convert(varchar(max),[RowLog Contents 0],2))-4 - 26 + 1) Deleted_RECID, @backup_file_name
FROM
fn_dump_dblog (
NULL, NULL, N'DISK', 1, @backup_file_name,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
where AllocUnitId in (
select a.allocation_unit_id 
from sys.allocation_units a inner join sys.partitions p
on (a.type in (1,3) and p.hobt_id = a.container_id)
or (a.type = 2 and p.partition_id = a.container_id)
inner join sys.tables t
on t.object_id = p.object_id 
where t.name = 'F_BAB_L_GEN_TABLE')
and Operation = 'LOP_DELETE_ROWS'

update master.dbo.TLog_tracking_monitor set end_time = getdate() where end_time is null 

fetch next from i into @backup_file_name
end
close i
deallocate i


--select * from sys.allocation_units a inner join sys.partitions p
--on (a.type in (1,3) and p.hobt_id = a.container_id)
--or (a.type = 2 and p.partition_id = a.container_id)
--inner join sys.tables t
--on t.object_id = p.object_id 
--where t.name = 'F_BAB_L_GEN_TABLE'


--0x

--declare @row varchar(max) = '70000400020000020026002001444F482E443230323330343130313833333638343235323030DFFF01B004F00372006F007700EF000001F801F00269006400EF000002F602111944004F0048002E00440032003000320033003000340031003000310038003300330036003800340032003500320030003000F00573007000610063006500F02468007400740070003A002F002F007700770077002E00770033002E006F00720067002F0058004D004C002F0031003900390038002F006E0061006D00650073007000610063006500F00378006D006C00EF040503F603110870007200650073006500720076006500F5F00263003100EF000006F80411104D00530047002E00530057004900460054002E00340037003200330039003500F7F70000000000000000626EECAB3100'

--select substring(@row,26 + 1, charindex('DFFF',@row)-4 - 26 + 1)
