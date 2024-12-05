select 

id,[replica_server],[availability_group_name],[database_name],[state_desc],[member_state],[role_desc],[quorum_votes],[sync_state_desc],[sync_health_desc],[database_state_desc],

[log_send_queue_size (RPO = Data Loss)], 

case 

when [log_send_queue_size (RPO = Data Loss)] like '%kb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)

when [log_send_queue_size (RPO = Data Loss)] like '%mb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%gb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%tb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0/1024.0

end log_send_queue_size_kb,

master.dbo.numbersize(sum(case 

when [log_send_queue_size (RPO = Data Loss)] like '%kb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)

when [log_send_queue_size (RPO = Data Loss)] like '%mb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%gb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%tb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0/1024.0

end) over() , 'kb') total_log_send_queue_size ,

master.dbo.numbersize(max(case 

when [log_send_queue_size (RPO = Data Loss)] like '%kb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)

when [log_send_queue_size (RPO = Data Loss)] like '%mb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%gb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0

when [log_send_queue_size (RPO = Data Loss)] like '%tb%' then cast(substring([log_send_queue_size (RPO = Data Loss)],1,charindex(' ',[log_send_queue_size (RPO = Data Loss)])-1) as float)*1024.0/1024.0/1024.0

end) over() , 'kb') max_log_send_queue_size ,

[redo_queue_size_not_yet (RTO = Long catch up)], 

case 

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%kb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%mb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%gb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%tb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0/1024.0

end redo_queue_size_not_yet_kb,

master.dbo.numbersize(sum(case 

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%kb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%mb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%gb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%tb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0/1024.0

end) over() , 'kb') total_redo_queue_size_not_yet,

master.dbo.numbersize(max(case 

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%kb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%mb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%gb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0

when [redo_queue_size_not_yet (RTO = Long catch up)] like '%tb%' then cast(substring([redo_queue_size_not_yet (RTO = Long catch up)],1,charindex(' ',[redo_queue_size_not_yet (RTO = Long catch up)])-1) as float)*1024.0/1024.0/1024.0

end) over() , 'kb') max_redo_queue_size_not_yet,

[total_waiting_logs],

[last_redone_time],[RPO],[Data_loss_Time RPO],[Long_catch_up RTO],[send or received latency],[capture_datetime]

from msdb.dbo.send_log_redo_queue_history

where capture_datetime > convert(varchar(10), getdate(), 120)
 
 
 
