--parameters
declare 
@table_name		varchar(255)  = '[Sales].[SalesOrderHeader]',
@add_ranges_on		char(1)	      = 'L', --accepted values "R" for Right or "L" for Left
@bulk			decimal(12,0) = 1000,
@partition_column	varchar(255)  = 'SalesOrderID',
@useLastFileGroup	int 	      = 1,
@manualFileGroup	varchar(500)  = 'DL006'

--variables
declare
@partition_function varchar(255),
@partition_scheme	varchar(255),
@partition_rows		varchar(255),
@partition_from		varchar(255),
@Partition_Key		varchar(255),
@sql			nvarchar(max),
@biggest_value		bigint,
@smallest_value		bigint,
@loop			int = 1,
@psname			varchar(500),
@fgname			varchar(500),
@pscount		int

set nocount on
select 
@partition_function	= partition_function,
@partition_scheme	= partition_scheme,
@partition_from		= Partition_Value_From,
@Partition_Key		= Partition_Key_Value
from (
select 
'['+cast(pf.name as varchar(500))+']' Partition_Function, 
'['+cast(ps.name as varchar(500))+']' Partition_Scheme, al.table_name, partition_rows, partition_size,
master.dbo.numbersize(sum(total_pages) over(partition by al.table_name) *8.0,'k') table_size,
isnull((prv.boundary_id + boundary_value_on_right),al.partition_number) partition_number, 
cast(prv.value as varchar(255)) Partition_Key_Value, 
cast(LAG(prv.value,1,1) OVER(ORDER BY table_name, partition_number) as varchar(255)) Partition_Value_From,
case when prv.value is null then '>' else prv.value end Partition_Value_To,
min(partition_number) over() first_partition,
max(partition_number) over() last_partition
from (
select i.data_space_id, p.object_id, p.index_id,
'['+schema_name(schema_id)+'].['+t.name+']' table_name,partition_number,
master.dbo.format(max(rows),-1) partition_rows,
master.dbo.numbersize(sum(a.total_pages) * 8.0,'k') partition_size,sum(a.total_pages) total_pages
from sys.partitions p inner join sys.tables t
on p.object_id = t.object_id
inner join sys.allocation_units a
on (a.type in (1,3) and a.container_id = p.partition_id)
or (a.type in (2) and a.container_id = p.hobt_id)
inner join sys.indexes i
on  p.object_id = i.object_id
and p.index_id = i.index_id
where p.index_id = 1
group by i.data_space_id, schema_id, p.object_id, p.index_id, t.name,partition_number) al
inner join sys.partition_schemes ps
on al.data_space_id = ps.data_space_id
inner join sys.partition_functions pf
on ps.function_id = pf.function_id
left outer join sys.partition_range_values prv
on prv.function_id = pf.function_id
and (prv.boundary_id + boundary_value_on_right) = al.partition_number
where table_name = @table_name
)x
where partition_number = case @add_ranges_on when 'R' then last_partition when 'L' then first_partition end
order by table_name, partition_number

if @add_ranges_on = 'R'
begin
set @sql = N'Select Top 1 @output = max('+@partition_column+') FROM '+@table_name+' Where '+@partition_column+' > '+cast(@partition_from as varchar(50))
exec sp_executesql @sql, N'@output decimal(12,0) output', @output = @biggest_value output
end

set @loop = 0
select @pscount = count(*)
from sys.partition_schemes ps inner join sys.partition_functions pf
on ps.function_id = pf.function_id
where pf.name = replace(replace(@partition_function,']',''),'[','')

if @add_ranges_on = 'R'
begin
while @partition_from < @biggest_value
begin
	set @loop = 1
	while @loop < @pscount + 1
	begin
		select 
		@psname = psname, 
		@fgname = fgname
		from (
		select 
		row_number() over(order by ps.name) id,
		maxfg  = max(d.destination_id), 
		psname = ps.name, 
		fgname = fg.name,
		pfname = pf.name
		from sys.filegroups fg inner join sys.destination_data_spaces d
		on fg.data_space_id = d.data_space_id
		inner join sys.partition_schemes ps
		on ps.data_space_id = d.partition_scheme_id
		inner join sys.partition_functions pf
		on ps.function_id = pf.function_id
		group by ps.name, fg.name, pf.name)a
		where pfname = replace(replace(@partition_function,']',''),'[','')
		and id = @loop

		print('ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];')  
		print('GO')

		set @loop += 1
	end

	select @partition_from = @partition_from + @bulk 
	print('ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');')  
	print('GO')
end
end
else
if @add_ranges_on = 'L'
begin
	while (cast(@Partition_Key as bigint) - @bulk) > 0
	begin
		set @loop = 1
		while @loop < @pscount + 1
		begin
			select 
			@psname = psname, 
			@fgname = fgname
			from (
			select 
			row_number() over(order by ps.name) id,
			maxfg  = max(d.destination_id), 
			psname = ps.name, 
			fgname = fg.name,
			pfname = pf.name
			from sys.filegroups fg inner join sys.destination_data_spaces d
			on fg.data_space_id = d.data_space_id
			inner join sys.partition_schemes ps
			on ps.data_space_id = d.partition_scheme_id
			inner join sys.partition_functions pf
			on ps.function_id = pf.function_id
			group by ps.name, fg.name, pf.name)a
			where pfname = replace(replace(@partition_function,']',''),'[','')
			and id = @loop

			print('ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];')  
			print('GO')
			set @loop += 1
		end

		set @Partition_Key -= @bulk
		print('ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@Partition_Key as varchar(200))+');')  
		print('GO')
	end
end

set nocount off
