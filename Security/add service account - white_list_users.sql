declare @username varchar(200) = 'ALBILAD\SVC_SCCMB01'
insert into white_list_users (account_number, username,team, is_allowed, send_notification) values
(@username,@username,'Service Account',1,0)

select * from white_list_users
update white_list_users set is_allowed = 0 where id in(12, 13)

--update white_list_users set is_allowed = 0 where id in (11)
--update white_list_users set send_notification = 0 where id in (5
--,6
--,7
--,8
--,9)


--T24 Team
declare @team_members varchar(max) = 'Vignesh Singaravelu Singaravelu <VSingaraveluSingaravelu@Bankalbilad.com>'
insert into master.[dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification)
select master.dbo.team_detail([value],'name')[account_number], master.dbo.team_detail([value],'name')[username],'T24 Team'[team], 1[is_allowed], master.dbo.team_detail([value],'email') [email],0[send_notification]
from master.dbo.separator(@team_members,';') s

--Select *
--from (
--select master.dbo.team_detail([value],name)[account_number], master.dbo.team_detail([value],name)[username],T24 Team[team], 1[is_allowed], master.dbo.team_detail([value],email) [email],0[send_notification]
--from master.dbo.separator(@team_members,;) s
--except
--select [account_number], [username], [team], [is_allowed], [email], [send_notification]
--from master.dbo.white_list_users)a
--where email not in (select email from white_list_users)

SET IMPLICIT_TRANSACTIONS ON
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e008374','Fahad Suliman Alqarawi','DBA Manager',1,'FSAlqarawi@bankAlbilad.com',0);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e004199','Abdulmohsen Ibrahim Bin Abdulwahed','DBA',1,'AI.BinAbdulwahed@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\c904153','Shaik Zubair Fareed','DBA',1,'SZubairFareed@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\c904529','Mohammed Fawzy AlHaleem','DBA',1,'MFawzyAlHaleem@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010043','Nawaf Abdulrahman Bukhari','DBA',1,'NAbdulrahmanBukhari@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010052','Hamad Fahad Al Rubayq','DBA',1,'HFahadAlRubayq@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010057','Odai Abdulaziz Alageel','DBA',1,'oabdulazizalageel@bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010053','Saud Abdullah Al Ballaa','DBA',1,'SAbdullahAlBallaa@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010059','Rahaf Omar AL Tirbaq','DBA',1,'ROmarALTirbaq@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('ALBILAD\e010312','Nawaf Ayed Alhajri','DBA',1,'NAyedAlhajri@Bankalbilad.com',1);
insert into [dbo].[white_list_users] ([account_number],[username],[team],[is_allowed],[email],[send_notification]) values ('BANKSA','System Admin','System Admin',1,NULL,0);
COMMIT;
SET IMPLICIT_TRANSACTIONS OFF

go
--add user into the white list users
declare @team_members varchar(max) = 'Amanulla Mohamed Yusuf <AMyusuf@bankAlbilad.com>'
insert into [dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification)
select master.dbo.team_detail([value],'name'),master.dbo.team_detail([value],'name'),'T24 Team', 1, master.dbo.team_detail([value],'email'),0
from master.dbo.separator(@team_members,';') s
