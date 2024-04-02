select [Page Magority %], format(no_of_pages,'###,###,###') no_of_pages, no_records_per_page_8kb, record_size
from (
select cast((no_of_pages / sum(no_of_pages) over()) * 100.0 as numeric(10,2)) [Page Magority %], *
from (
select 
cast(count(*) as float) no_of_pages, 
no_records_per_page_8kb, 
cast(8060.0 / cast(no_records_per_page_8kb as float) as numeric(10,3)) record_size
from (
select count(*) no_records_per_page_8kb, fileid, pageid from (
select top 1000000 --sample of records on 1,000,000 rows
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid
from [dbo].[PARTITION_TABLE_LEFT])a
group by fileid, pageid)b
group by no_records_per_page_8kb, 
cast(8060.0 / cast(no_records_per_page_8kb as float) as numeric(10,3)))c)d
where [Page Magority %] >= 20
order by [Page Magority %] desc
