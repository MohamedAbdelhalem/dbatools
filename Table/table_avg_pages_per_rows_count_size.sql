--exec sp_table_size '','F_BAB_L_EFT_BRANCH_TXNS ,F_BAB_H_T000 ,F_BAB_H_T001'
exec sp_table_size '','F_OS_XML_CACHE'

declare @min int, @avg int, @max int
select @min = min(rows), @avg = avg(rows), @max = max(rows)
from (
select count(*) rows, fileid, pageid
from (
select 
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid
from [dbo].F_OS_XML_CACHE_temp2)a
group by fileid, pageid)b

select
cast(sum(case when rows = @min then 1 else 0 end) as varchar(100))+' rows = '+cast(cast(sum(case when rows = @min then 1.0 else 0.0 end) / count(*) * 100.0 as numeric(10,2)) as varchar(100))+'% min value = '+cast(@min as varchar(100)) [min value],
cast(sum(case when rows = @avg then 1 else 0 end) as varchar(100))+' rows = '+cast(cast(sum(case when rows = @avg then 1.0 else 0.0 end) / count(*) * 100.0 as numeric(10,2)) as varchar(100))+'% avg value = '+cast(@avg as varchar(100)) [avg],
cast(sum(case when rows = @max then 1 else 0 end) as varchar(100))+' rows = '+cast(cast(sum(case when rows = @max then 1.0 else 0.0 end) / count(*) * 100.0 as numeric(10,2)) as varchar(100))+'% max value = '+cast(@max as varchar(100)) [max value]
from (
select count(*) rows, fileid, pageid
from (
select
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid
from [dbo].F_OS_XML_CACHE_temp2)a
group by fileid, pageid)b


select AVG(rows)
from (
select count(*) rows, fileid, pageid
from (
select 
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid
from [dbo].[F_OS_XML_CACHE_temp2])a
group by fileid, pageid)b

