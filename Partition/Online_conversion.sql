DROP Index CI_PARTITION_TABLE__5E02827250CDB1A2 On [dbo].[PARTITION_TABLE] 
--00:00:13
 
--add computed column as a PARTITION_KEY column 
--e.g. in this column will be a day year number so 1 partition will have multi-years
--e.g., partition 1 will have 2021-01-01, 2022-01-01, 2023-01-01, and 2024-01-01
ALTER Table [dbo].[PARTITION_TABLE] Add PARTITION_KEY As (DATEPART(DY, TransactionTime)) PERSISTED NOT NULL
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
