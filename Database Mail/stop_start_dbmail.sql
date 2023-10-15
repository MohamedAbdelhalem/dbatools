USE msdb
go

select top 100 * from msdb..sysmail_allitems
order by sent_date desc

select * from msdb.dbo.sysmail_account

exec msdb.dbo.sysmail_stop_sp
 
exec msdb.dbo.sysmail_start_sp
