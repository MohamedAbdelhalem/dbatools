USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_big_table_summarizing]    Script Date: 3/9/2023 9:39:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_big_table_summarizing](
@table_name				nvarchar(500)	= [PRODmfreportsdbBAB].[dbo].[middleware_requests], 
@summary_table			nvarchar(500)	= [master].[dbo].[middleware_requests_summary2],
@bulk					int				= 1000, --max value 3,000 rows
@cluster_index_key		nvarchar(300)	= [id],
@stop_date_column		nvarchar(300)	= [ts],
@keep_months			int				= 13
)
as
begin
declare 
@loop					bigint = 0, 
@go_or_no_go			int = 1,
@sql_get_ids			nvarchar(max), 
@sql_go_nogo			nvarchar(max), 
@sql_insert				nvarchar(max), 
@till_date				datetime = dateadd(month, - @keep_months, convert(nvarchar(10),dateadd(day,-day(getdate()),getdate()) + 1,120)),
@date_time				datetime,
@cluster_index_key_from bigint, 
@cluster_index_key_to	bigint

set nocount on

while @go_or_no_go = 1
begin

set @sql_get_ids = select @output_from = min(+@cluster_index_key+), @output_to = max(+@cluster_index_key+)
from (
select top +cast(@bulk as nvarchar(15))+ +@cluster_index_key+
from +@table_name+
where +@cluster_index_key+ > +cast(isnull(@cluster_index_key_to,0) as varchar(40))+
order by +@cluster_index_key+)a
--print(@sql_get_ids)

exec sp_executesql 
@sql_get_ids, 
N@output_from bigint output, @output_to bigint output, 
@cluster_index_key_from output, 
@cluster_index_key_to	output

set @sql_go_nogo = select @output_go = case when +@stop_date_column+ < ++convert(varchar(50),@till_date,121)++ then 1 else 0 end, @output_date = convert(varchar(10), +@stop_date_column+, 120)
from +@table_name+
where +@cluster_index_key+ = +cast(@cluster_index_key_to as varchar(40))
--print(@sql_go_nogo)

exec sp_executesql 
@sql_go_nogo, 
N@output_go int output, @output_date datetime output, 
@go_or_no_go output, 
@date_time output

set @sql_insert = insert into +@summary_table+ (unique_id, from_id, to_id, from_unique_column, to_unique_column, date_time, deleted)
select  1, +cast(0 + (@loop * @bulk) + 1 as varchar(50))+, +cast((0 + (@loop * @bulk)) + @bulk as varchar(50))+, +cast(@cluster_index_key_from as varchar(50))+, +cast(@cluster_index_key_to as varchar(50))+, ++convert(varchar(50),@date_time,120)++, 0

exec sp_executesql 
@sql_insert 
--print(@sql_insert)

set @loop = @loop + 1
end

set @sql_insert = update +@summary_table+ 
set unique_id = 0 
where id = (select max(id) from +@summary_table+)

exec sp_executesql 
@sql_insert 

set @sql_get_ids = select @output_from = min(+@cluster_index_key+), @output_to = max(+@cluster_index_key+)
from (
select top +cast(@bulk as nvarchar(15))+ +@cluster_index_key+
from +@table_name+
where +@cluster_index_key+ between +cast(isnull(@cluster_index_key_from,0) as varchar(40))+ and +cast(isnull(@cluster_index_key_to,0) as varchar(40))+
and +@stop_date_column+ < ++convert(varchar(50),@till_date,121)++
order by +@cluster_index_key+)a
--print(@sql_get_ids)

exec sp_executesql 
@sql_get_ids, 
N@output_from bigint output, @output_to bigint output, 
@cluster_index_key_from output, 
@cluster_index_key_to output

set @sql_insert = insert into +@summary_table+ (unique_id, from_id, to_id, from_unique_column, to_unique_column, date_time, deleted)
select  1, +cast(0 + (@loop * @bulk) + 1 as varchar(50))+, +cast((0 + (@loop * @bulk)) + @bulk as varchar(50))+, +cast(@cluster_index_key_from as varchar(50))+, +cast(@cluster_index_key_to as varchar(50))+, ++convert(varchar(50),@date_time,120)++, 0

exec sp_executesql 
@sql_insert 
--print(@sql_insert)

set nocount off
end
