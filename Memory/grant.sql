use master
go
SELECT r.session_id 
      ,master.dbo.numbersize(mg.requested_memory_kb/1024.0,'m') requested_memory
      ,isnull(master.dbo.numbersize(mg.granted_memory_kb/1024.0,'m'), 'not granted yet') granted_memory
	  ,master.dbo.numbersize(mg.used_memory_kb/1024.0,'m') used_memory
      ,master.dbo.numbersize(mg.ideal_memory_kb/1024.0,'m') ideal_memory
	  ,master.dbo.numbersize(mg.required_memory_kb/1024.0,'m') [Minimum memory required] 
      ,mg.request_time 
      ,isnull(convert(varchar(50),mg.grant_time,121) , 'not granted yet') grant_time
      ,master.dbo.duration('s',datediff(s,mg.request_time ,mg.grant_time)) grant_time_ms 
	  ,queue_id
	  ,wait_order
      ,mg.query_cost 
      ,mg.dop 
      ,( 
        SELECT SUBSTRING(TEXT, 
                         statement_start_offset / 2 + 1,
                         (CASE WHEN statement_end_offset = - 1 
                            THEN LEN(
                                     CONVERT(NVARCHAR(MAX), 
                                     TEXT)
                                     ) * 2 
                         ELSE statement_end_offset 
                         END - statement_start_offset 
                    ) / 2) 
        FROM sys.dm_exec_sql_text(r.sql_handle) 
       ) AS query_text 
      ,qp.query_plan 
FROM sys.dm_exec_query_memory_grants AS mg 
     INNER JOIN sys.dm_exec_requests r 
     ON mg.session_id = r.session_id 
     CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp 
	 where mg.session_id != @@SPID
ORDER BY mg.required_memory_kb DESC;

--select * from sys.dm_exec_query_optimizer_info

--select top 10 * from sys.dm_exec_query_memory_grants
--696


select * from sys.dm_tran_top_version_generators  
select top 100 * from sys.dm_tran_version_store

select vs.transaction_sequence_num, version_sequence_num,status, min_length_in_bytes, record_length_first_part_in_bytes,record_length_second_part_in_bytes, t.aggregated_record_length_in_bytes
from sys.dm_tran_version_store vs inner join sys.dm_tran_top_version_generators t
on vs.rowset_id = t.rowset_id
