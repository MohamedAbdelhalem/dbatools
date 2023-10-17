--set statistics Profile off
--set statistics IO on

select * from (
select top 1000
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid,
master.[dbo].[virtical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',3) slotid,
* 
from [dbo].[ScoreLogCharacteristic]
--from [T24PROD_UAT].[dbo].[FBNK_CUSTOMER]
--from [T24PROD_UAT].[dbo].FENJ_ACCOUNT
--from [msdb].[dbo].[autoadmin_task_agent_metadata]
--from FENJ_FUND200 
--from F_BAB_T_ATMFT_IN
--from [FBNK_FUNDS_TRANSFER#HIS]
where recid = '10000177'
order by RECID)a
--where pageid = 36816562 
--and fileid = 15


--dbcc traceon(3604)
--dbcc page(0,1,8242224,3)

--select avg(slots)
--from (
--select count(*) slots, fileid, pageid
--from (
--insert into master.dbo.ScoreLogCharacteristic_pages
--select 
--master.[dbo].[vertical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',1) fileid,
--master.[dbo].[vertical_array](replace(replace(sys.fn_PhysLocFormatter (%%physloc%%),')',''),'(',''),':',2) pageid

--from [dbo].[ScoreLogCharacteristic])a
--group by fileid, pageid)b
