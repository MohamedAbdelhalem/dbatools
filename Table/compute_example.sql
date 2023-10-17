--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect 10.4.2.1,1433

ALTER AVAILABILITY GROUP [MENGNAG_2] FAILOVER;

GO


GO



select *from sys.availability_group_listener_ip_addresses

select * from sys.tcp_endpoints
select * from sys.endpoints


create table test_compute (recid int, name varchar(100), salary float, comm float)

insert into test_compute values 
(1,'mohamed',1500,10),
(2,'mohamed',2500,10),
(3,'mohamed',7580,10),
(4,'mohamed',8900,10),
(5,'mohamed',1000,10),
(6,'mohamed',1999,10)

update test_compute set name='Nawaf' where recid = 6

select * from test_compute
where final_salary > 10000

update test_compute set salary = 14587 where recid = 3

alter function dbo.fn_final_salary(@salary float, @comm float)
returns float
with schemabinding
as
begin
declare @result float
select @result = ((@salary * @comm) /100) + @salary
return @result
end
select dbo.fn_final_salary(14555,10)

alter table test_compute add final_salary as dbo.fn_final_salary(salary,comm) persisted
alter table test_compute drop column final_salary 
alter table test_compute alter column recid int not null
alter table test_compute add constraint pk_recid_compute primary key (recid)
create nonclustered index ind_final_salary on test_compute (final_salary)

select allocated_page_file_id, allocated_page_page_id, page_type_desc 
from sys.dm_db_database_page_allocations(db_id(), object_id('test_compute'),null,null,'detailed')
dbcc traceon (3604,-1)
dbcc page(0,1,569,3)

