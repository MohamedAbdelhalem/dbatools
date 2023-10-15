declare @date_time varchar(200), @delay_day int = 0
set @date_time = 'convert(datetime,convert(varchar(10),getdate()-'+cast(@delay_day as varchar(10))+',120),120) and dateadd(ms,-2,dateadd(day,1,convert(varchar(10),getdate()-'+cast(@delay_day as varchar(10))+',120)))'
print(@date_time)

exec [master].[dbo].[sp_latency_history]
@filter					= 0,
--@date					= '2023-05-28 02:30:00 and 2023-05-28 03:30:00',
@date					= -1,
@order_by				= 'date', --date, Latency
@order_by_node			= 2, --0 = all or 1,2,3,4
@database				= NULL,
@desc					= 0,
@only_job				= 0

