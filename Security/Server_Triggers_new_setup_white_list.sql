USE [master]
GO

declare 
@type varchar(30),
@name varchar(300),
@sql varchar(1000)

declare i cursor fast_forward
for
select 'trigger', '['+name+'] ON ALL SERVER'
from sys.server_triggers
where name in (
'Trg_TrackLoginManagement',
'TRG_SchemaChange_LogInTable_DDL',
'TRG_Pervent_Accounts_to_Login_to_SQL',
'DBA_PREVENT_SERVERLEVEL_DB_CHANGES')
union all
select 'table', '['+schema_name(schema_id)+'].['+name+']'
from sys.tables
where name = 'white_list_users'
open i
fetch next from i into @type, @name
while @@FETCH_STATUS = 0
begin
set @sql = 'DROP '+@type+' '+@name
exec(@sql)
print(@sql)
fetch next from i into @type, @name
end
close i
deallocate i
GO

go
create table white_list_users 
(id int identity(1,1), account_number varchar(100), username varchar(100), team varchar(100), is_allowed bit, email varchar(300), send_notification bit)
insert into white_list_users (account_number, username, team, is_allowed, email, send_notification) values 
('ALBILAD\e008374', 'Fahad Suliman Alqarawi', 'DBA Manager', 1,'FSAlqarawi@bankAlbilad.com',0),
('ALBILAD\e004199', 'Abdulmohsen Ibrahim Bin Abdulwahed', 'DBA', 1,'AI.BinAbdulwahed@Bankalbilad.com',1),
('ALBILAD\c904153', 'Shaik Zubair Fareed', 'DBA', 1, 'SZubairFareed@Bankalbilad.com',1),
('ALBILAD\c904529', 'Mohammed Fawzy AlHaleem', 'DBA', 1, 'MFawzyAlHaleem@Bankalbilad.com',1),
('ALBILAD\e010043', 'Nawaf Abdulrahman Bukhari', 'DBA', 1,'NAbdulrahmanBukhari@Bankalbilad.com',1),
('ALBILAD\e010052', 'Hamad Fahad Al Rubayq', 'DBA', 1,'HFahadAlRubayq@Bankalbilad.com',1),
('BANKSA', 'System Admin', 'System Admin', 1, NULL, 0)
go

Create TRIGGER [TRG_SchemaChange_LogInTable_DDL]
ON ALL SERVER 
FOR CREATE_TABLE,DROP_TABLE,ALTER_TABLE,CREATE_VIEW,DROP_VIEW,
ALTER_VIEW,CREATE_PROCEDURE,DROP_PROCEDURE,ALTER_PROCEDURE
AS 
begin
DECLARE @eventInfo XML, @EmailRecipients Nvarchar(1500)
SET  @eventInfo = EVENTDATA()
Declare @PostTime nvarchar(max);
Set @PostTime = REPLACE(CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/PostTime)')),'T', ' ')
Declare @LoginName nvarchar(max); 
Set @LoginName = CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/LoginName)'))
Declare @UserName nvarchar(max); 
Set @UserName =  CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/UserName)'))
Declare @InstanceName nvarchar(max);
Set @InstanceName = (Select @@SERVERNAME)
Declare @DatabaseName nvarchar(max); 
Set @DatabaseName = CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/DatabaseName)'))
Declare @SchemaName nvarchar(max); 
Set @SchemaName = CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/SchemaName)'))
Declare @ObjectName nvarchar(max);  
Set @ObjectName = CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/ObjectName)'))
Declare @ObjectType nvarchar(max); 
Set @ObjectType = CONVERT(Nvarchar(500),@eventInfo.query('data(/EVENT_INSTANCE/ObjectType)'))
Declare @HostName nvarchar(max); 
Set @HostName = (Select Host_Name())
Declare @HostIP nvarchar(max); 
Set @HostIP =  (SELECT client_net_address FROM sys.dm_exec_connections  WHERE session_id = @@SPID )
Declare @PROGRAM_NAME nvarchar(max); 
Set @PROGRAM_NAME = (Select PROGRAM_NAME())
Declare @DDLQuery nvarchar(max); 
Set @DDLQuery = @eventInfo.value( '(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)' )
DECLARE @ErrorMsg     nvarchar(max);    -- To hold the error message we create
DECLARE @MailSubject  nvarchar(2048);   -- To hold the Subject for the Mail.                              
INSERT INTO  msdb..TRG_SchemaChange_LogInTable_DDL  VALUES
( 
@PostTime , @LoginName , @UserName , @InstanceName , @DatabaseName , @SchemaName , @ObjectName , @ObjectType , @HostName , @HostIP , @PROGRAM_NAME , @DDLQuery
) 

