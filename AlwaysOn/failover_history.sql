declare @err table (date_time datetime, [error_number] int, [error_message] nvarchar(max))
;WITH cte_HADR AS (SELECT object_name, CONVERT(XML, event_data) AS data
FROM sys.fn_xe_file_target_read_file('AlwaysOn*.xel', null, null, null)
WHERE object_name = 'error_reported'
)
insert into @err
SELECT data.value('(/event/@timestamp)[1]','datetime') AS [timestamp],
       data.value('(/event/data[@name=''error_number''])[1]','int') AS [error_number],
       data.value('(/event/data[@name=''message''])[1]','varchar(max)') AS [message]
FROM cte_HADR
WHERE data.value('(/event/data[@name=''error_number''])[1]','int') = 1480
--and data.value('(/event/data[@name=''message''])[1]','varchar(max)') like '%DT_Archive8%'
--and data.value('(/event/data[@name=''message''])[1]','varchar(max)') like '%AssystDB%'
--and data.value('(/event/@timestamp)[1]','datetime') between '2023-02-24 00:00:00' and getdate()
--order by timestamp desc

select * from (
select date_time, [error_number], 
ltrim(rtrim(replace(master.dbo.vertical_array([error_message],' ', 5),'"',''))) database_name,
replace(master.dbo.vertical_array(ltrim(substring([error_message],charindex(' is ',[error_message]),len([error_message]))),' ',5),'"','') status_from,
replace(master.dbo.vertical_array(ltrim(substring([error_message],charindex(' is ',[error_message]),len([error_message]))),' ',7),'"','') status_to
from @err)a
where database_name = 'BAB_CCRS_STAGING'
order by date_time
