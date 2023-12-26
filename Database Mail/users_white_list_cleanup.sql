use master
go
declare @dba_team table 
(id int identity(1,1), account_number varchar(100), username varchar(255), member_role varchar(100), email_address varchar(1000), is_allowed bit)
insert into @dba_team values
('ALBILAD\e008374','Fahad Alqarawi'	, 'DBA Manager','FSAlqarawi@bankAlbilad.com',	1),
('ALBILAD\e004199','Abdulmohsen'	, 'DBA', 'AI.BinAbdulwahed@Bankalbilad.com',	1),
('ALBILAD\c904153','Shaik Zubair'	, 'DBA', 'SZubairFareed@Bankalbilad.com',		1),
('ALBILAD\c904529','Mohammed Fawzy'	, 'DBA', 'MFawzyAlHaleem@Bankalbilad.com',		1),
('ALBILAD\e010053','Saud Al Ballaa'	, 'DBA', 'SAbdullahAlBallaa@Bankalbilad.com',	1),
('ALBILAD\e010059','Rahaf'			, 'DBA', 'ROmarALTirbaq@Bankalbilad.com',		1),
('ALBILAD\e010312','Nawaf Alhajri'	, 'DBA', 'NAyedAlhajri@Bankalbilad.com',		1)

--select * from white_list_users

if OBJECT_ID('master.dbo.white_list_users') is null
begin

create table master.[dbo].[white_list_users](
[id]				[int] identity(1,1),
[account_number]	[varchar](100),
[username]			[varchar](100),
[team]				[varchar](100),
[is_allowed]		[bit],
[email]				[varchar](300),
[send_notification] [bit]
)

insert into master.[dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification)
select account_number, username, member_role, is_allowed, email_address, case when member_role = 'DBA Manager' then 0 else 1 end
from @dba_team
where is_allowed = 1

end
else
begin

delete from master.[dbo].[white_list_users]
where account_number in (
						select account_number
						from master.[dbo].[white_list_users]
						where team in ('DBA','DBA Manager')
						except
						select account_number
						from @dba_team
						where is_allowed = 1)

insert into master.[dbo].[white_list_users] (account_number, username, team, is_allowed, email, send_notification)
select account_number, username, member_role, is_allowed, email_address, case when member_role = 'DBA Manager' then 0 else 1 end
from @dba_team
where account_number in (
					select account_number
					from @dba_team
					where is_allowed = 1
					except
					select account_number
					from master.[dbo].[white_list_users]
					where is_allowed = 1
					)
end

select * from white_list_users
