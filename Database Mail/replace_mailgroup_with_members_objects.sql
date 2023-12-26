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

declare 
@mail_group		varchar(max),
@email_group	varchar(100),
@max_dba		int,
@operator_name	varchar(255),
@operator_id	int,
@loop			int = 0,
@enable			int
declare @sysoperators table (operator_id int, email_addresses varchar(100))
select @max_dba = MIN(id) - 1, @email_group = '' 
from @dba_team
where member_role = 'DBA'
and is_allowed = 1

while @email_group is not null
begin
set @email_group = null

select @max_dba = MAX(id) over(), @email_group = isnull(@email_group+';','') + email_address
from (
select id, email_address, 
case when sum(LEN(email_address)) over(partition by master.dbo.gBulk(id,id) order by id) > 96 then 0 else 1 end flag
from (
select id, email_address
from @dba_team
where member_role = 'DBA'
and is_allowed = 1
and id > @max_dba
)a)b
where flag = 1

insert into @sysoperators
select operator_id, email_addresses
from (
select @loop + 1 operator_id, @email_group email_addresses)a
where email_addresses is not null

set @loop += 1
end

select @mail_group = isnull(@mail_group+';','') + email_addresses
from @sysoperators
select @mail_group
select * from @sysoperators

--declare @objects table (database_name varchar(300), object_name varchar(1000), type_desc varchar(255), value nvarchar(max))
--insert into @objects
--exec sp_MSforeachdb 'use ?
--select ''?'' database_name, o.name object_name, o.type_desc, s.value
--from sys.sql_modules sq inner join sys.objects o
--on sq.object_id = o.object_id
--cross apply master.dbo.Separator(sq.definition, CHAR(10))s
--where s.value like ''%mailgroup_dba@bankalbilad.com%''
--order by o.name, s.id' 

select s.value 
from master.dbo.Separator('declare @mailgroup_dba varchar(max)
select @mailgroup_dba = isnull(@mailgroup_dba+'';'','''') + email
from master.[dbo].[white_list_users]
where is_allowed = 1
and send_notification = 1
',CHAR(10))s
order by s.id


select DB_NAME(db_id()) database_name, o.name object_name, o.type_desc, s.value
from sys.sql_modules sq inner join sys.objects o
on sq.object_id = o.object_id
cross apply master.dbo.Separator(sq.definition, CHAR(10))s
where s.value like '%mailgroup_dba@bankalbilad.com%'
and o.type_desc ='SQL_STORED_PROCEDURE'
order by o.name, s.id 



