Create Table [dbo].[sessions] (   
[spid] [smallint] not null,   
[database_name] [nvarchar](256) null,   
[text] [nvarchar](max) null,   
[waittime] [bigint] not null,   
[lastwaittype] [nchar](64) not null,   
[blocked] [smallint] not null,   
[status] [nchar](60) not null,   
[cmd] [nchar](32) not null,   
[flag_status] [int] not null);
go

select * from sessions order by flag_status


SET IMPLICIT_TRANSACTIONS ON
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (51,N'HPUCMDB',N'(@P1 bigint,@P2 varchar(8000),@P3 int)update SEQUENCES set SEQUENCE_VALUE=@P1  where SEQUENCE_KEY=@P2  and SEQUENCE_CUSTOMER_ID=@P3 ',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (52,N'HPUCMDB',N'(@P1 int)select IS_ACTIVE from CUSTOMER_REGISTRATION where ID=@P1 ',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (53,N'HPUCMDB',N'(@P1 int)select IS_ACTIVE from CUSTOMER_REGISTRATION where ID=@P1 ',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (54,N'HPUCMDB',N'(@P1 varchar(8000),@P2 bigint,@P3 varchar(8000),@P4 varchar(8000))UPDATE HA_WRITER SET SERVER_ID=@P1 ,TIMESTAMP=@P2 ,SUGGESTED_SERVER_ID=@P3 ,SUGGESTION_TIMESTAMP=@P4 ',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (55,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (56,N'msdb',N'(@P1 int,@P2 uniqueidentifier,@P3 int)UPDATE msdb.dbo.sysjobactivity SET run_requested_date = DATEADD(ms, -DATEPART(ms, GetDate()),  GetDate()), run_requested_source = CONVERT(sysname, @P1), queued_date = NULL, start_execution_date = NULL, last_executed_step_id = NULL, last_executed_step_date = NULL, stop_execution_date = NULL, job_history_id = NULL, next_scheduled_run_date = NULL WHERE job_id = @P2 and session_id = @P3',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (57,N'am',N'set transaction isolation level read uncommitted',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (58,N'am',N'set transaction isolation level read uncommitted',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (59,N'am',N'(@P1 int)SELECT TOP 1 O1.memOptValue FROM amOption O1 WHERE O1.lOptId = @P1',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (60,N'HPUCMDB',N'(@P1 varchar(8000),@P2 bigint,@P3 varchar(8000),@P4 varchar(8000))UPDATE HA_WRITER SET SERVER_ID=@P1 ,TIMESTAMP=@P2 ,SUGGESTED_SERVER_ID=@P3 ,SUGGESTION_TIMESTAMP=@P4 ',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (61,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (62,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (63,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (64,N'msdb',N'SELECT ISNULL(SUSER_SNAME(), SUSER_NAME())',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (66,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (67,N'HPSM',N'IF @@TRANCOUNT > 0 ROLLBACK TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (68,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (69,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (70,N'HPSM',N'(@P1 varchar(7),@P2 varchar(9))SELECT m1."ID",m1."ID" FROM ASSIGNMENTLOGM1 m1 WHERE ((m1."FOREIGN_KEY"=@P1 and m1."FOREIGN_FILENAME"=@P2) AND ((m1."ID">25601183) OR ((m1."ID"=25601183) AND (m1."ID">25601183)))) ORDER BY m1."ID" ASC',43,N'CXPACKET                        ',0,N'suspended                     ',N'SELECT          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (71,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',3907,N'LCK_M_U                         ',92,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (72,N'HPSM',N'(@P1 varchar(9),@P2 varchar(7))SELECT * FROM SLAACTIVEM1 SERIALIZABLE WHERE "FOREIGN_FILENAME"=@P1 AND "FOREIGN_KEY"=@P2',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (73,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (74,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (75,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (76,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (77,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (78,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (79,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (80,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (81,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (82,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',390,N'LCK_M_S                         ',92,N'suspended                     ',N'SELECT          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (83,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (84,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (85,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (86,N'am',N'(@P1 nvarchar(4000))SELECT TOP 1 E1.lEmplDeptId, E1.lWorkCalendarId, E1.seLoginStatus, E1.bResetPwd, E1.bFixedPwd, E1.dPwdExpiration, E1.LoginFailures, E1.dtLogonFailure, E1.dStartValidity, E1.dEndValidity, E1.bNeverExpirePwd FROM (amEmplDept E1 LEFT OUTER JOIN amRelEmplMProf R2 ON (E1.lEmplDeptId = R2.lEmplDeptId) AND (E1.lDefMProfileId = R2.lMProfileId)) WHERE  E1.UserLogin = @P1',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (87,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',2826,N'LCK_M_U                         ',71,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (88,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (89,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (90,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',1314,N'LCK_M_U                         ',71,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (91,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',212,N'LCK_M_U                         ',71,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (92,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',1299,N'LCK_M_U                         ',91,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (94,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (95,N'am',N'CREATE PROCEDURE up_GetCounterVal @CounterName varchar(64), @CounterIncrement int AS BEGIN DECLARE @CounterIdent int DECLARE amCounterLock CURSOR FOR SELECT lCounterId FROM amCounter WHERE Identifier = @CounterName FOR UPDATE SELECT @CounterIdent = MAX(lCounterId) FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NULL  INSERT INTO amCounter (lCounterId, Identifier, Description, lValue, dtLastModif) SELECT MAX(lCounterId) + 1, @CounterName, @CounterName, @CounterIncrement, GetDate() FROM amCounter ELSE BEGIN OPEN amCounterLock UPDATE amCounter SET lValue = lValue + @CounterIncrement, dtLastModif = GetDate() WHERE lCounterId = @CounterIdent END SELECT lValue FROM amCounter WHERE Identifier = @CounterName IF @CounterIdent IS NOT NULL CLOSE amCounterLock DEALLOCATE amCounterLock END ',1314,N'LCK_M_U                         ',71,N'suspended                     ',N'UPDATE          ',0);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (96,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (97,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
insert into [dbo].[sessions] ([spid],[database_name],[text],[waittime],[lastwaittype],[blocked],[status],[cmd],[flag_status])     values (98,N'HPSM',N'IF @@TRANCOUNT > 0 COMMIT TRAN',0,N'MISCELLANEOUS                   ',0,N'sleeping                      ',N'AWAITING COMMAND',5);
COMMIT;