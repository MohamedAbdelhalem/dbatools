--sp_table_size '','F_BAB_L_GEN_TABLE'
--47,966,572
--47,960,679

declare 
@min_recid varchar(500),
@max_recid varchar(500),
@delete_st varchar(max),
@loop int = 0

update master.dbo.log set loop_id = 0
while @loop < 100
begin
select 
@min_recid = MIN(RECID), 
@max_recid = Max(RECID) 
from (
SELECT top 1000 RECID
FROM "F_BAB_L_GEN_TABLE"    
where RECID like 'FTENJ%'
order by RECID)a

set @delete_st = 'Delete from F_BAB_L_GEN_TABLE where RECID between '+''''+@min_recid+''''+' and '+''''+@max_recid+''''
exec(@delete_st)

waitfor delay '00:00:02'

set @loop += 1
update master.dbo.log set loop_id = @loop
end
 

--select * from master.dbo.log

--SELECT master.dbo.format(count(*),-1), substring(RECID, 1, charindex('.',RECID, CHARINDEX('.',RECID)+2)-1) 
--FROM "F_BAB_L_GEN_TABLE"    
--where RECID like 'FTENJ%'
--group by substring(RECID, 1, charindex('.',RECID, CHARINDEX('.',RECID)+2)-1) 
--order by substring(RECID, 1, charindex('.',RECID, CHARINDEX('.',RECID)+2)-1) 

--and RECID like 'FTENJ.20230727%'
--order by RECID 
----1,018,113