use msdb
go
select job_name, step_id, step_name, 
command, subsystem, package, package_name
from (
select job_name, step_id, step_name, command, subsystem, package, case when charindex('\',package) > 0 then reverse(substring(reverse(package),1,charindex('\',reverse(package))-1)) else '' end package_name
from (
select j.name job_name, step_id, step_name, command, subsystem, 
substring(master.[dbo].[virtical_array](command,' ',2),5,len(master.[dbo].[virtical_array](command,' ',2))-7) package
from msdb.dbo.sysjobs j inner join msdb.dbo.sysjobsteps js
on j.job_id = js.job_id
where subsystem = 'ssis')a)b
--where package_name like '%Delegations%'
--where package_name in (
--'IALMasterPackage',
--'MV-Corporate-GrossIncome',
--'MV-Corporate-ExtRiskRating',
--'MV-Corporate-AdditionalRevenue',
--'Collection',
--'JointAccount',
--'DebitCards')

--Following SSIS package is failed. Kindly assist BAB DBA team to address the issue. 

--1.	CRM_SSIS_IALMasterPackage. Step= IALMasterPackage
--2.	CRM_SSIS_Corporate. Step= MV-Corporate-GrossIncome
--3.	CRM_SSIS_Corporate. Step= MV-Corporate-ExtRiskRating
--4.	CRM_SSIS_Corporate. Step= MV-Corporate-AdditionalRevenue
--5.	CRM_SSIS_360. Step= Collection success
--6.	CRM_SSIS_Corporate. Step= JointAccount
--7.	CRM_SSIS_360. Step= DebitCards failed
