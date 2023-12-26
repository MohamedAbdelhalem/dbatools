select id operator_id, case when email_address = 'mailgroup_dba@bankalbilad.com' then 1 else 0 end replace_all, email_address 
from msdb.dbo.sysoperators
where email_address like '%mailgroup_dba@bankalbilad.com%'
order by id

select a.name, o.name operator_name,o.email_address, op.*, n.*
from msdb.dbo.sysalerts a left outer join msdb.dbo.sysnotifications n
on a.id = n.alert_id
left outer join 
(
select id operator_id, case when email_address = 'mailgroup_dba@bankalbilad.com' then 1 else 0 end replace_all, email_address 
from msdb.dbo.sysoperators
where email_address like '%mailgroup_dba@bankalbilad.com%') op
on op.operator_id = n.operator_id
inner join msdb.dbo.sysoperators o
on n.operator_id = o.id
where op.operator_id is not null
order by a.name

select * from msdb.dbo.sysalerts

select * from msdb.dbo.sysnotifications
where alert_id = 77

declare @opg1 varchar(100)
declare @opg2 varchar(100)
declare @dba_team table 
(username varchar(255), member_role varchar(100), email_address varchar(1000), operator_gid int, is_allowed bit)
insert into @dba_team values
('Fahad Alqarawi', 'Manager', 'FSAlqarawi@bankAlbilad.com',		0,	0),
('Abdulmohsen'	 , 'DBA', 'AI.BinAbdulwahed@Bankalbilad.com',	1,	1),
('Shaik Zubair'	 , 'DBA', 'SZubairFareed@Bankalbilad.com',		1,	1),
('Mohammed Fawzy', 'DBA', 'MFawzyAlHaleem@Bankalbilad.com',		1,	1),
('Saud Al Ballaa', 'DBA', 'SAbdullahAlBallaa@Bankalbilad.com',	2,	1),
('Rahaf'		 , 'DBA', 'ROmarALTirbaq@Bankalbilad.com',		2,	1),
('Nawaf Alhajri' , 'DBA', 'NAyedAlhajri@Bankalbilad.com',		2,	1)

select @opg1 = ISNULL(@opg1+';','')+ email_address
from @dba_team
where member_role = 'DBA'
and is_allowed = 1
and operator_gid = 1

select @opg2 = ISNULL(@opg2+';','')+ email_address
from @dba_team
where member_role = 'DBA'
and is_allowed = 1
and operator_gid = 2

select @opg1 mailgroup_dba_1
select @opg2 mailgroup_dba_2
select @opg1+';'+@opg2 mailgroup_dbas

if not exists (select * from msdb.dbo.sysoperators where name like 'dba_g%')
begin

exec msdb.dbo.sp_add_operator @name=N'dba_g1', 
@enabled = 1, 
@pager_days = 0, 
@email_address = @opg1

exec msdb.dbo.sp_add_operator @name=N'dba_g2', 
@enabled = 1, 
@pager_days = 0, 
@email_address = @opg2

end

go
--check job steps to print

select * from msdb.dbo.sysjobsteps
where command like '%mailgroup_dba@bankalbilad.com%'

go
