--parameters
declare 
@dml_operation	varchar(100) = 'insert',
@bulk			int = 1000,
@using_CI		bit = 1,
--When a clustered index key column is not utilized and no alternative is available, use a standard column is the subsequent option.
--then use Non-clustered index column BUT THIS COLUMN BE UNIQUE 
--e.g. 
--[INT] with Identity
--[DATETIME] with default Getdate() NOT [DATE], DO NOT USE [DATE] data type 
@where_condition varchar(max) = 'Where SalesOrderID between 46659 and 64600',
--place in @where_condition parameter the filter you want or type 'default'
@column_name	varchar(255) = 'OrderDate', 
@column_type	varchar(255) = 'datetime',
--Expected values for DML Operations
--Delete
--Select COUNT(*)
--Select COUNT
@source_db	varchar(355) = db_name(db_id()),
@source_table	varchar(355) = '[Sales].[SalesOrderHeader]',
@destinationDB	varchar(355) = 'AdventureWorks2019',
@destinationTB	varchar(355) = '[Sales].[SalesOrderHeader]'

--variables
declare
@sql		 varchar(max),
@columns	 varchar(max)

select @source_db		= '['+replace(replace(@source_db,']',''),'[','')+']'
select @source_table	= '['+replace(replace(substring(@source_table,1,charindex('.',@source_table)-1),']',''),'[','')+']'+'.'+'['+replace(replace(substring(@source_table,charindex('.',@source_table)+1,len(@source_table)),']',''),'[','')+']'
select @destinationDB	= '['+replace(replace(@destinationDB,']',''),'[','')+']'
select @destinationTB	= '['+replace(replace(substring(@destinationTB,1,charindex('.',@destinationTB)-1),']',''),'[','')+']'+'.'+'['+replace(replace(substring(@destinationTB,charindex('.',@destinationTB)+1,len(@destinationTB)),']',''),'[','')+']'

if @dml_operation in ('delete','select *','select count(*)')
begin
if @using_CI = 1
begin
	select top 1
	@column_name = c.name, 
	@column_type = t.name
	from sys.columns c inner join sys.types t
	on c.user_type_id = t.user_type_id
	inner join sys.indexes i 
	on c.object_id = i.object_id 
	inner join sys.index_columns ic 
	on i.object_id = ic.object_id 
	and i.index_id = ic.index_id 
	and c.column_id = ic.column_id 
	where c.object_id = object_id(@source_table)
	and i.index_id = 1
	order by c.is_identity desc
end
end
else if @dml_operation = 'insert' and @destinationTB != 'default' and @destinationDB != 'default'
begin
if @using_CI = 1
begin
	select top 1
	@column_name = c.name, 
	@column_type = t.name
	from sys.columns c inner join sys.types t
	on c.user_type_id = t.user_type_id
	inner join sys.indexes i 
	on c.object_id = i.object_id 
	inner join sys.index_columns ic 
	on i.object_id = ic.object_id 
	and i.index_id = ic.index_id 
	and c.column_id = ic.column_id 
	where c.object_id = object_id(@source_table)
	and i.index_id = 1
	order by c.is_identity desc
end
select @columns = isnull(@columns+',','') + '['+c.name+']'
from sys.columns c
where object_id = object_id(@source_table)
order by c.column_id
end

set @sql = '
select gbulk_id, 
min(dataValues) From_'+@column_name+', 
max(dataValues) To_'+@column_name+', 
format(sum(count(*)) over(),''###,###,###'') Table_total_rows, 
format(count(*),''###,###,###'') Rows_per_patch, '+case 
when @column_type in ('tinyint','smallint','int','bigint','float','numeric','decimal') then 
''''+case @dml_operation when 'insert' then 'insert into '+@destinationDB+'.'+@destinationTB+' ('+@columns+') 
select '+@columns else @dml_operation end+
' From '+@source_db+'.'+@source_table+' Where '+@column_name+' between ''+cast(min(dataValues) as varchar(100))+'' and ''+cast(max(dataValues) as varchar(100))+'''' dml_script'
when @column_type in ('date','datetime','datetime2') then 
''''+case @dml_operation when 'insert' then 'insert into '+@destinationDB+'.'+@destinationTB+' ('+@columns+') 
select '+@columns else @dml_operation end+
' From '+@source_db+'.'+@source_table+' Where '+@column_name+' between ''+''''''''+convert(varchar(50),min(dataValues),121)+''''''''+'' and ''+''''''''+convert(varchar(50),max(dataValues),121)+''''''''+'''' dml_script'
else
''''+case @dml_operation when 'insert' then 'insert into '+@destinationDB+'.'+@destinationTB+' ('+@columns+') 
select '+@columns else @dml_operation end+
' From '+@source_db+'.'+@source_table+' Where '+@column_name+' between ''+''''''''+cast(min(dataValues) as varchar(100))+''''''''+'' and ''+''''''''+cast(max(dataValues) as varchar(100))+''''''''+'''' dml_script'
end +'
from (
select 
master.dbo.gbulk(row_number() over(order by '+@column_name+'),'+cast(@bulk as varchar(50))+') gbulk_id, 
'+@column_name+' dataValues 
from '+@source_table+'
'+case when @where_condition = 'default' then '' else @where_condition end+')a
group by gbulk_id
order by gbulk_id'

exec(@sql)
print(@sql)


