create table test_compute (id int, name varchar(100), salary int, comm int)
insert into test_compute values (1, 'mohamed', 1234, 10)
alter table test_compute add total_salary as salary * comm + salary persisted
alter table test_compute drop column total_salary 
select * from test_compute
update test_compute set comm = 44
select allocated_page_file_id, allocated_page_page_id, page_type_desc from sys.dm_db_database_page_allocations(db_id(), object_id('test_compute'), null,null,'detailed')
where page_type_desc = 'data_page'

dbcc traceon (3604,-1)
dbcc page(0,1,380,3)
