--generate partition function and scheme for datetime on different column
set nocount on
--parameters
declare 
@table_name				varchar(300) = 'dbo.SalesOrderHeader',
@CI_column_name			varchar(300) = 'SalesOrderID',
@date_column_name		varchar(300) = 'OrderDate',
@date_partition_by		varchar(50) = 'year_2012_2017', --accepted values year_2012_2025, month, day_2012_2025
@date_partition_range	varchar(10) = 'right',
@use_primary_fg			int = 0,
@filegroup_prefix		varchar(200) = 'fg'
--declare @table table (id int identity(1,1), dataValues int)
--declare @min_value int, @max_value int, @sql varchar(max)

--variables
declare
@to			int,
@from		int, 
@loop		int = 0,
@f_sql		varchar(max),
@fg_sql		varchar(max),
@ps_sql		varchar(max),
@pf_sql		varchar(max),
@fg_name	varchar(500)

if master.dbo.vertical_array(@date_partition_by,'_',1) = 'year'
begin
select 
@from = master.dbo.vertical_array(@date_partition_by,'_',2),
@to = master.dbo.vertical_array(@date_partition_by,'_',3)

set @loop = @from
if @use_primary_fg = 1
begin

while @loop < @to + 1
begin 
select @ps_sql = ISNULL(@ps_sql+',','') + '[PRIMARY]'
select @pf_sql = ISNULL(@pf_sql+',','') + ''''+cast(@loop as varchar(10))+'-01-01'+''''
set @loop += 1
end
select @ps_sql = ISNULL(@ps_sql+',','') + '[PRIMARY]'

end
else
begin
while @loop < @to + 1
begin 
select @ps_sql = ISNULL(@ps_sql+',','') + '['+@filegroup_prefix+'_'+cast(@loop as varchar(10))+']'
select @pf_sql = ISNULL(@pf_sql+',','') + ''''+cast(@loop as varchar(10))+'-01-01'+''''
set @loop += 1
end
select @ps_sql = ISNULL(@ps_sql+',','') + '['+@filegroup_prefix+'_'+cast((@to+1) as varchar(10))+']'

declare fg_cursor cursor fast_forward
for
select ltrim(rtrim(replace(replace(value,']',''),'[','')))
from master.dbo.Separator(@ps_sql,',')
order by id

open fg_cursor
fetch next from fg_cursor into @fg_name
while @@FETCH_STATUS = 0
begin
set @fg_sql = 'alter database ['+DB_NAME(db_id())+'] add filegroup ['+@fg_name+'];'
print(@fg_sql)
print('go')
set @f_sql = 'alter database ['+DB_NAME(db_id())+'] add file 
(name='+''''+replace(@fg_name,@filegroup_prefix,'file')+'_01'', filename=''<PATH>\'+DB_NAME(db_id())+'_'+replace(@fg_name,@filegroup_prefix,'file')+'_01.ndf'', size=100MB, filegrowth=64MB) To Filegroup ['+@fg_name+'];'
print(@f_sql)
print('go')
fetch next from fg_cursor into @fg_name
end
close fg_cursor
deallocate fg_cursor

end

print('CREATE PARTITION FUNCTION [PF_'+replace(replace(replace(@table_name,']',''),'[',''),'.','_')+'_'+@date_partition_range+'](datetime)
AS
RANGE '+@date_partition_range+' FOR VALUES (
'+@pf_sql+'
);')

print('go')

print('CREATE PARTITION SCHEME [PS_'+replace(replace(replace(@table_name,']',''),'[',''),'.','_')+'_'+@date_partition_range+']
AS PARTITION [PF_'+replace(replace(replace(@table_name,']',''),'[',''),'.','_')+'_'+@date_partition_range+']
TO
(
'+@ps_sql+'
);')

print('go')

print('--ALTER TABLE '+@table_name+' DROP CONSTRAINT <PK_CI_NAME>;')
print('ALTER TABLE '+@table_name+' ADD CONSTRAINT <PK_CI_NAME> PRIMARY KEY (['+@CI_column_name+'],['+@date_column_name+']) WITH (ONLINE=ON) ON [PS_'+replace(replace(replace(@table_name,']',''),'[',''),'.','_')+'_'+@date_partition_range+'](['+@date_column_name+']);')

end

set nocount off
