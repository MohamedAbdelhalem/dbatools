use master
go
if object_id('[dbo].[big_table_partitions]') is not null
begin
drop procedure [dbo].[big_table_partitions]
end
go

--select RECID into dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019] from [T24SDC10].dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019] with (nolock)
--go
--set statistics profile off
--go
--ALTER table dbo.FBNK_AC_LOCKED_EVENTS_ARC_FEB2019 add constraint [PK_FBNK_AC_LOCKED_EVENTS_ARC_FEB2019] primary key (RECID)

create procedure [dbo].[big_table_partitions]
(@start bigint /*0*/, @offset_bulk bigint /*1000000*/, @bulk bigint /*1000*/)
as
begin

;with big_table as (
select row_number() over(order by recid) id, recid
from dbo.[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019]
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

select 
master.dbo.format(count(*) * 2000, -1) [number of summary data], 
ceiling((14730218.0 / 2000.0) / (1000000 / 2000)) [total loops],  
(14730218.0 / 2000.0) / (1000000 / 2000) * (cast(count(*) * 2000 as float)) / 14730218.0 * 100.0 /100.0  [current and start with]
from master.[dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5]
where from_id != to_id

use master
go
declare 
@table_name		varchar(1000) = '[dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019]', 
@offset_bulk	float = 1000000,
@bulk			float = 2000,
@start			float = 0

declare @loop bigint = 0, @table_rows float, @table_rows_loop float
declare @recid_from varchar(300), @recid_to varchar(300) 

select @table_rows = max(rows)
from sys.partitions
where object_id = object_id(@table_name)
set @table_rows_loop = (@table_rows / @bulk)

select @table_rows, @table_rows_loop, ceiling((@table_rows_loop + 1) / (@offset_bulk / @bulk))

set @loop = @start
while @loop < ceiling((@table_rows_loop + 1) / (@offset_bulk / @bulk))
begin

insert into master.[dbo].[FBNK_AC_LOCKED_EVENTS_ARC_FEB2019_summary5]
exec master.[dbo].big_table_partitions 
@start = @loop, 
@offset_bulk = @offset_bulk, 
@bulk = @bulk

set @loop = @loop + 1
end

