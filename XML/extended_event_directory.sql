select xe.name Extended_Event, 
cast(xet.target_data as xml).value('(EventFileTarget/File/@name)[1]', 'VARCHAR(MAX)') Extended_Event_Directory
from sys.dm_xe_session_targets xet JOIN sys.dm_xe_sessions xe 
on xe.address = xet.event_session_address
where xet.target_name = 'event_file'
