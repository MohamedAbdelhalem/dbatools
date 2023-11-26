
declare @emails table (mailitem_id bigint)
declare
@db_mail_profile			  varchar(100),
@subject					      varchar(1000),
@to_whom_to_send_emails	varchar(max) = 'mabdelhalem@domain.com, fawzyismail@domain.com, mfabdelhalem@domain.com', --e.g. Put here the emails you want to send 
@ccemail					      varchar(1000),
@bformat					      varchar(100),
@email_body					    varchar(max),
@send_request_date			datetime,
@rec_emails					    varchar(max)

insert into @emails
select top 5 mailitem_id  --here is the email id with the top 5, change it with what you want.
from msdb.dbo.sysmail_allitems
where send_request_date between '2023-11-10 00:00:00' and '2023-11-11 23:59:59' -- time of the email that it was sent
and subject = 'Performance monitor - top 20 queries' --e.g. Any email subject you had configured and to send it from the database like to send you the top 20 queries that consume the CPU or I/O. 

select @rec_emails = isnull(@rec_emails+';','')+ ltrim(rtrim(value))
from master.dbo.Separator(@to_whom_to_send_emails, ',')

--to display the history emails

--select p.name profile_name, body_format, subject, 
--'<p><i>This is a copy of the below E-mail, and the original receiving time for it was on <b style="color:red;">'+convert(varchar(10),send_request_date,120)+
--'</b> at <b style="color:red;">'+convert(varchar(30),send_request_date,108)+'</b></i>.</p>'+
--body 
--from msdb.dbo.sysmail_allitems a inner join msdb.dbo.sysmail_profile p
--on a.profile_id = p.profile_id
--where mailitem_id in (
--select mailitem_id from @emails)
--order by send_request_date 

declare send_bulk_emails cursor fast_forward
for
select p.name profile_name, body_format, subject, 
'<p><i>This is a copy of the below E-mail, and the original receiving time for it was on <b style="color:red;">'+convert(varchar(10),send_request_date,120)+
'</b> at <b style="color:red;">'+convert(varchar(30),send_request_date,108)+'</b></i>.</p>'+
body 
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
@recipients = @rec_emails, 
@subject = @subject, 
@body = @email_body, 
@body_format = @bformat 

fetch next from send_bulk_emails into @db_mail_profile, @bformat, @subject, @email_body
end
close send_bulk_emails
deallocate send_bulk_emails





