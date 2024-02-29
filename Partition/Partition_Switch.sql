--to achieve to transfer rows from partition number to another table's partition number, you have to make sure the second table is the same everything

--1. tabele structure
exec [dbo].[sp_table_script] 'Partition_Table'

--2. clustered index muster be the same
exec [dbo].[sp_table_indexes] 'Partition_Table'

--3. switch the partition between tables
ALTER TABLE Partition_Table SWITCH PARTITION 5 TO Partition_Table_history PARTITION 5;


