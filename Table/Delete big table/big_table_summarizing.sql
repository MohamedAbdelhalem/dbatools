use master
go
declare
@table_name				nvarchar(500)	= '[PRODmfreportsdbBAB].[dbo].[middleware_requests]', 
@bulk					int				= 1000, --max value 3,000 rows
@cluster_index_key		nvarchar(300)	= '[id]',
@stop_date_column		nvarchar(300)	= '[ts]',
@start					int				= 0

declare 
@loop					bigint = 0, 
@go_or_no_go			int = 1,
@sql_get_ids			nvarchar(max), 
@sql_go_nogo			nvarchar(max), 
@till_date				datetime = dateadd(month, -13, convert(nvarchar(10),dateadd(day,-day(getdate()),getdate()) + 1,120)),
@date_time				datetime,
@cluster_index_key_from bigint, 
@cluster_index_key_to	bigint

set nocount on

while @go_or_no_go = 1
begin

set @sql_get_ids = 'select @output_from = min('+@cluster_index_key+'), @output_to = max('+@cluster_index_key+')
from (
select top '+cast(@bulk as nvarchar(15))+' '+@cluster_index_key+'
from '+@table_name+'
where '+@cluster_index_key+' > '+cast(isnull(@cluster_index_key_to,0) as varchar(40))+'
order by '+@cluster_index_key+')a'
print(@sql_get_ids)

exec sp_executesql 
@sql_get_ids, 
N'@output_from bigint output, @output_to bigint output', 
@cluster_index_key_from output, 
@cluster_index_key_to	output

set @sql_go_nogo = 'select @output_go = case when '+@stop_date_column+' < '+''''+convert(varchar(50),@till_date,121)+''''+' then 1 else 0 end, @output_date = convert(varchar(10), '+@stop_date_column+', 120)
from '+@table_name+'
where '+@cluster_index_key+' = '+cast(@cluster_index_key_to as varchar(40))
--print(@sql_go_nogo)

exec sp_executesql 
@sql_go_nogo, 
N'@output_go int output, @output_date datetime output', 
@go_or_no_go output, 
@date_time output

insert into master.dbo.[middleware_requests_summary2] (unique_id, from_id, to_id, from_unique_column, to_unique_column, date_time, deleted)
select  1, 0 + (@loop * @bulk) +1 , (0 + (@loop * @bulk)) + @bulk, @cluster_index_key_from, @cluster_index_key_to, @date_time, 0

set @loop = @loop + 1
end

update master.dbo.[middleware_requests_summary2]
set unique_id = 0 where id = (select max(id) from master.dbo.[middleware_requests_summary2])

set @sql_get_ids = 'select @output_from = min('+@cluster_index_key+'), @output_to = max('+@cluster_index_key+')
from (
select top '+cast(@bulk as nvarchar(15))+' '+@cluster_index_key+'
from '+@table_name+'
where '+@cluster_index_key+' between '+cast(isnull(@cluster_index_key_from,0) as varchar(40))+' and '+cast(isnull(@cluster_index_key_to,0) as varchar(40))+'
and '+@stop_date_column+' < '+''''+convert(varchar(50),@till_date,121)+''''+'
order by '+@cluster_index_key+')a'
--print(@sql_get_ids)

exec sp_executesql 
@sql_get_ids, 
N'@output_from bigint output, @output_to bigint output', 
@cluster_index_key_from output, 
@cluster_index_key_to output

insert into master.dbo.[middleware_requests_summary2] (unique_id, from_id, to_id, from_unique_column, to_unique_column, date_time, deleted)
select  1, 0 + (@loop * @bulk) +1 , (0 + (@loop * @bulk)) + @bulk, @cluster_index_key_from, @cluster_index_key_to, @date_time, 0

set nocount off
go

--truncate table master.dbo.[middleware_requests_summary2]

--select * from  master.dbo.[middleware_requests_summary2]