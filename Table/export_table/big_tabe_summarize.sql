use []-- create the procedure on the user database
go
drop table master.dbo.[middleware_requests_summary]
go
create table master.dbo.[middleware_requests_summary]
(id bigint identity(1,1), unique_id bigint, from_id bigint, to_id bigint, from_unique_column varchar(500), to_unique_column varchar(500))
go
create or alter procedure big_tabe_summarize
(
@table_name varchar(500) = 'dbo.[middleware_requests_summary]', 
@bulk		int = 1000,
@start		int = 0)
as
begin
declare @loop bigint = 0, @table_rows float, @table_rows_loop float
declare @recid_from varchar(300), @recid_to varchar(300) 

select @table_rows = max(rows)
from sys.partitions
where object_id = object_id(@table_name)
set @table_rows_loop = @table_rows / @bulk

set @loop = @start
while @loop < ceiling(@table_rows_loop)
begin

;with big_table as (
select id
from [PRODmfreportsdbBAB].dbo.[middleware_requests]
order by id
OFFSET 0 + (@loop * @bulk) ROWS FETCH NEXT @bulk ROWS ONLY)
select @recid_from = min(id), @recid_to = max(id)
from big_table

insert into master.dbo.[middleware_requests_summary] (from_id, to_id, from_unique_column, to_unique_column)
select  0 + (@loop * @bulk) +1 , (0 + (@loop * @bulk)) + @bulk, @recid_from, @recid_to

set @loop = @loop + 1
end
end

go


exec big_tabe_summarize
@table_name = 'dbo.[FBNK_FUNDS_TRANSFER#HIS]', 
@bulk		= 10000,
@start		= 15312

