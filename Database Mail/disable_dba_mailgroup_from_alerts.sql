declare 
@email_group	varchar(100),
@max_dba		int,
@operator_name	varchar(255),
@operator_id	int,
@loop			int = 0,
@enable			int

declare @sysoperators table (operator_id int, email_addresses varchar(100))
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
select @loop + 1, @email_group

set @loop += 1
end

declare operators cursor fast_forward
for
select op1.operator_id, op2.name, op1.email_addresses, case when op1.email_addresses is null then 0 else 1 end
from @sysoperators op1 left outer join msdb.dbo.sysoperators op2
on op2.name = 'DBAs_g'+CAST(op1.operator_id as varchar(10))
where op1.email_addresses is not null
union 
select 0, name, NULL, 0
from msdb.dbo.sysoperators op2
where name like 'DBAs_g%'
and name not in (select op2.name
from @sysoperators op1 inner join msdb.dbo.sysoperators op2
on op2.name = 'DBAs_g'+CAST(op1.operator_id as varchar(10))
where op1.email_addresses is not null)

open operators
fetch next from operators into @operator_id, @operator_name, @email_group, @enable
while @@FETCH_STATUS = 0
begin

if @operator_name is not null 
begin
	if @enable = 1
	begin
		exec msdb.dbo.sp_update_operator 
		@name = @operator_name, 
		@enabled = 1, 
		@pager_days = 0, 
		@email_address = @email_group, 
		@pager_address = N''
	end
	else
	begin
		exec msdb.dbo.sp_update_operator 
		@name = @operator_name, 
		@enabled = 0
	end
end
else
begin
		set @operator_name = 'DBAs_g'+cast(@operator_id as varchar(10))
		exec msdb.dbo.sp_add_operator 
		@name = @operator_name, 
		@enabled = 1, 
		@pager_days = 0, 
		@email_address = @email_group
end
fetch next from operators into @operator_id, @operator_name, @email_group, @enable
end
close operators 
deallocate operators 

select * 
from msdb.dbo.sysoperators

go

/*
select al.name, op.name,
case 
when replace(op.email_address,';','') = 'mailgroup_dba@bankalbilad.com' then 'dba_mailgroup' 
when replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' and email_address like '%mailgroup_dba@bankalbilad.com%' then 'dba_mailgroup_and_others'
when email_address = 'ai.binabdulwahed@bankalbilad.com;analhumud@bankalbilad.com;szubairfareed@bankalbilad.com' then 'dba_member' 
when op.name like 'DBAs_g%' then 'DBAs' 
end alert_type
from msdb.dbo.sysoperators op inner join msdb.dbo.sysnotifications n
on op.id = n.operator_id
inner join msdb.dbo.sysalerts al
on al.id = n.alert_id
where case 
when replace(op.email_address,';','') = 'mailgroup_dba@bankalbilad.com' then 'dba_mailgroup' 
when replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' and email_address like '%mailgroup_dba@bankalbilad.com%' then 'dba_mailgroup_and_others'
when email_address = 'ai.binabdulwahed@bankalbilad.com;analhumud@bankalbilad.com;szubairfareed@bankalbilad.com' then 'dba_member' 
when op.name like 'DBAs_g%' then 'DBAs' 
end  in ('dba_mailgroup','dba_mailgroup_and_others','dba_member')
order by al.name, op.name
*/

declare 
@alert			varchar(255), 
@old_operator	varchar(255), 
@dba_operator	varchar(255), 
@alert_type		varchar(255)

declare dba_operators cursor fast_forward
for
select name
from msdb.dbo.sysoperators
where name like 'DBAs_g%'
and enabled = 1

declare update_notification cursor fast_forward
for
select al.name, op.name,
case 
when replace(op.email_address,';','') = 'mailgroup_dba@bankalbilad.com' then 'dba_mailgroup' 
when replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' and email_address like '%mailgroup_dba@bankalbilad.com%' then 'dba_mailgroup_and_others'
when email_address = 'ai.binabdulwahed@bankalbilad.com;analhumud@bankalbilad.com;szubairfareed@bankalbilad.com' then 'dba_member' 
when op.name like 'DBAs_g%' then 'DBAs' 
end alert_type
from msdb.dbo.sysoperators op inner join msdb.dbo.sysnotifications n
on op.id = n.operator_id
inner join msdb.dbo.sysalerts al
on al.id = n.alert_id
where case 
when replace(op.email_address,';','') = 'mailgroup_dba@bankalbilad.com' then 'dba_mailgroup' 
when replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' and email_address like '%mailgroup_dba@bankalbilad.com%' then 'dba_mailgroup_and_others'
when email_address = 'ai.binabdulwahed@bankalbilad.com;analhumud@bankalbilad.com;szubairfareed@bankalbilad.com' then 'dba_member' 
when op.name like 'DBAs_g%' then 'DBAs' 
end  in ('dba_mailgroup','dba_mailgroup_and_others','dba_member')
order by al.name, op.name

