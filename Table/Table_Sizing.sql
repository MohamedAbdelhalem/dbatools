SELECT 
 [id]
,[table_name]
,master.dbo.format([rows],-1)
,[avg_row_count]
,[avg_row_size]
,[percent]
,[avg_row_count_pct]
,[avg_row_size_plus_%]
,case when table_name = '[dbo].[MESSAGE_ARCHIVE]' then (600000000 * 2) else rows end
,master.dbo.numbersize(case 
when master.dbo.vertical_array(avg_row_size,' ',2) = 'bytes' then cast(replace(master.dbo.vertical_array(avg_row_size,' ',1),',','') as numeric(10,2)) * 1.0
when master.dbo.vertical_array(avg_row_size,' ',2) = 'kb' then cast(replace(master.dbo.vertical_array(avg_row_size,' ',1),',','') as numeric(10,2)) * 1024.0
end * case when table_name = '[dbo].[MESSAGE_ARCHIVE]' then (600000000 * 2) else rows end / 1024.0, 'kb')
from [msdb].[dbo].[table_sizing]
where rows > 0


SELECT 
master.dbo.numbersize(sum(case 
when master.dbo.vertical_array(avg_row_size,' ',2) = 'bytes' then cast(replace(master.dbo.vertical_array(avg_row_size,' ',1),',','') as numeric(10,2)) * 1.0
when master.dbo.vertical_array(avg_row_size,' ',2) = 'kb' then cast(replace(master.dbo.vertical_array(avg_row_size,' ',1),',','') as numeric(10,2)) * 1024.0
end * case when table_name = '[dbo].[MESSAGE_ARCHIVE]' then (600000000 * 2) else rows end) / 1024.0, 'kb')
from [msdb].[dbo].[table_sizing]
where rows > 0

select count(*), year(EVENT_TIME) from [dbo].[BACKEND_EVENT] with (nolock) group by year(EVENT_TIME)
--51,570,742	2023
go
select count(*), year(EMAIL_TIME) from [dbo].[MAIL_ARCHIVE]  with (nolock) group by year(EMAIL_TIME)
--1,009,000		2021
--98,049,581	2022
--35,367,755	2023
go
select count(*), year(CREATION_TIME) from [dbo].[MESSAGE_ARCHIVE]  with (nolock) group by year(CREATION_TIME)
--4561,079		2014
--49,542,106	2015
--80,372,041	2016
--52,377,024	2017
--66,823,087	2018
--228,631,391	2019
--243,900,273	2020
--429,052,129	2021
--591,938,331	2022
--221,407,239	2023
go
select count(*), year(CREATION_TIME) from [dbo].[MESSAGE_OUT_BKP]  with (nolock) group by year(CREATION_TIME)
--7,134,339	2023
