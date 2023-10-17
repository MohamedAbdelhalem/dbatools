SELECT COUNT(*) [Nr_exec/min],
convert(varchar(16),[CollectDate],120) CollectDate
--,master.dbo.duration('ms',max([total_elapsed_time])) total_elapsed_time
,[session_id]
,[sql_text]
,master.dbo.duration('ms',sum(cast(replace(replace(replace(substring([wait_info],1,CHARINDEX(')',[wait_info])-1),'(',''),'ms',''),',','') as float))) waittime
,substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), 1, CHARINDEX(' ', substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))-1) lastwaittype
,ltrim(rtrim(substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), CHARINDEX(' ',substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))+1,LEN(wait_info)))) waiting_key
,blocking_session_id
,sum([CPU]) CPU
,sum([reads]) Reads
,sum([writes]) Writes
,sum([physical_reads]) physical_reads
,[status]
,[host_name]
,[program_name]
FROM [MonitoringDB].[dbo].[TBL2_M_WhoIsActive]
where InstanceID = 41
and collectdate between '2023-08-19 20:45:00' and '2023-08-19 21:00:00'
and LEN(wait_info) > 5
and sql_text not in ('sp_server_diagnostics','COMMIT TRAN')
and status != 'sleeping'	
--and session_id =373
group by        
convert(varchar(16),[CollectDate],120)
,[session_id]
,substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), 1, CHARINDEX(' ', substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))-1)
,ltrim(rtrim(substring(substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])), CHARINDEX(' ',substring([wait_info],CHARINDEX(')',[wait_info])+1,LEN([wait_info])))+1,LEN(wait_info))))
,[sql_text]
,[status]
,[host_name]
,[program_name]
,blocking_session_id
order by convert(varchar(16),[CollectDate],120), session_id