open update_notification
fetch next from update_notification into @alert, @old_operator, @alert_type
while @@FETCH_STATUS = 0
begin

if @alert_type in ('dba_member','dba_mailgroup')
begin
	exec msdb.dbo.sp_delete_notification @alert_name = @alert, @operator_name = @old_operator
end

open dba_operators
fetch next from dba_operators into @dba_operator
while @@FETCH_STATUS = 0
begin
	exec msdb.dbo.sp_add_notification 
	@alert_name = @alert, 
	@operator_name = @dba_operator, 
	@notification_method = 1
fetch next from dba_operators into @dba_operator
end
close dba_operators 

fetch next from update_notification into @alert, @old_operator, @alert_type
end
close update_notification
deallocate update_notification
deallocate dba_operators

/*
select * 
from msdb.dbo.sysoperators

select al.name, op.name,email_address,
case 
when replace(op.email_address,';','') = 'mailgroup_dba@bankalbilad.com' then 'dba_mailgroup' 
when replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' and email_address like '%mailgroup_dba@bankalbilad.com%' then 'dba_mailgroup_and_others'
when email_address = 'ai.binabdulwahed@bankalbilad.com;analhumud@bankalbilad.com;szubairfareed@bankalbilad.com' then 'dba_member' 
when op.name like 'DBAs_g%' then 'DBAs' 
end alert_type
from msdb.dbo.sysoperators op inner join msdb.dbo.sysnotifications n
on op.id = n.operator_id
inner join msdb.dbo.sysalerts al
on al.id = n.alert_id
order by al.name, op.name
*/
go

--operators that have mailgroup_dba@bankalbilad.com and others
declare @operator_name varchar(255), @email_address varchar(200)
declare dba_operator cursor fast_forward
for
select name, isnull([1],'')+isnull(';'+[2],'')+isnull(';'+[3],'')+isnull(';'+[4],'')+isnull(';'+[5],'')
from (
select row_number() over(partition by name order by name) id, name, s.value email_address
from msdb.dbo.sysoperators
cross apply master.dbo.Separator(email_address,';') s
where replace(email_address,';','') != 'mailgroup_dba@bankalbilad.com' 
and email_address like '%mailgroup_dba@bankalbilad.com%'
and s.value != 'mailgroup_dba@bankalbilad.com')a
pivot (
max(email_address) for id in ([1],[2],[3],[4],[5]))p

open dba_operator
fetch next from dba_operator into @operator_name, @email_address
while @@FETCH_STATUS = 0
begin

exec msdb.dbo.sp_update_operator 
@name = @operator_name, 
@enabled = 1, 
@pager_days = 0, 
@email_address = @email_address, 
@pager_address = N''

fetch next from dba_operator into @operator_name, @email_address
end
close dba_operator
deallocate dba_operator

GO
--only operators with mailgroup_dba@bankalbilad.com
declare @operator_name varchar(255), @email_address varchar(200)
declare dba_operator cursor fast_forward
for
select name
from msdb.dbo.sysoperators
where replace(email_address,';','') = 'mailgroup_dba@bankalbilad.com' 
or (name like 'DBAs_g%' and enabled = 0)

open dba_operator
fetch next from dba_operator into @operator_name
while @@FETCH_STATUS = 0
begin

if @operator_name like 'DBAs_g%'
begin
EXEC msdb.dbo.sp_delete_operator @name = @operator_name
end
else
begin
EXEC msdb.dbo.sp_update_operator @name = @operator_name, @enabled = 0
end
fetch next from dba_operator into @operator_name
end
close dba_operator
deallocate dba_operator

/*
select al.name, al.enabled, op.name, op.enabled, op.email_address
from msdb.dbo.sysoperators op inner join msdb.dbo.sysnotifications n
on op.id = n.operator_id
inner join msdb.dbo.sysalerts al
on al.id = n.alert_id
order by al.name, op.name
*/
