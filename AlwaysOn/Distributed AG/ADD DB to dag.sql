--add database to dag
--on PRIMARY take backup from the database [test] (full and log)
BACKUP DATABASE [test] 
TO  DISK = N'S:\Backup\test_after_dag.bak' WITH NOFORMAT, NOINIT,  
NAME = N'test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 1
GO

BACKUP log[test] 
TO  DISK = N'S:\Backup\test_after_dag.bak' WITH NOFORMAT, NOINIT,  
NAME = N'test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 50
GO

--then remove database if [test] database exist on the PRIMARY local ag on the SECONRARY site 
--then restore the backup files from PRIMARY local ag on the PRIMARY site with norecovery

--then restore them on the PRIMARY node on the SECONARY site
--and then run this command on PRIMARY local ag on the SECONDARY site to join [test] database into distributed availability groups
ALTER DATABASE [test] SET HADR AVAILABILITY GROUP = [DAG_Test]

--If you tried to join the database on PRIMARY you get the below error message

--Msg 35240, Level 16, State 13, Line 11
--Database 'test' cannot be joined to or unjoined from availability group 'AG_Test_01'. This operation is not supported on the primary replica of the availability group. 
