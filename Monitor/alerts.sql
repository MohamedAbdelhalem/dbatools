select 
name, message_text, enabled, occurrence_count, last_occurrence, last_response
from (
select 
name, message_text, enabled, occurrence_count,
last_occurrence_date,	
last_occurrence_date	+' '+substring(last_occurrence_time,1,2)+':'+substring(last_occurrence_time,3,2)+':'+substring(last_occurrence_time,5,2) last_occurrence, 
last_response_date,
last_response_date		+' '+substring(last_response_time,1,2)+':'+substring(last_response_time,3,2)+':'+substring(last_response_time,5,2) last_response
from (
SELECT name, mess.text message_text, a.enabled, occurrence_count,
case when last_occurrence_date > 0 then convert(varchar(10), convert(datetime, cast(last_occurrence_date as varchar(10)),120),120) else '2000-01-01' end last_occurrence_date, 
case 
when len(last_occurrence_time) = 1 then '00000'+cast(last_occurrence_time as varchar(10))
when len(last_occurrence_time) = 2 then '0000'+cast(last_occurrence_time as varchar(10))
when len(last_occurrence_time) = 3 then '000'+cast(last_occurrence_time as varchar(10))
when len(last_occurrence_time) = 4 then '00'+cast(last_occurrence_time as varchar(10))
when len(last_occurrence_time) = 5 then '0'+cast(last_occurrence_time as varchar(10))
when len(last_occurrence_time) = 6 then ''+cast(last_occurrence_time as varchar(10))
end last_occurrence_time, 
case when last_response_date > 0 then convert(varchar(10), convert(datetime, cast(last_response_date as varchar(10)),120),120) else '2000-01-01' end last_response_date, 
case 
when len(last_response_time) = 1 then '00000'+cast(last_response_time as varchar(10))
when len(last_response_time) = 2 then '0000'+cast(last_response_time as varchar(10))
when len(last_response_time) = 3 then '000'+cast(last_response_time as varchar(10))
when len(last_response_time) = 4 then '00'+cast(last_response_time as varchar(10))
when len(last_response_time) = 5 then '0'+cast(last_response_time as varchar(10))
when len(last_response_time) = 6 then ''+cast(last_response_time as varchar(10))
end last_response_time
FROM msdb.dbo.sysalerts a inner join sys.messages mess
on a.message_id = mess.message_id
where mess.language_id = 1033)b)c
where occurrence_count > 0


select * FROM msdb.dbo.syscachedcredentials