IF @LoginName NOT IN (select account_number from white_list_users where is_allowed = 1)
Begin 
SELECT @ErrorMsg  =   '
Dear Database Team 
We arrested breakthrough case on Database Production: ' + @DatabaseName + CHAR(13) + CHAR(13)  + 
' Exists on Database Server ' + @InstanceName + CHAR(13) + CHAR(13)  + 
' Executed by user: ' + @LoginName + CHAR(13) + CHAR(13)  + 
' Please take immediate preventive actions this Login Name is [ ' + @LoginName + ' ] Conected from Host Name [ ' + @HostName + ' ] and the Host IP is ' + @HostIP +  CHAR(13) + CHAR(13)  + 
' ********* BEGIN DDL Statement ******** '+ CHAR(13) + CHAR(13)  + 
 @DDLQuery + CHAR(13) + CHAR(13)  +
' ******** END DDL Statement ******** '+ CHAR(13) + CHAR(13)  +
'For More Information Execute Below Query on the DB Server Mentioned on Email'+ CHAR(13) + CHAR(13)  +
'Select * from MSDB.[dbo].[TRG_SchemaChange_LogInTable_DDL] Order By EventTime DESC' 

SELECT @MailSubject = 'Database Security breakthrough! caught DDL Statement on ' + @DatabaseName +' on Server ' + @InstanceName

select @EmailRecipients = isnull(@EmailRecipients,'') + email +';' from white_list_users
where is_allowed = 1 
and send_notification = 1
and email is not null

EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'DBAlert' 
, @recipients   = @EmailRecipients
, @subject      = @MailSubject
, @body         = @ErrorMsg  
, @importance   = 'high'; 
Print'You are not authorized to fo this action'
END
END
GO

DISABLE TRIGGER [TRG_SchemaChange_LogInTable_DDL] ON ALL SERVER
GO


Create TRIGGER [Trg_TrackLoginManagement]
-- Author:      Mostafa EL-Masry
-- Create date: 25/03/2019
-- Description: Trg_TrackLoginManagement
ON ALL SERVER
FOR 
 DDL_SERVER_SECURITY_EVENTS
AS
BEGIN
SET NOCOUNT ON
Begin transaction TrackLoginManagement
DECLARE @data xml,
              @EventType Nvarchar(500),
              @EventTime datetime,
              @ServerName Nvarchar(500),
              @AffectedLoginName Nvarchar(500),
              @WhoDidIt Nvarchar(500),
              @EmailSubject Nvarchar(500),
              @EmailBody Nvarchar(800),
			  @EmailBody2 Nvarchar(800),
              @EmailRecipients Nvarchar(1500),
              @TSQL Nvarchar(MAX)
 
select @EmailRecipients = isnull(@EmailRecipients,'') + email +';' from white_list_users
where is_allowed = 1 
and send_notification = 1
and email is not null

--SET @EmailRecipients = @EmailRecipients
SET @data = EVENTDATA()
SET @EventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(100)')
SET @EventTime = @data.value('(/EVENT_INSTANCE/PostTime)[1]','datetime')
SET @ServerName = @data.value('(/EVENT_INSTANCE/ServerName)[1]','varchar(100)')
SET @AffectedLoginName = @data.value('(/EVENT_INSTANCE/ObjectName)[1]','varchar(100)')
SET @WhoDidIt = @data.value('(/EVENT_INSTANCE/LoginName)[1]','varchar(100)')
SET @TSQL = @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]','varchar(4000)')

SET @EmailSubject =  @EventType + ' occured by ' + @WhoDidIt + ' on ' +
      @ServerName + ' occured at: ' + convert(Varchar, @EventTime) 
SET @EmailBody = 'This User Tried to Do edit on DB Secuirty Level with this T-SQL ' + @TSQL +' 
and the Transaction is Rolled Back because this user is not From DBA Team 
Please Communicate with him to Understand Why he do this action
'
SET @EmailBody2 = 'This User Tried to Do edit on DB Secuirty Level with this T-SQL ' + @TSQL +' and the Transaction is Committed because this user is one of the DBA Team'
IF @WhoDidIt in (select account_number from white_list_users where is_allowed = 1)
begin
Commit transaction TrackLoginManagement
EXEC msdb.dbo.sp_send_dbmail  
    @recipients = @EmailRecipients
  , @subject = @EmailSubject  
  , @body = @EmailBody2 
  , @importance = 'High'  
  , @profile_name = 'DBAlert' -- Put profile name here
  , @body_format = 'HTML' ; 
END
ELSE 
begin
Rollback 
EXEC msdb.dbo.sp_send_dbmail  
    @recipients = @EmailRecipients
  , @subject = @EmailSubject  
  , @body = @EmailBody 
  , @importance = 'High'  
  , @profile_name = 'DBAlert' -- Put profile name here
  , @body_format = 'HTML' ; 
 end
Insert into MSDB..Trg_TrackLoginManagement
(EventType,WhoDidIt,ServerName,EventTime,SQLScript)
Select 
@EventType,@WhoDidIt,@ServerName,@EventTime,@TSQL
END
GO

ENABLE TRIGGER [Trg_TrackLoginManagement] ON ALL SERVER
GO



