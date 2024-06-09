--THIS FEATURE IS ONLY ALLOWED ON ENTERPRISE EDITION for updatable distributed partitioned view
--#############################################################################################

create table employee_2018 (id int, name varchar(100), date_time datetime check (date_time between '2018-01-01' and '2018-12-31 23:59:59.997'))
create table employee_2019 (id int, name varchar(100), date_time datetime check (date_time between '2019-01-01' and '2019-12-31 23:59:59.997'))
create table employee_2020 (id int, name varchar(100), date_time datetime check (date_time between '2020-01-01' and '2020-12-31 23:59:59.997'))
create table employee_2021 (id int, name varchar(100), date_time datetime check (date_time between '2021-01-01' and '2021-12-31 23:59:59.997'))
create table employee_2022 (id int, name varchar(100), date_time datetime check (date_time between '2022-01-01' and '2022-12-31 23:59:59.997'))
create table employee_2023 (id int, name varchar(100), date_time datetime check (date_time between '2023-01-01' and '2023-12-31 23:59:59.997'))
create table employee_2024 (id int, name varchar(100), date_time datetime check (date_time between '2024-01-01' and '2024-12-31 23:59:59.997'))

GO
create View [dbo].[Employees] 
with schemabinding
as
select id, name, date_time from [dbo].[employee_2018]
union all
select id, name, date_time from [dbo].[employee_2019]
union all
select id, name, date_time from [dbo].[employee_2020]
union all
select id, name, date_time from [dbo].[employee_2021]
union all
select id, name, date_time from [dbo].[employee_2022]
union all
select id, name, date_time from [dbo].[employee_2023]
union all
select id, name, date_time from [dbo].[employee_2024]

go
insert into [dbo].[Employees] values (1, 'mohamed fawzy', '2018-12-23 08:55:09')
--Msg 4440, Level 16, State 9, Line 29
--UNION ALL view 'master.dbo.Employees' is not updatable because a primary key was not found on table '[master].[dbo].[employee_2018]'.

drop view  employees
drop table employee_2018
drop table employee_2019
drop table employee_2020
drop table employee_2021
drop table employee_2022
drop table employee_2023
drop table employee_2024

create table employee_2018 (id int primary key, name varchar(100), date_time datetime check (date_time between '2018-01-01' and '2018-12-31 23:59:59.997'))
create table employee_2019 (id int primary key, name varchar(100), date_time datetime check (date_time between '2019-01-01' and '2019-12-31 23:59:59.997'))
create table employee_2020 (id int primary key, name varchar(100), date_time datetime check (date_time between '2020-01-01' and '2020-12-31 23:59:59.997'))
create table employee_2021 (id int primary key, name varchar(100), date_time datetime check (date_time between '2021-01-01' and '2021-12-31 23:59:59.997'))
create table employee_2022 (id int primary key, name varchar(100), date_time datetime check (date_time between '2022-01-01' and '2022-12-31 23:59:59.997'))
create table employee_2023 (id int primary key, name varchar(100), date_time datetime check (date_time between '2023-01-01' and '2023-12-31 23:59:59.997'))
create table employee_2024 (id int primary key, name varchar(100), date_time datetime check (date_time between '2024-01-01' and '2024-12-31 23:59:59.997'))

insert into [dbo].[Employees] values (1, 'mohamed fawzy', '2018-12-23 08:55:09')
--Msg 4436, Level 16, State 12, Line 28
--UNION ALL view 'master.dbo.Employees' is not updatable because a partitioning column was not found.

drop view  employees
drop table employee_2018
drop table employee_2019
drop table employee_2020
drop table employee_2021
drop table employee_2022
drop table employee_2023
drop table employee_2024

create table employee_2018 (id int, name varchar(100), date_time datetime check (date_time between '2018-01-01' and '2018-12-31 23:59:59.997'), constraint pk_id_2018 primary key (id, date_time))
create table employee_2019 (id int, name varchar(100), date_time datetime check (date_time between '2019-01-01' and '2019-12-31 23:59:59.997'), constraint pk_id_2019 primary key (id, date_time))
create table employee_2020 (id int, name varchar(100), date_time datetime check (date_time between '2020-01-01' and '2020-12-31 23:59:59.997'), constraint pk_id_2020 primary key (id, date_time))
create table employee_2021 (id int, name varchar(100), date_time datetime check (date_time between '2021-01-01' and '2021-12-31 23:59:59.997'), constraint pk_id_2021 primary key (id, date_time))
create table employee_2022 (id int, name varchar(100), date_time datetime check (date_time between '2022-01-01' and '2022-12-31 23:59:59.997'), constraint pk_id_2022 primary key (id, date_time))
create table employee_2023 (id int, name varchar(100), date_time datetime check (date_time between '2023-01-01' and '2023-12-31 23:59:59.997'), constraint pk_id_2023 primary key (id, date_time))
create table employee_2024 (id int, name varchar(100), date_time datetime check (date_time between '2024-01-01' and '2024-12-31 23:59:59.997'), constraint pk_id_2024 primary key (id, date_time))

insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2018-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2019-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2020-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2021-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2022-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2023-12-23 08:55:09')
insert into [dbo].[Employees] values (10, 'mohamed fawzy', '2023-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2024-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2025-12-23 08:55:09')
insert into [dbo].[Employees] values (1,  'mohamed fawzy', '2017-12-23 08:55:09')

exec sp_table_size '','employee_2018,employee_2019,employee_2020,employee_2021,employee_2022,employee_2023,employee_2024','name'
