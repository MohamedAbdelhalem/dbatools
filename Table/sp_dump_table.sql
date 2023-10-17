
exec [dbo].[sp_dump_table]
@table = '[dbo].[MESSAGE_OUT_BKP]', 
@new_name = '[dbo].[MESSAGE_OUT_BKP_fawzy]', 
@migrated_to = 'MS SQL Server', 
@columns = 'all',
@where_records_condition = 'where CREATION_TIME between ''2022-05-25'' and getdate()',
@with_computed = 0, 
@header = 0, 
@bulk = 1000, 
@patch = 1

exec [dbo].[sp_dump_table]
@table = '[dbo].[BACKEND_OBJECT]', 
@new_name = 'default', 
@migrated_to = 'MS SQL Server', 
@columns = 'all',
@where_records_condition = 'default',
@with_computed = 0, 
@header = 0, 
@bulk = 1000, 
@patch = 0

