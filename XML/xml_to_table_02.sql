truncate table master.dbo.table_recids

select id, RECID, case when RECID not like '%><%' then LAG(RECID, 1,1) over(order by id) + RECID else RECID end 
from 
master.dbo.table_recids
where len(RECID) < len('c146><c147>201661112090621.030002')
order by id

select id, RECID, substring(recid, 1, 1000 - charindex('>', reverse(recid)) + 1), charindex('>', reverse(recid)) + 1
from master.dbo.table_recids
order by id

select id, RECID, substring(recid, charindex('><', recid), len(recid) - charindex('>', reverse(recid)) + 1 + charindex('><', recid)), charindex('>', reverse(recid)) + 1 + charindex('><', recid)
from master.dbo.table_recids
order by id

