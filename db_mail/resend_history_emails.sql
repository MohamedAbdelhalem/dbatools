
declare @emails table (mailitem_id bigint)
declare
@db_mail_profile	varchar(100),
@subject			varchar(1000),
@email				varchar(1000) = 'MFawzyAlHaleem@Bankalbilad.com',
@ccemail			varchar(1000),
@bformat			varchar(100),
@email_body			varchar(max)

insert into @emails
select top 5 mailitem_id
from msdb.dbo.sysmail_allitems
where send_request_date > '2023-09-26'
and subject = 'T24 Top 50 IO Report on DB Server D1T24DBSQPWV4'

declare send_bulk_emails cursor fast_forward
for
select p.name profile_name, body_format, subject, body
from msdb.dbo.sysmail_allitems a inner join msdb.dbo.sysmail_profile p
on a.profile_id = p.profile_id
where mailitem_id in (
select mailitem_id from @emails
)
order by send_request_date 

open send_bulk_emails
fetch next from send_bulk_emails into @db_mail_profile, @bformat, @subject, @email_body
while @@FETCH_STATUS = 0
begin

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
--@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = @bformat 

fetch next from send_bulk_emails into @db_mail_profile, @bformat, @subject, @email_body
end
close send_bulk_emails
deallocate send_bulk_emails



