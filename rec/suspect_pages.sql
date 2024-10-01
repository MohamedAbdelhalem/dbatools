select database_id, db_name(database_id) name, file_id, page_id, event_type,
case event_type 
when 1 then 'An 823 error that causes a suspect page (such as a disk error) or an 824 error other than a bad checksum or a torn page (such as a bad page ID).'
when 2 then 'Bad checksum.'
when 3 then 'Torn page.'
when 4 then 'Restored (page was restored after it was marked bad).'
when 5 then 'Repaired (DBCC repaired the page).'
when 7 then 'Deallocated by DBCC.'
end event_desc, error_count, last_update_date
from msdb.dbo.suspect_pages

