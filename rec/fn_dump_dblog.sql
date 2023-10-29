select *--[Transaction Name], [Transaction ID], [Begin Time] 
into msdb.dbo.logs
FROM
sys.fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'F:\MSSQL_Backup\DocDigit_backups_2022_09_29\VPSTLDNS_P001$CSTL_AG_DigitalDocs_PRD_Log_20220928_170001.trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
where convert(datetime, [begin time], 120) > '2022/04/17 13:59:00:000'
and [Transaction Name] = 'DELETE'
--where [Transaction ID] in (select [Transaction ID] from msdb.dbo.logs)
--0027:ffceb97e

select * from (
select '['+SCHEMA_NAME(t.schema_id)+'].['+t.name+']' [object_name], t.type_desc, l.* 
from msdb.dbo.logs l inner join sys.allocation_units a
on a.allocation_unit_id = l.AllocUnitId
inner join sys.partitions p
on ((a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_number))
inner join sys.objects t
on p.object_id = t.object_id)a
where [object_name] like '%Templates%' 
--where [Transaction ID] = '0000:002bcc17'


select * from (
select '['+SCHEMA_NAME(t.schema_id)+'].['+t.name+']' [object_name], t.type_desc, l.* 
from sys.fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'F:\MSSQL_Backup\DocDigit_backups_2022_09_29\VPSTLDNS_P001$CSTL_AG_DigitalDocs_PRD_Log_20220928_160000.trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) l inner join sys.allocation_units a
on a.allocation_unit_id = l.AllocUnitId
inner join sys.partitions p
on ((a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_number))
inner join sys.objects t
on p.object_id = t.object_id)a
--where [object_name] like '%Templates%' 
where [Transaction ID] in ('0000:002bcaf0','0000:002bcaf1')


select * from (
select '['+SCHEMA_NAME(t.schema_id)+'].['+t.name+']' [object_name], t.type_desc, l.* 
from sys.fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'F:\MSSQL_Backup\DocDigit_backups_2022_09_29\VPSTLDNS_P001$CSTL_AG_DigitalDocs_PRD_Log_20220928_160000.trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) l inner join sys.allocation_units a
on a.allocation_unit_id = l.AllocUnitId
inner join sys.partitions p
on ((a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_number))
inner join sys.objects t
on p.object_id = t.object_id)a
where [Transaction ID] in (
select [Transaction ID] from (
select '['+SCHEMA_NAME(t.schema_id)+'].['+t.name+']' [object_name], t.type_desc, l.* 
from sys.fn_dump_dblog (
NULL, NULL, N'DISK', 1, N'F:\MSSQL_Backup\DocDigit_backups_2022_09_29\VPSTLDNS_P001$CSTL_AG_DigitalDocs_PRD_Log_20220928_160000.trn',
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,
DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) l inner join sys.allocation_units a
on a.allocation_unit_id = l.AllocUnitId
inner join sys.partitions p
on ((a.type in (1,3) and a.container_id = p.hobt_id)
or (a.type in (2) and a.container_id = p.partition_number))
inner join sys.objects t
on p.object_id = t.object_id)b
where [object_name] like '%Templates%')

