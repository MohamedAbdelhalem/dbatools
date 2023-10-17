select * from master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]

select row_number() over(order by from_id) id, from_id, to_id, from_unique_column, to_unique_column 
from master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]
where from_id != to_id
order by from_id

select master.dbo.format(max(rows)*1000,-1)
from sys.partitions
where object_id in ( object_id('dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]'))

select * from master.dbo.FBNK_FUNDS_TRANSFER#HIS_summary4
order by from_id
