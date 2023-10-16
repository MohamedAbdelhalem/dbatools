create table white_list_users 
(id int identity(1,1), account_number varchar(100), username varchar(100), team varchar(100), is_allowed bit, email varchar(300), send_notification bit)
insert into white_list_users (account_number, username, team, is_allowed, email, send_notification) values 
('ALBILAD\e008374', 'Fahad Suliman Alqarawi', 'DBA Manager', 1,'FSAlqarawi@bankAlbilad.com',0),
('ALBILAD\e004199', 'Abdulmohsen Ibrahim Bin Abdulwahed', 'DBA', 1,'AI.BinAbdulwahed@Bankalbilad.com',1),
('ALBILAD\c904153', 'Shaik Zubair Fareed', 'DBA', 1, 'SZubairFareed@Bankalbilad.com',1),
('ALBILAD\c904529', 'Mohammed Fawzy AlHaleem', 'DBA', 1, 'MFawzyAlHaleem@Bankalbilad.com',1),
('ALBILAD\e010043', 'Nawaf Abdulrahman Bukhari', 'DBA', 1,'NAbdulrahmanBukhari@Bankalbilad.com',1),
('ALBILAD\e010052', 'Hamad Fahad Al Rubayq', 'DBA', 1,'HFahadAlRubayq@Bankalbilad.com',1),
('Najib Anwer', 'Najib Anwer Anwarul Haque', 'T24 Team', 1,'NAnwerAnwarulHaque@Bankalbilad.com',0),
('BANKSA', 'System Admin', 'System Admin', 1, NULL, 0)

select * from white_list_users 


insert into white_list_users (account_number, username, team, is_allowed, email, send_notification) values 
('ETL_PRD', 'APP user', 'ETL', 1, NULL, 0),
('ALBILAD\SVC_WFM_DB', 'Service Account', 'Service Account', 1, NULL, 0),
('ALBILAD\SVC_WFM_PROD', 'Service Account', 'Service Account', 1, NULL, 0)

declare @email_notifications varchar(2000)
select @email_notifications = isnull(@email_notifications+';','')+ email
from white_list_users
where send_notification = 1

select @email_notifications 

IF @LoginName NOT IN (select account_number from white_list_users where is_allowed = 1)

