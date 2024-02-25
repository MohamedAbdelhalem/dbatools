DROP Index CI_PARTITION_TABLE__5E02827250CDB1A2 On [dbo].[PARTITION_TABLE] 
--00:00:13
 
--add computed column as a PARTITION_KEY column
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
 
--PRIMARY KEY
ALTER TABLE [dbo].[PARTITION_TABLE] 
ADD CONSTRAINT PK_PARTITION_TABLE__5E02827250CDB1A2 PRIMARY KEY ([PARTITION_KEY], [PKID])
WITH (ONLINE=ON, MAXDOP=8) --if you add MAXDOP it will override your default settings
ON [Partition_S_days]([PARTITION_KEY])
