--From the Primary node

ALTER DATABASE [AptraConn_prd] SET PARTNER OFF;

--From Secondary node and make sure that Log Send Queue KB counter doesnt have any queues
go
declare @table table ([object_name] varchar(1000), counter_name varchar(1000), instance_name varchar(1000), current_value varchar(200))

insert into @table
select object_name, counter_name, instance_name, cntr_value
from sys.dm_os_performance_counters
where object_name like '%mirr%'
and instance_name = 'AptraConn_prd'
and counter_name not like '%/%'
and counter_name in ('Log Send Queue KB')
and cntr_value > 0 
order by counter_name

select 
object_name, counter_name, instance_name, ltrim(rtrim(current_value)) , case 
when counter_name like '% kb %' then master.dbo.numberSize(current_value,'KB')
when counter_name like '%(ms)%' then master.dbo.duration('s',current_value/1000) 
else 
current_value
end current_value
from @table
order by counter_name

--Then take transaction log backup from the Primary database
go
BACKUP log [AptraConn_prd] TO  DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1APTDBSQPWV1\AptraConn_prd_log_2023_07_25__03_23_pm.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AptraConn_prd-log Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 1

--Then restore it on the Secondary node
go
RESTORE LOG [AptraConn_prd]
FROM DISK = N'\\npci1.d1fs.albilad.com\SQLNativeBackup\D1APTDBSQPWV1\AptraConn_prd_log_2023_07_25__03_23_pm.bak'
WITH FILE = 1,
NAME = N'AptraConn_prd-log Database Backup', NORECOVERY, NOUNLOAD, STATS = 1

--Then go to the Secondary node and join the database to mirror
go
declare @partner varchar(500), @set_partner varchar(1000), @database_name varchar(500) = 'AptraConn_prd'
select top 1 @partner = mirroring_partner_name 
from sys.database_mirroring
where mirroring_partner_name is not null

set @set_partner = 'ALTER DATABASE ['+@database_name+'] SET PARTNER ='+''''+@partner+''''
exec(@set_partner)

--And finally go to the Primary node and join the database to mirror
go
declare @partner varchar(500), @set_partner varchar(1000), @database_name varchar(500) = 'AptraConn_prd'
select top 1 @partner = mirroring_partner_name 
from sys.database_mirroring
where mirroring_partner_name is not null

set @set_partner = 'ALTER DATABASE ['+@database_name+'] SET PARTNER ='+''''+@partner+''''
exec(@set_partner)

