select database_name, 
case 
when io_total_stall < 1							   then 0
when io_total_stall > 1   and io_total_stall <= 5   then 1
when io_total_stall > 5   and io_total_stall <= 10  then 2
when io_total_stall > 10  and io_total_stall <= 20  then 3
when io_total_stall > 20  and io_total_stall <= 100 then 4
when io_total_stall > 100 and io_total_stall <= 500 then 5
else 6 end Latency_num,
case 
when io_total_stall < 1							    then 'Excellent'
when io_total_stall > 1   and io_total_stall <= 5   then 'Very Good'
when io_total_stall > 5   and io_total_stall <= 10  then 'Good'
when io_total_stall > 10  and io_total_stall <= 20  then 'Poor'
when io_total_stall > 20  and io_total_stall <= 100 then 'Bad'
when io_total_stall > 100 and io_total_stall <= 500 then 'Very Bad'
else 'Awful' end Latency_desc,
total_latency_RW_ms,
total_latency_RW,
file_id, logical_name, physical_name, master.dbo.numbersize(size * 8.0,'k') file_size, master.dbo.numbersize(growth * 8.0,'k') file_growth,
io_stall_read_ms, io_stall_write_ms, num_of_reads, num_of_writes
from (
select db_name(mf.database_id) database_name,
cast((io_stall_read_ms+0.0001  + io_stall_write_ms+0.0001) / (num_of_reads + num_of_writes) as numeric(10,5)) io_total_stall,
cast((io_stall_read_ms+0.0001  + io_stall_write_ms+0.0001) / (num_of_reads + num_of_writes) as numeric(10,5)) total_latency_RW_ms,
master.dbo.duration('ms',cast((io_stall_read_ms+0.0001  + io_stall_write_ms+0.0001) / (num_of_reads + num_of_writes) as numeric(10,5))) total_latency_RW,
mf.file_id, mf.name logical_name, mf.physical_name, mf.size, mf.growth, io_stall_read_ms, io_stall_write_ms, num_of_reads, num_of_writes
from sys.dm_io_virtual_file_stats(NULL, NULL) iov inner join sys.master_files mf
on iov.database_id = mf.database_id
and iov.file_id = mf.file_id
where mf.database_id in (2)
or mf.database_id > 4)a
order by Latency_num desc, total_latency_RW_ms desc
--order by left(physical_name,1) 

