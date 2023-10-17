select object_name(object_id), master.dbo.format(max(rows),-1) rows, 
cast(max(rows) as float) / ((6373863) * 1.0 ) * 100.0 percent_complete, 
master.[dbo].[time_to_complete](max(rows),  6373863, '2022-10-02 11:11:00') [time_to_complete]
from sys.partitions
where object_name(object_id) = 'F_BAB_L_GEN_ACCT_STMT'
group by object_id
--2,154,911
--2,160,373
--2,165,835

