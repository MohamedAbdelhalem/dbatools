use DatabaseName
go
--parameters
declare 
@table_name				varchar(500) = '[dbo].[MAIL_ARCHIVE]',
@ci_or_pk_column_name	varchar(500) = 'EMAIL_ID',
@date_column_name		varchar(500) = 'EMAIL_TIME',
@keep_days				int = '31',
@action					varchar(100) = 'delete', --accepted values (select *, select count(*), delete)
@bulk					int = 1000, -- between 1000 and 3000 depend on sys.dm_tran_locks
@exec					int = 1 --1=print, 2=execute
 
--select top 100
--master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLoDcFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
--master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
--master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid,
--*
--from [dbo].[BACKEND_EVENT]
 
--variables
declare 
@sql_nonclustered	varchar(max),
@sql_bulk_delete	varchar(max),
@ci_type_name_desc	varchar(100),
@ci_type_name		varchar(100),
@key_ordinal		int
 
select top 1 @key_ordinal = ic.key_ordinal
from sys.indexes i inner join sys.index_columns ic
on i.object_id = ic.object_id 
and i.index_id = ic.index_id
inner join sys.columns c
on ic.object_id = c.object_id
and ic.column_id = c.column_id
where i.object_id = object_id(@table_name)
and c.name = @date_column_name
order by ic.key_ordinal
 
 
if isnull(@key_ordinal,0) = 0 or isnull(@key_ordinal,0) > 1
begin
set @sql_nonclustered = 'CREATE NONCLUSTERED INDEX IDX_'+@date_column_name+'_'+replace(replace(replace(@table_name,']',''),'[',''),'.','_')+' ON '+@table_name+' (['+@date_column_name+']) WITH (ONLINE=ON, MAXDOP=4)'
print(@sql_nonclustered)
end
else
begin
 
select 
@ci_type_name = tp.name,
@ci_type_name_desc = case 
when tp.name in ('varchar','char') then tp.name+'('+cast((c.max_length * 2) as varchar(100))
when tp.name in ('nvarchar','nchar') then tp.name+'('+cast((c.max_length * 2) as varchar(100))+')'
when tp.name in ('decimal','numeric') then tp.name+'('+cast(c.[precision] as varchar(100))+','+cast(c.scale as varchar(100))+')'
else tp.name end
from sys.tables t inner join sys.columns c
on t.object_id = c.object_id
inner join sys.types tp
on c.user_type_id = tp.user_type_id
where t.object_id = object_id(@table_name)
and c.name = @ci_or_pk_column_name
 
set @sql_bulk_delete = '
use ['+db_name(db_id())+']
 
declare 
@gid		bigint,
@min_value '+@ci_type_name_desc+',
@max_value '+@ci_type_name_desc+',
@count		int = 0,
@times		int = 0
 
declare delete_cursor cursor fast_forward
for
select gid, min(['+@ci_or_pk_column_name+']), max(['+@ci_or_pk_column_name+'])
from (
select master.dbo.gbulk(row_number() over(order by ['+@ci_or_pk_column_name+']), '+cast(@bulk as varchar(100))+') gid, ['+@ci_or_pk_column_name+']
from '+@table_name+' WITH (NOLOCK)
where ['+@date_column_name+'] < '+''''+convert(varchar(10),dateadd(day,-@keep_days,getdate()),120)+''''+')a
group by gid
order by gid
 
open delete_cursor
fetch next from delete_cursor into @gid, @min_value, @max_value
while @@fetch_status = 0
begin
 
'+case when ltrim(rtrim(@action)) = 'select count(*)' then replace(@action,'count(*)','@count = @count + count(*)')
else @action end+' from '+@table_name+' where '+@ci_or_pk_column_name+' between @min_value and @max_value
 
'+case when ltrim(rtrim(@action)) = 'select count(*)' then 'set @times += 1' else '' end+'
fetch next from delete_cursor into @gid, @min_value, @max_value
end
close delete_cursor
deallocate delete_cursor
 
'+case when ltrim(rtrim(@action)) = 'select count(*)' then 'select format(@count,''###,###,###'') total_count_rows, format(@times,''###,###,###'') number_of_deletes' else '' end
 
if (ltrim(rtrim(@action)) in ('select count(*)','select *'))
begin
	if @exec in (1)
	begin
		print(@sql_bulk_delete)
	end
	else
	if @exec in (2)
	begin
		exec(@sql_bulk_delete)
	end
end
else
begin
	print(@sql_bulk_delete)
end
end
 
