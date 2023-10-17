alter procedure big_table_partitions
(@start bigint = 0, @offset_bulk bigint = 1000000, @bulk bigint = 1000)
as
begin

;with big_table as (
select row_number() over(order by recid) id, recid
from T24PROD_MASTER.dbo.[FBNK_FUNDS_TRANSFER#HIS]
order by recid
OFFSET 0 + (@start * @offset_bulk) ROWS FETCH NEXT @offset_bulk ROWS ONLY)
select row_number() over(order by unique_id desc) id, unique_id, min(id), max(id), min(recid), max(recid)
from (
select count(*) over() - patch_id - count(*) over(order by id) unique_id, * 
from (
select id % @bulk patch_id, id, recid
from big_table)a
where patch_id in (0,1)
union all
select -1, 0, id, recid
from (
select count(*) over() - patch_id - count(*) over(order by id) unique_id, * 
from (
select id % @bulk patch_id, id, recid
from big_table)a)b
where id in (select max(id) 
				from (
					select count(*) over() - patch_id - count(*) over(order by id) unique_id, patch_id, id, recid 
						from (
							select id % @bulk patch_id, id, recid 
								from big_table)a)b))c
group by unique_id
order by unique_id desc

end

go

declare 
@table_name varchar(500) = 'dbo.[FBNK_FUNDS_TRANSFER#HIS]', 
@bulk		int = 1000,
@start		int = 0

declare @loop bigint = 0, @table_rows float, @table_rows_loop float
declare @recid_from varchar(300), @recid_to varchar(300) 

select @table_rows = max(rows)
from sys.partitions
where object_id = object_id(@table_name)
set @table_rows_loop = @table_rows / @bulk

set @loop = @start
while @loop < ceiling(@table_rows_loop)
begin

insert into master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]
exec big_table_partitions @start = @loop, @offset_bulk = 1000000, @bulk = 1000

set @loop = @loop + 1
end



