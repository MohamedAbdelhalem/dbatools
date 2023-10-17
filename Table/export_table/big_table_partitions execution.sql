declare 
@table_name varchar(500) = 'dbo.[FBNK_FUNDS_TRANSFER#HIS]', 
@start		int = 0

declare @loop bigint = 0, @table_rows float, @table_rows_loop float
declare @recid_from varchar(300), @recid_to varchar(300) 

select @table_rows = max(rows)
from sys.partitions
where object_id = object_id(@table_name)
set @table_rows_loop = @table_rows / 1000000.0

set @loop = @start
while @loop < ceiling(@table_rows_loop)
begin

insert into master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]
exec big_table_partitions @start = @loop, @offset_bulk = 1000000, @bulk = 1000

set @loop = @loop + 1
end

--select * from master.dbo.[FBNK_FUNDS_TRANSFER#HIS_summary4]