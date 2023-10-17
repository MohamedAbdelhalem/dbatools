use T24SDC10
go
declare @P_restore_loction_groups varchar(2000)
select @P_restore_loction_groups = 
isnull(@P_restore_loction_groups+';','') + name
from (
select 
distinct cast(data_space_id as varchar)+'-'+reverse(substring(reverse(physical_name),charindex('\',reverse(physical_name)),len(physical_name))) name
from sys.master_files
where database_id = db_id())a
order by name

create table master.dbo.restore_loction_groups (directorys_map varchar(2000))
insert into master.dbo.restore_loction_groups values (@P_restore_loction_groups)

select * from master.dbo.restore_loction_groups
