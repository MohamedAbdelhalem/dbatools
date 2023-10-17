--step 1 check tables size
--use [T24SDC3]
--go
exec sp_table_size '','FBNK_FUNDS_TRANSFER#HIS, FENJ_FUND200 '

--step 2 check the non-computed columns as an example they need to keep data after [PROCESSING_DATE] > '20230310'
select count(*)--[RECID], [XMLRECORD] 
from FBNK_FUNDS_TRANSFER#HIS
where [PROCESSING_DATE] >= '20230310'

select count(*)--[RECID], [XMLRECORD] 
from FENJ_FUND200
where [PROCESSING_DATE] >= '20230310'

--step 3 export and import usng SSMS to make an SSIS package to create new table with the above query

--step 4 monitor the porgress

select t.name,
master.dbo.format(max(rows),-1) rows, 
case t.name 
when 'FBNK_FUNDS_TRANSFER#HIS_gt_20230310' then '7,999,098' 
when 'FENJ_FUND200_gt_20230310' then '417,143' 
end
target, 
case t.name
when 'FBNK_FUNDS_TRANSFER#HIS_gt_20230310' then cast(cast(max(rows) as float) / 7999098.0 * 100.0 as numeric(10,4))
when 'FENJ_FUND200_gt_20230310' then cast(cast(max(rows) as float) / 417143.0 * 100.0 as numeric(10,4))
end percent_complete,
case t.name
when 'FBNK_FUNDS_TRANSFER#HIS_gt_20230310' then master.[dbo].[time_to_complete](cast(max(rows) as float), 7999098.0, '2023-03-20 14:50:00') 
when 'FENJ_FUND200_gt_20230310' then master.[dbo].[time_to_complete](cast(max(rows) as float), 417143.0, '2023-03-20 14:50:00') 
end time_to_complete,
master.dbo.duration('s',datediff(s,'2023-03-20 14:50:00',getdate())) duration
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
where p.object_id in (object_id('FBNK_FUNDS_TRANSFER#HIS_gt_20230310'),object_id('FENJ_FUND200_gt_20230310'))
group by t.name

--step 5 create computed columns and indexes
declare 
@old_table_name varchar(350) = '[dbo].[FBNK_FUNDS_TRANSFER#HIS]',
@new_table_name varchar(350) = '[dbo].[FBNK_FUNDS_TRANSFER#HIS_gt_20230310]'

select 'ALTER TABLE '+@new_table_name+' ADD '+name+' AS '+definition
from sys.computed_columns
where object_id = object_id(@old_table_name)

exec sp_table_indexes @new_table_name
exec sp_table_indexes @old_table_name

go
--step 6 rename the tables

declare 
@old_table_name1 varchar(350) = '[dbo].[FBNK_FUNDS_TRANSFER#HIS]',
@old_table_name2 varchar(350) = 'FBNK_FUNDS_TRANSFER#HIS_full_old',
@new_table_name1 varchar(350) = '[dbo].[FBNK_FUNDS_TRANSFER#HIS_gt_20230310]',
@new_table_name2 varchar(350) = 'FBNK_FUNDS_TRANSFER#HIS'

exec sp_rename @old_table_name1, @old_table_name2
exec sp_rename @new_table_name1, @new_table_name2

go
declare 
@old_table_name1 varchar(350) = '[dbo].[FENJ_FUND200]',
@old_table_name2 varchar(350) = 'FENJ_FUND200_full_old',
@new_table_name1 varchar(350) = '[dbo].[FENJ_FUND200_gt_20230310]',
@new_table_name2 varchar(350) = 'FENJ_FUND200'

exec sp_rename @old_table_name1, @old_table_name2
exec sp_rename @new_table_name1, @new_table_name2





