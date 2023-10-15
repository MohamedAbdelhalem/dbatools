create Procedure [dbo].[sp_recommended_missing_indexes]
as
begin
declare @table table (Create_index varchar(max), database_name varchar(250), table_name varchar(500),
unique_compiles int, 
requested_times int,
avg_estimate_query_cost float,
avg_improvment_of_est_query_cost float)

declare @objects table (object_name varchar(500))
declare 
@object_id varchar(50),
@database_name varchar(250),
@i1 varchar(35),
@i2 varchar(250),
@i3 varchar(5),
@i4 varchar(500),
@i5 varchar(5),
@i6 varchar(1000),
@i7 varchar(1000),
@index_keys varchar(500),
@unique_compiles int, 
@requested_times int,
@avg_estimate_query_cost float,
@avg_improvment_of_est_query_cost float

declare @output varchar(10), @object_name_output varchar(250)
declare @sql nvarchar(max)
DECLARE @ParmDefinition nvarchar(500)

declare cursor_indexes cursor fast_forward
for
select  
object_id, database_name, i1, i2, i3, i4, i5, i6, i7, index_keys, gs.unique_compiles, 
gs.user_seeks + gs.user_scans, avg_total_user_cost, avg_user_impact
from (
select index_handle,
object_id, replace(replace(substring(statement,1,charindex('.',statement)-1),']',''),'[','') database_name,
'Create Nonclustered Index [IDX_' i1,
replace(replace(reverse(substring(reverse(statement),1,charindex('.',reverse(statement))-1)),']',''),'[','') i2,
'] on ' i3,
[statement] i4,
' (' i5,
case 
when equality_columns is null then inequality_columns 
when equality_columns is not null and inequality_columns is not null then equality_columns + ',' + inequality_columns
else equality_columns end i6,
isnull(') Include ('+included_columns+')',')') i7,
replace(replace(replace(replace(
case 
when equality_columns is null then inequality_columns 
when equality_columns is not null and inequality_columns is not null then equality_columns + ',' + inequality_columns
else equality_columns end,']',''),'[',''),',','_'),' ','') index_keys
from sys.dm_db_missing_index_details) mid
inner join sys.dm_db_missing_index_groups g 
on mid.index_handle = g.index_handle
inner join sys.dm_db_missing_index_group_stats gs 
on g.index_group_handle = gs.group_handle

open cursor_indexes
fetch next from cursor_indexes into @object_id,@database_name,@i1,@i2,@i3,@i4,@i5,@i6,@i7,@index_keys,
@unique_compiles, 
@requested_times,
@avg_estimate_query_cost,
@avg_improvment_of_est_query_cost

while @@fetch_status = 0
begin

set @sql = 'use ['+@database_name+']
select @object_name = object_name(object_id), @output_inside = count(*) from ['+@database_name+'].[sys].[indexes] where index_id > 1 and object_id = '+@object_id+' group by object_id'
SET @ParmDefinition = N'@output_inside int OUTPUT, @object_name varchar(250) OUTPUT';
EXEC sp_executesql @sql, @ParmDefinition, @output_inside = @output OUTPUT, @object_name = @object_name_output OUTPUT;

insert into @objects values (@object_name_output)
select @output = @output + count(*) from @objects where object_name = @object_name_output

insert into @table values (
@i1+@index_keys+'_'+@i2+'__'+@output+@i3+@i4+@i5+@i6+@i7, 
@database_name, 
master.dbo.virtical_array(@i4, '.',3),
@unique_compiles, 
@requested_times,
@avg_estimate_query_cost,
@avg_improvment_of_est_query_cost
)

fetch next from cursor_indexes into @object_id,@database_name,@i1,@i2,@i3,@i4,@i5,@i6,@i7,@index_keys,
@unique_compiles, 
@requested_times,
@avg_estimate_query_cost,
@avg_improvment_of_est_query_cost
end
close cursor_indexes
deallocate cursor_indexes

select Database_Name,  table_name,
Create_Index, 
unique_compiles, 
requested_times,
cast(round(avg_estimate_query_cost,2) as varchar)+' qb$' avg_estimate_query_cost ,
cast(round(avg_improvment_of_est_query_cost,2) as varchar)+' %' avg_improvment_of_est_query_cost
from @table
where database_name != 'tempdb'
order by cast(avg_estimate_query_cost as int) desc
--order by cast(substring(avg_estimate_query_cost,1,charindex(' ',avg_estimate_query_cost)-1) as int) desc
end