--To transfer rows from one partition number to another table's partition number, you have to make sure the second table is the same as the source table

--1. tabele structure
exec [dbo].[sp_table_syntax] 'Partition_Table'

--2. clustered index must be the same
exec [dbo].[sp_table_indexes] 'Partition_Table'

--3. switch the partition between tables
--e,g., we need to switch partition 5 from the source table [dbo].[Partition_Table] to archived table [dbo].[Partition_Table_history]
  
ALTER TABLE [dbo].[Partition_Table] SWITCH PARTITION 5 TO [dbo].[Partition_Table_history] PARTITION 5;

--PS. you can't alter the table switch partition to the target partition in another table that already has records, IT MUST BE EMPTY. 
--This is the error message if you try to add records in a non-empty partition

Msg 4904, Level 16, State 1, Line 44
ALTER TABLE SWITCH statement failed. The specified partition 5 of target table 'AdventureWorks2019.dbo.Partition_Table_history' must be empty.
