--parameters
declare 
@table_name		varchar(255)  = '[Sales].[SalesOrderHeader]',
@position		char(1)       = 'm', --accepted values "R" for Right or "L" for Left or "M" for Manual, and this parameter will be ignored when @alter = 'MERGE'
@alter			char(5)       = 'split', --accepted values "SPLIT" or "MERGE"
@manual_split		int           = 0, --not yet activated
@from_partition		int           = 152,
@to_partition		int           = 0,
@bulk			decimal(12,0) = 1000,
@partition_column	varchar(255)  = 'SalesOrderID',
@useLastFileGroup	int           = 1,
@manualFileGroup	varchar(500)  = 'DL006',
@action			int           = 3

--variables
declare
@partition_function 	varchar(255),
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
@pscount		int,
@executesql		varchar(2000)

if @alter in ('SPLIT','MERGE')
begin
	set nocount on
	select 
	@partition_function = partition_function,
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
	on (a.type in (1,3) and a.container_id = p.hobt_id)
	or (a.type = 2 and a.container_id = p.partition_id)
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
	where (@position in ('R','L') and partition_number = case @position when 'R' then last_partition when 'L' then first_partition end)
	or
	(@position in ('M') and partition_number = @from_partition)
	order by table_name, partition_number

	if @position = 'R' and @alter = 'SPLIT'
	begin
		set @sql = N'Select Top 1 @output = max('+@partition_column+') FROM '+@table_name+' Where '+@partition_column+' > '+cast(@partition_from as varchar(50))
		exec sp_executesql @sql, N'@output decimal(12,0) output', @output = @biggest_value output
	end

	set @loop = 0
	select @pscount = count(*)
	from sys.partition_schemes ps inner join sys.partition_functions pf
	on ps.function_id = pf.function_id
	where pf.name = replace(replace(@partition_function,']',''),'[','')

	if @position = 'R' and @alter = 'SPLIT'
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

				if @action = 1
				begin
					print('ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];')  
					print('GO')
				end
				else
				if @action = 2
				begin
					set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
					exec(@executesql)
				end
				else
				if @action = 3
				begin
					set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
					exec(@executesql)
					print(@executesql)
					print('GO')
				end
			end
			set @loop += 1
		end
		select @partition_from = @partition_from + @bulk 
		if @action = 1
		begin
			print('ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');')  
			print('GO')
		end
		else
		if @action = 2
		begin
			set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');'
			exec(@executesql)  
		end
		else
		if @action = 3
		begin
			set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');'
			exec(@executesql)  
			print(@executesql)  
			print('GO')
		end
	end
	else
	if @position = 'M' and @alter = 'SPLIT' and @from_partition > 0 and @to_partition = 0 and @from_partition != 1 and 
	(cast(@Partition_Key as decimal(12,0)) - cast(@partition_from as decimal(12,0)) - @bulk) > 0
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

			if @action = 1
			begin
				print('ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];')  
				print('GO')
			end
			else
			if @action = 2
			begin
				set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
				exec(@executesql)
			end
			else
			if @action = 3
			begin
				set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
				exec(@executesql)
				print(@executesql)
				print('GO')
			end
			set @loop += 1
		end
		select @partition_from = @Partition_Key - @bulk 
		if @action = 1
		begin
			print('ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');')  
			print('GO')
		end
		else
		if @action = 2
		begin
			set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');'
			exec(@executesql)
		end
		else
		if @action = 3
		begin
			set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@partition_from as varchar(200))+');'
			exec(@executesql)
			print(@executesql)
			print('GO')
		end
	end
	else
	if @position = 'L' and @alter = 'SPLIT'
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

				if @action = 1
				begin
					print('ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];')  
					print('GO')
				end
				else
				if @action = 2
				begin
					set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
					exec(@executesql)
				end
				else
				if @action = 3
				begin
					set @executesql = 'ALTER PARTITION SCHEME '+@psname+' NEXT USED ['+case when @useLastFileGroup = 1 then @fgname else @manualFileGroup end +'];'
					exec(@executesql)
					print(@executesql)
				end
				set @loop += 1
			end
			set @Partition_Key -= @bulk

			if @action = 1
			begin
				print('ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@Partition_Key as varchar(200))+');')  
				print('GO')
			end
			else
			if @action = 2
			begin
				set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@Partition_Key as varchar(200))+');'
				exec(@executesql)
			end
			else
			if @action = 3
			begin
				set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() SPLIT RANGE ('+cast(@Partition_Key as varchar(200))+');'
				exec(@executesql)
				print(@executesql)
				print('GO')
			end
		end
	end
	else
		if @alter = 'Merge' and @from_partition > 0 and @to_partition > 0
		begin
			declare merge_partitions_cur cursor fast_forward
			for
			select Partition_Key_Value
			from (
			select 
			'['+cast(pf.name as varchar(500))+']' Partition_Function, 
			partition_number,
			partition_rows, 
			cast(prv.value as varchar(255)) Partition_Key_Value 
			from (
			select i.data_space_id, p.object_id, p.index_id,
			'['+schema_name(schema_id)+'].['+t.name+']' table_name,partition_number,
			master.dbo.format(max(rows),-1) partition_rows
			from sys.partitions p inner join sys.tables t
			on p.object_id = t.object_id
			inner join sys.allocation_units a
			on (a.type in (1,3) and a.container_id = p.hobt_id)
			or (a.type = 2 and a.container_id = p.partition_id)
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
			where partition_number between @from_partition and @to_partition
			order by partition_number

			open merge_partitions_cur
			fetch next from merge_partitions_cur into @Partition_Key
			while @@FETCH_STATUS = 0
			begin
				if @action = 1
				begin
					print('ALTER PARTITION FUNCTION '+@partition_function+'() MERGE RANGE ('+cast(@Partition_Key as varchar(200))+');')  
					print('GO')
				end
				else
				if @action = 2
				begin
					set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() MERGE RANGE ('+cast(@Partition_Key as varchar(200))+');'
					exec(@executesql)
				end
				else
				if @action = 3
				begin
					set @executesql = 'ALTER PARTITION FUNCTION '+@partition_function+'() MERGE RANGE ('+cast(@Partition_Key as varchar(200))+');'
					exec(@executesql)
					print(@executesql)
					print('GO')
				end
			fetch next from merge_partitions_cur into @Partition_Key
			end
			close merge_partitions_cur 
			deallocate merge_partitions_cur 
	end
	set nocount off
end

