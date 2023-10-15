select 
job_name, step_id, step_name, sql_message_id, sql_severity, 
master.dbo.numbersize(required_space,'byte') required_space, 
master.dbo.numbersize(substring(available_space, 1, charindex(' ', available_space)-1),'byte') available_space, 
master.dbo.numbersize(cast(required_space as bigint) - cast(substring(available_space, 1, charindex(' ', available_space)-1) as bigint),'byte') required_size_to_complete_restore, 
[message], run_status, run_date, run_time, run_duration
from (
select 
instance_id, job_name, step_id, step_name, sql_message_id, sql_severity, [message],
substring([error_message],1, charindex(' ', [error_message])-1) required_space, 
ltrim(substring([error_message], charindex('while only', [error_message])+len('while only'),len([error_message]))) available_space, 
run_status, run_date, run_time, run_duration
from (
select instance_id, job_name, step_id, step_name, sql_message_id, sql_severity, substring(message,1, charindex('.', message)-1) [error_message], substring(message,1, charindex('.', message)-1) [message], run_status, run_date, run_time, run_duration
from (
select instance_id, j.name job_name, step_id, step_name, sql_message_id, sql_severity, ltrim(substring(message,charindex('the database requires', message) + len('the database requires'), len(message))) [error_message],
ltrim(substring(message,charindex('the database requires', message) + len('the database requires'), len(message))) [message], run_status, run_date, run_time, run_duration
From msdb.dbo.sysjobs j  inner join msdb.dbo.sysjobhistory jh 
on j.job_id = jh.job_id 
where run_status = 0
and step_id > 0
and sql_message_id = 3621)a)b)c
where job_name = 'Automatic Restore Job'
order by instance_id desc

select instance_id, j.name job_name, step_id, step_name, sql_message_id, sql_severity, ltrim(substring(message,charindex('the database requires', message) + len('the database requires'), len(message))) [error_message],
ltrim(substring(message,charindex('the database requires', message) + len('the database requires'), len(message))) [message], run_status, run_date, run_time, run_duration, message
From msdb.dbo.sysjobs j  inner join msdb.dbo.sysjobhistory jh 
on j.job_id = jh.job_id 


declare 

Executed as user: ALBILAD\SVC_sqlagent. ...ate the database. The database requires 150994944000 additional free bytes, while only 146593284096 bytes are available. [SQLSTATE 42000] (Error 3257)  Problems were identified while planning for the RESTORE statement. Previous messages provide details. [SQLSTATE 42000] (Error 3119)  RESTORE DATABASE is terminating abnormally. [SQLSTATE 42000] (Error 3013)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\FULL\2022\October\" [SQLSTATE 01000] (Error 0)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\FULL\2022\October\" [SQLSTATE 01000] (Error 0)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\DIFF\2022\October\" [SQLSTATE 01000] (Error 0)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\DIFF\2022\October\" [SQLSTATE 01000] (Error 0)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\SDC_TO_PDC\DBs\LOGs\2022\October\" [SQLSTATE 01000] (Error 0)  dir cd "\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\LOGs\2022\October\" [SQLSTATE 01000] (Error 0)  RESTORE DATABASE [T24Prod]  FROM DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\DIFF\2022\October\D1T24DBSQPWV4_2022_T24Prod_DIFFBackup_20221024190001.bak'  WITH FILE = 1,  NORECOVERY,  NOUNLOAD, STATS = 5 [SQLSTATE 01000] (Error 0)  Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression. [SQLSTATE 21000] (Error 512)  The statement has been terminated. [SQLSTATE 01000] (Error 3621)  RESTORE LOG [T24Prod]  FROM DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\LOGs\2022\October\D1T24DBSQPWV4_2022_T24Prod_LogBackup_20221024194000.Trn'  WITH FILE = 1,  NORECOVERY,  NOUNLOAD, STATS = 5 [SQLSTATE 01000] (Message 0)  The log in this backup set begins at LSN 1903345000083031000001, which is too recent to apply to the database. An earlier log backup that includes LSN 1899241000084451600001 can be restored. [SQLSTATE 42000] (Error 4305)  RESTORE LOG is terminating abnormally. [SQLSTATE 42000] (Error 3013)  Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression. [SQLSTATE 21000] (Error 512)  The statement has been terminated. [SQLSTATE 01000] (Error 3621)  The log in this backup set begins at LSN 1903370000043244300001, which is too recent to apply to the database. An earlier log backup that includes LSN 1899241000084451600001 can be restored. [SQLSTATE 42000] (Error 4305)  RESTORE LOG is terminating abnormally. [SQLSTATE 42000] (Error 3013)  RESTORE LOG [T24Prod]  FROM DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\LOGs\2022\October\D1T24DBSQPWV4_2022_T24Prod_LogBackup_20221024195000.Trn'  WITH FILE = 1,  NORECOVERY,  NOUNLOAD, STATS = 5 [SQLSTATE 01000] (Error 0)  Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression. [SQLSTATE 21000] (Error 512)  The statement has been terminated. [SQLSTATE 01000] (Error 3621)  The log in this backup set begins at LSN 1903375000096306400001, which is too recent to apply to the database. An earlier log backup that includes LSN 1899241000084451600001 can be restored. [SQLSTATE 42000] (Error 4305)  RESTORE LOG is terminating abnormally. [SQLSTATE 42000] (Error 3013)  RESTORE LOG [T24Prod]  FROM DISK = N'\\npci2.d2fs.albilad.com\T24_BACKUP\PDC_TO_SDC\DBs\LOGs\2022\October\D1T24DBSQPWV4_2022_T24Prod_LogBackup_20221024200000.Trn'  WITH FILE = 1,  NORECOVERY,  NOUNLOAD, STATS = 5 [SQLSTATE 01000] (Error 0)  Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression. [SQLSTATE 21000] (Error 512)  The statement has been terminated. [SQLSTATE 01000] (Error 3621)  The log in this backup set begins at LSN 1903381000097559300001, which is too recent to ...  The step failed.