CREATE TRIGGER [TRG_Pervent_Accounts_to_Login_to_SQL]
ON ALL SERVER 
FOR LOGON
AS
BEGIN
   DECLARE @program_name nvarchar(128)
   DECLARE @host_name nvarchar(128)
   SELECT @program_name = program_name, 
      @host_name = host_name
   FROM sys.dm_exec_sessions AS c
   WHERE c.session_id = @@spid
   IF ORIGINAL_LOGIN() IN('ALBILAD\svc_avbkup','apm_prd') 
      ----AND @program_name LIKE '%Management%Studio%' 
	 and @program_name in( 'Microsoft SQL Server Management Studio','SQLCMD')
   BEGIN
      RAISERROR('This login is for application use only.',16,1)
      ROLLBACK;
Insert into MSDB..Pervent_Accounts_to_Login_to_SQL
(LoginName,HostName,APPName)
Select ORIGINAL_LOGIN(),@host_name,@program_name
   END
END;
GO

ENABLE TRIGGER [TRG_Pervent_Accounts_to_Login_to_SQL] ON ALL SERVER
GO



Create TRIGGER  [DBA_PREVENT_SERVERLEVEL_DB_CHANGES] 
ON ALL SERVER 
FOR   CREATE_DATABASE , ALTER_DATABASE ,  DROP_DATABASE
AS 
BEGIN
DECLARE @data xml,
              @EventType varchar(100),
              @EventTime datetime,
              @ServerName varchar(100),
              @AffectedLoginName varchar(100),
              @WhoDidIt varchar(100),
              @EmailSubject varchar(500),
              @EmailBody varchar(800),
              @EmailRecipients varchar(1500),
              @TSQL varchar(4000),
			  @DATABASEName nvarchar(128) 

select @EmailRecipients = isnull(@EmailRecipients,'') + email +';' from white_list_users
where is_allowed = 1 
and send_notification = 1
and email is not null


--SET @EmailRecipients = @EmailRecipients
Set @DATABASEName = @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(128)')
SET @data = EVENTDATA()
SET @EventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(100)')
SET @EventTime = @data.value('(/EVENT_INSTANCE/PostTime)[1]','datetime')
SET @ServerName = @data.value('(/EVENT_INSTANCE/ServerName)[1]','varchar(100)')
SET @AffectedLoginName = @data.value('(/EVENT_INSTANCE/ObjectName)[1]','varchar(100)')
SET @WhoDidIt = @data.value('(/EVENT_INSTANCE/LoginName)[1]','varchar(100)')
SET @TSQL = @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]','varchar(4000)')

SET @EmailSubject =  @EventType + ' occured by ' + @WhoDidIt + ' on ' +
      @ServerName + ' occured at: ' + convert(Varchar, @EventTime) 
SET @EmailBody = @EventType + ' occured by ' + @WhoDidIt + ' on ' +
      @ServerName + ' occured at: ' + convert(Varchar, @EventTime) + 
	  ' and here is the T-SQL he Executed it {{ ' +@TSQL +' }}
	  YOU ARE NOT ALLOWED TO PERFORM THIS ACTION. For more information CONSULT YOUR DBA FOR SUPPORT
	  ' 
Rollback;
EXEC msdb.dbo.sp_send_dbmail  
    @recipients = @EmailRecipients
  , @subject = @EmailSubject  
  , @body = @EmailBody 
  , @importance = 'High'  
  , @profile_name = 'DBAlert' -- Put profile name here
  , @body_format = 'HTML' ;  

Insert into MSDB..DBA_PREVENT_SERVERLEVEL_DB_CHANGES
(EventType,WhoDidIt,ServerName,EventTime,SQLScript)
Select 
@EventType,@WhoDidIt,@ServerName,@EventTime,@TSQL
Print 'YOU ARE NOT ALLOWED TO PERFORM THIS ACTION. CONSULT YOUR DBA FOR SUPPORT'
--RAISERROR ('YOU ARE NOT ALLOWED TO PERFORM THIS ACTION. CONSULT YOUR DBA FOR SUPPORT  %s' , 25 , 2 , @DATABASEName ) WITH LOG
--return
END
GO

ENABLE TRIGGER [DBA_PREVENT_SERVERLEVEL_DB_CHANGES] ON ALL SERVER
GO

use msdb
go

if object_id('[dbo].[TRG_SchemaChange_LogInTable_DDL]') is null
begin

CREATE TABLE [dbo].[TRG_SchemaChange_LogInTable_DDL](
	[RecordId] [int] IDENTITY(1,1) NOT NULL,
	[EventTime] [datetime] NULL,
	[LoginName] [nvarchar](500) NULL,
	[UserName] [nvarchar](500) NULL,
	[InstanceName] [nvarchar](500) NULL,
	[DatabaseName] [nvarchar](500) NULL,
	[SchemaName] [nvarchar](500) NULL,
	[ObjectName] [nvarchar](500) NULL,
	[ObjectType] [nvarchar](500) NULL,
	[HostName] [nvarchar](500) NULL,
	[HostIP] [nvarchar](500) NULL,
	[Programme_Name] [nvarchar](500) NULL,
	[DDLCommand] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
print('Table [dbo].[TRG_SchemaChange_LogInTable_DDL] created')
end
GO

