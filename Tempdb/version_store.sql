select db_name(database_id) database_name,
master.dbo.numbersize(sum(cast(record_length_first_part_in_bytes as bigint))/1024.0/1024.0,'m') version_store_size
from sys.dm_tran_version_store
group by database_id

--when tempdb total size was between 92 GB and 46.99 GB
----------------------------------------
--database_name	|	version_store_size  |
----------------------------------------
--msdb			|	11.29 MB			|
--T24Prod		|	51.44 GB			|
----------------------------------------