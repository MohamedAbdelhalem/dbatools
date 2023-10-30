If you have a situation with ***a database***  that has a mirror configuration, 

The point of weakness here that the transaction log was configured with a max size of 50GB and by the coincidence that the backup team takes daily backups for all databases inside this instance except this database and the second thing that the disk was reached 63% used space and that makes us didn’t receive any alert from ManageEngine because that will not trigger the threshold of 85%.

So the issue was that the transaction log reached the max size of $\colorbox{green}{{\color{white}{This\ is\ a\ Big\ Title}}}$ plus there were some data waits to sync with the secondary node around 980 KB but because the free space inside the log file was + -1.20 MB all the below solutions failed:
1.	Take a log or full backup, because when you are going to take any backup you will write the checkpoint LSN regarding any type, as a transaction, because there is not enough space @@ -1.20 MB@@.
2.	Increase the max size of the transaction log file.
3.	Alter the secondary log file and set the file growth to more than 0 KB (the database has two log files 1 active and the other set to 0 KB file growth).

So the only solution is to remove the database from the mirror by the below steps.

> **Note**
> From the **Primary node**

```SQL
ALTER DATABASE [DATABASE_NAME] SET PARTNER OFF;
```

> **Note**
> From the **Primary node** From **Secondary node** and make sure that Log Send Queue KB counter doesn’t have any queues

```SQL

declare @table table ([object_name] varchar(1000), counter_name varchar(1000), instance_name varchar(1000), current_value varchar(200))

insert into @table
select object_name, counter_name, instance_name, cntr_value
from sys.dm_os_performance_counters
where object_name like '%mirr%'
and instance_name = AptraConn_prd'
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
```

> **Note**
> From the **Primary node** Then take transaction log backup from the **Primary Node** database

```SQL

BACKUP log [DATABASE_NAME] TO  DISK = N'\\...\DATABASE_NAME_log_2023_07_25__03_23_pm.bak' WITH NOFORMAT, NOINIT,  
NAME = N'DATABASE_NAME-Log Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 1
```

> **Note**
> From the **Primary node** Then restore it on the **Secondary node**

```SQL

RESTORE LOG [DATABASE_NAME]
FROM DISK = N'\\...\DATABASE_NAME_log_2023_07_25__03_23_pm.bak'
WITH FILE = 1,
NAME = N'DATABASE_NAME-log Database Backup', NORECOVERY, NOUNLOAD, STATS = 1
```

> **Note**
> From the **Primary node** Then go to the **Secondary node** and join the database to mirror

```SQL

declare @partner varchar(500), @set_partner varchar(1000), @database_name varchar(500) = 'DATABASE_NAME'
select top 1 @partner = mirroring_partner_name 
from sys.database_mirroring
where mirroring_partner_name is not null

set @set_partner = 'ALTER DATABASE ['+@database_name+'] SET PARTNER ='+''''+@partner+''''
exec(@set_partner)
```

> **Note**
> From the **Primary node** And finally go to the **Primary node** and join the database to mirror

```SQL

declare @partner varchar(500), @set_partner varchar(1000), @database_name varchar(500) = 'DATABASE_NAME'
select top 1 @partner = mirroring_partner_name 
from sys.database_mirroring
where mirroring_partner_name is not null

set @set_partner = 'ALTER DATABASE ['+@database_name+'] SET PARTNER ='+''''+@partner+''''
exec(@set_partner)
```
