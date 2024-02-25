DROP Index CI_PARTITION_TABLE__5E02827250CDB1A2 On [dbo].[PARTITION_TABLE] 
--00:00:13
 
--computed column for the PARTITION_KEY column then
ALTER Table [dbo].[PARTITION_TABLE] Add PARTITION_KEY As (DATEPART(dy, TransactionTime)) Persisted NOT NULL
--00:16:44
 
--then alter the table and choose either to convert to 
--only clustered index (the table) 
--or the primary key index
 
--NON-PRIMARY KEY
CREATE CLUSTERED INDEXCI_PARTITION_TABLE__5E02827250CDB1A2 
ON [dbo].[PARTITION_TABLE] ([PARTITION_KEY], [PKID])
WITH (ONLINE=ON, MAXDOP=8) --if you add MAXDOP it will override your default settings
ON [Partition_S_days]([PARTITION_KEY])
 
--NON-PRIMARY KEY
ALTER TABLE [dbo].[PARTITION_TABLE] 
ADD CONSTRAINT PK_PARTITION_TABLE__5E02827250CDB1A2 PRIMARY KEY ([PARTITION_KEY], [PKID])
WITH (ONLINE=ON, MAXDOP=8) --if you add MAXDOP it will override your default settings
ON [Partition_S_days]([PARTITION_KEY])
 
 
-- to check and if you want to maintain your table and know the rows and size for each partition
 
use [database name]
go
select al.table_name, partition_rows, partition_size,
master.dbo.numbersize(sum(total_pages) over(partition by al.table_name) *8.0,'k') table_size,
prv.boundary_id partition_number
from (
select i.data_space_id, p.object_id, p.index_id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name,partition_number,
master.dbo.format(max(rows),-1) partition_rows,
master.dbo.numbersize(sum(a.total_pages) * 8.0,'k') partition_size,sum(a.total_pages) total_pages
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.indexes i
on  p.object_id = i.object_id
and p.index_id = i.index_id
where p.index_id = 1
group by i.data_space_id, schema_id, p.object_id, p.index_id, t.name,partition_number) al
inner join sys.partition_schemes ps
on al.data_space_id = ps.data_space_id
inner join sys.partition_functions pf
on ps.function_id = pf.function_id
inner join sys.partition_range_values prv
on prv.function_id = pf.function_id
and (prv.boundary_id + boundary_value_on_right) = al.partition_number
where table_name = '[dbo].[PARTITION_TABLE]'
order by table_name, partition_number
 
