declare 
@type varchar(30),
@name varchar(300),
@sql varchar(1000)

declare i cursor fast_forward
for
select case type 
when 'P'	then 'PROCEDURE' 
when 'V'	then 'VIEW' 
when 'U'	then 'TABLE'
when 'TF'	then 'FUNCTION'
when 'FN'	then 'FUNCTION'
end , '['+schema_name(schema_id)+'].['+name+']'
from sys.objects
where object_id in (
object_id('[dbo].[Dynamic_restore_HTML]'), 
object_id('[dbo].[kill_sessions_before_restore]'),
object_id('[dbo].[monitor_restore]'),
object_id('[dbo].[set_compatibility]'),
object_id('[dbo].[sp_restore_database_distribution_groups]'),
object_id('[dbo].[sp_notification_restore]'))

open i
fetch next from i into @type, @name
while @@FETCH_STATUS = 0
begin

set @sql = 'DROP '+@type+' '+@name
exec(@sql)
fetch next from i into @type, @name
end
close i
deallocate i
go
if OBJECT_ID('[dbo].[white_list_users]') is null
begin
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
end
go

if OBJECT_ID('[dbo].[restore_notification]') is null
begin
CREATE TABLE [dbo].[restore_notification](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[database_name] [varchar](500) NULL,
	[status] [int] NULL,
	[start_time] [datetime] NULL,
	[finish_time] [datetime] NULL,
	[total_files] [int] NULL,
	[current_file] [int] NULL,
	[last_file_name] [varchar](1000) NULL
) ON [PRIMARY]
end
GO

if OBJECT_ID('[dbo].[restore_loction_groups]') is null
begin
CREATE TABLE [dbo].[restore_loction_groups](
	[directorys_map] [varchar](2000) NULL
) ON [PRIMARY]
end
GO

if OBJECT_ID('[dbo].[restore_loction_groups]') is null
begin
declare @physical_name varchar(2000) = ''
select 
@physical_name = cast(data_space_id as varchar)+'-'+physical_name+';' + @physical_name
from (
select distinct data_space_id, reverse(substring(reverse(physical_name), charindex('\',reverse(physical_name)), len(physical_name))) physical_name
from sys.master_files
where db_name(database_id) = 'T24SDC61')a
order by data_space_id desc, physical_name 

insert into [dbo].[restore_loction_groups] values (substring(@physical_name,1,len(@physical_name)-1))
end
go

create Procedure set_compatibility
(@db_name varchar(500))
as
begin
declare 
@instance_level		int,
@database_level		int,
@version			int, 
@sql				varchar(1500)

select @version = substring(cast(value_data as varchar(20)),1,charindex('.',cast(value_data as varchar(20)))-1)
from sys.dm_server_registry
where value_name = 'CurrentVersion'

select @instance_level = case @version 
when 10 then 100	--2008
when 11 then 110	--2012
when 12 then 120	--2014
when 13 then 130	--2016
when 14 then 140	--2017
when 15 then 150	--2019
end

select @database_level = compatibility_level 
from sys.databases
where name = @db_name

if @instance_level != @database_level
begin
	set @sql = 'ALTER DATABASE ['+@db_name+'] SET COMPATIBILITY_LEVEL = '+cast(@instance_level as varchar)
	exec(@sql)
end
end
go

CREATE Procedure [dbo].[kill_sessions_before_restore]
(@type varchar(100), @name varchar(400))
as
begin
declare @kill varchar(50)
declare @table table (kill_statement varchar(30))

if @type = 'database'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where dbid = db_id(@name)
end
else
if @type = 'login'
begin
insert into @table
select 'kill '+cast(spid as varchar)
from sys.sysprocesses 
where loginame = @name
end

declare k cursor fast_forward
for
select kill_statement from @table
open k
fetch next from k into @kill
while @@FETCH_STATUS = 0
begin
print(@kill)
exec(@kill)
fetch next from k into @kill
end
close k
deallocate k
end

go

create view [dbo].[monitor_restore]
as
select spid, percent_complete, database_name, backup_file, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(backup_file,1,charindex('\',backup_file)-1)) backup_file_name,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete, [restore_type], duration, time_to_complete, estimated_completion_time,
reverse(substring(reverse(database_name),1,charindex(' ',reverse(database_name))-1)) database_name,
reverse(replace(replace(substring(text,1, charindex('''', text,6)),'N''','') ,'''','')) backup_file,
waittime, lastwaittype, blocked, command, status
from (
select spid, percent_complete,
case
when s.text like '%restore database%' and s.text like '%move%' then 'FULL'
when s.text like '%restore database%' and s.text not like '%move%' then 'DIFF'
when s.text like '%restore log%' then 'LOG' end [restore_type], 
dbo.duration('s',datediff(s, r.start_time, getdate())) duration, 
dbo.duration('s',
case when percent_complete = 0 then 0 else case when 
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
< 0 then 0 else
cast((100.0 / (round(percent_complete,5) + .00001)) 
* 
datediff(s, r.start_time, getdate()) as int)
-
datediff(s, r.start_time, getdate())
end end
) time_to_complete,
dbo.duration('s', estimated_completion_time/1000) estimated_completion_time,
ltrim(rtrim(substring(s.text,1, charindex('from',s.text)-4))) database_name,
substring(s.text,charindex('=',s.text)+1,len(s.text)) text,
waittime, lastwaittype, blocked, command, r.status
from sys.sysprocesses p cross apply sys.dm_exec_sql_text(p.sql_handle)s
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
where command like 'Restore%')a)b
GO

CREATE Procedure [dbo].[Dynamic_restore_HTML]
(@html varchar(max) output)
as
begin
set nocount on

select 
rn.database_name [Database Name],
Command,
cast(round((cast(rn.current_file as float) / cast(rn.total_files  as float)) * 100.0, 4) as varchar)+' %' [Overall Percent Complete],
cast(round(percent_complete,3) as varchar)+' %'  [Current Backup File Percent Complete],
Restore_type,
duration Restore_duration,
Time_to_complete,
Estimated_completion_time,
backup_file_name [Backup File Name]
into dynamicHTMLTable 
from [dbo].[monitor_restore] mr cross apply dbo.restore_notification rn
where rn.status = 0

declare 
@tr varchar(max), 
@th varchar(max), 
@cursor____columns varchar(max), 
@cursor_vq_columns varchar(max), 
@cursor_vd_columns varchar(max), 
@cursor_vr_columns varchar(max), 
@query_columns_count int, 
@sqlstatement varchar(max),
@border_color varchar(100) = 'gray'

declare @tr_table table (id int identity(1,1), row_id int, tr varchar(1000))

select
@cursor____columns = isnull(@cursor____columns+',
','')+'['+c.name+']',
@cursor_vq_columns = isnull(@cursor_vq_columns+',
','')+'@'+replace(c.name,' ','_'),
@cursor_vd_columns = isnull(@cursor_vd_columns+',
','')+'@'+replace(c.name,' ','_')+' '+case 
when t.name in ('char','nchar','varchar','nvarchar') then t.name+'('+case when c.max_length < 0 then 'max' else cast(c.max_length as varchar(10)) end+')' 
when t.name in ('bit') then 'varchar(5)'
when t.name in ('real','int','bigint','smallint','tinyint','float') then 'varchar(20)'
else '' 
end,
@cursor_vr_columns = isnull(@cursor_vr_columns+'
union all 
select @loop, ','')+''''+'<td style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle;">'+''''+'+ltrim(rtrim(@'+replace(c.name,' ','_')+'))+'+''''+'</td>'+''''
from sys.columns c inner join sys.types t
on c.user_type_id = t.user_type_id
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable%')
order by column_id

select @th = isnull(@th+'
','')+'<th style="border:1px solid '+@border_color+';">'+name+'</th>'
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable%')
order by column_id

select @query_columns_count = count(*)
from sys.columns 
where object_id in (select object_id
from sys.tables
where name like 'dynamicHTMLTable%')

set @sqlstatement = '
declare @loop int = 0
declare '+@cursor_vd_columns+'
declare i cursor 
for 
select '+@cursor____columns+' 
from dynamicHTMLTable

open i 
fetch next from i into '+@cursor_vq_columns+'
while @@fetch_status = 0
begin
set @loop = @loop + 1
select @loop, '+@cursor_vr_columns+'
fetch next from i into '+@cursor_vq_columns+'
end
close i
deallocate i'

insert into @tr_table
exec(@sqlstatement)

select @tr = isnull(@tr+'
','') +
case 
when col_position = 1 then
'</tr>
  <tr style="border:1px solid '+@border_color+'; text-align: center; vertical-align: middle;">
  '+tr
when col_position = col_count then
tr+'
</tr>'
else 
tr
end
from (
select top 100 percent row_number() over(partition by row_id order by id) col_position,id,row_id,@query_columns_count col_count,tr 
from @tr_table
order by id, row_id)a


declare @table varchar(max) = '
<table style="border:1px solid '+@border_color+';border-collapse:collapse;width: 70%">
  <tr bgcolor="YELLOW">
  '+@th+'
  '+@tr+'
'+'</table>'

set @html = @table

drop table dynamicHTMLTable
set nocount off
end

go

CREATE Procedure [dbo].[sp_notification_restore] (
@done					bit = 0,
@ccteam					varchar(200), 
@dba_in_to				varchar(500) = 'ALBILAD\c904529',
@db_mail_profile		varchar(50)  = 'DBAlert')
as
begin
declare 
@registry_key1			varchar(1500), 
@system_instance_name	varchar(300), 
@instance_name			varchar(100),
@server_name			varchar(100),
@IpAddress				varchar(50),
@subject				varchar(1000),
@database_name			varchar(500),
@email					varchar(1000),
@ccemail				varchar(1000),
@email_body				varchar(max),
@dear					varchar(500)


select @dear = isnull(@dear+', '+case when id = users and users > 1 then 'and ' else '' end, '') + username
from (
select top 100 percent row_number() over(order by id) id, substring(username,1, charindex(' ',username)-1) username, count(*) over() users
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)
order by id)a

if @done = 1
begin
set @email_body = '<p><b>Dear '+@dear+'</b>,</p>

<p>Kindly be informed that the restore was <b>completed successfully</b>.</p>

<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'
end
else
begin
exec master.dbo.Dynamic_restore_HTML
@html = @email_body output
set @email_body = '<p><b>Dear '+@dear+'</b>,</p>


<p>Kindly be informed that the restore is <b>in progress</b> and you can find the status in the below table.</p>


'+@email_body+'


<p><b>Thanks a lot...</b></p>
<p><b>Database Monitoring.</b></p>'
end

select 
@server_name = case when charindex('\',name) > 0 then substring(name, 1, charindex('\',name)-1) else name end,
@instance_name = case when charindex('\',name) > 0 then substring(name, charindex('\',name)+1, len(name)) else 'MSSQLSERVER' end
from sys.servers where server_id = 0

declare @table table (id int identity(1,1), output_Text varchar(max))
declare @xp varchar(200), @id int
set @xp = 'ipconfig'
insert into @table
exec xp_cmdshell @xp

select @id = id 
from (
select id, case when charindex('.',ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))) > 0 then 1 else 0 end has_gateway
from @table
where id in (select id + 2
from @table
where output_Text like '%IPV4%'))a
where has_gateway = 1

select @IpAddress = ltrim(rtrim(substring(output_Text,charindex(':',output_text)+1, len(output_text))))-- IP_address
from @table
where id = @id - 2

select @database_name = database_name from [master].[dbo].[monitor_restore]
set @subject = 'Restore monitor Progress Bar '+@Server_name+' - '+@IpAddress+' ('+replace(replace(@database_name,'[',''),']','')+')'

select @ccemail = isnull(@ccemail+';','')+email 
from white_list_users
where send_notification = 1
and account_number != @dba_in_to
and is_allowed = 1

select @email = isnull(@email+';','')+email 
from white_list_users
where is_allowed = 1
and (account_number = @dba_in_to
or team = @ccteam)

exec msdb..sp_send_dbmail 
@profile_name = @db_mail_profile, 
@recipients = @email, 
@copy_recipients = @ccemail,
@subject = @subject, 
@body = @email_body, 
@body_format = 'HTML'

end

go

create Procedure [dbo].[sp_restore_database_distribution_groups]
(
@backupfile					varchar(max), 
@filenumber					varchar(5) = 'all', 
@option_01					int = 0,				   -- the new location of all files (log, data, or archive) will be the same of the location in the file list regarding the backup file.
@option_02					int = 0,				   -- all file (primary (.mdf), log fils (.ldf), secondary file (.ndf), archive file in the same location.
@restore_loc				varchar(500)  = 'default',
@option_03					int = 0,				   -- specify the data files folder (1 folder) and the same of the log files (1 folder too).
@restore_loc_data			varchar(500)  = 'default',
@restore_loc_log			varchar(500)  = 'default',
@option_04					int = 0,
@number_of_files_per_type	varchar(100)  = 'default', --'2-4'  "2" is the file type id, and "4" is the number of files per location
@restore_loction_groups		varchar(1000) = 'default', --'0-T:\SQLSERVER\Data\;1-J:\SQLSERVER\Data\;2-J:\SQLSERVER\Data\;2-K:\SQLSERVER\Data\;2-L:\SQLSERVER\Data\;2-M:\SQLSERVER\Data\;3-N:\SQLSERVER\Data\',
													   --"0,1,2,3" file type
													   -- 0 Log file .ldf
													   -- 1 primary file .mdf
													   -- 2 secondary file .ndf
													   -- 3 archive file
@with_recovery				bit = 1,  
@new_db_name				varchar(500)  = 'default',
@percent					int = 5,
@password					varchar(100)  = 'default',
@replace					bit,
@log_stopat					varchar(100)  = 'default',
@action						int = 1)

as
begin 
declare @restor_loc_table			table (output_text varchar(max))
declare @restor_loc_table_data		table (output_text varchar(max))
declare @restor_loc_table_data_1	table (output_text varchar(max))
declare @restor_loc_table_data_2	table (output_text varchar(max))
declare @restor_loc_table_data_3	table (output_text varchar(max))
declare @restor_loc_table_log		table (output_text varchar(max))
declare @xp_cmdshell varchar(500), 
@files_exist int, 
@files_exist_data int, 
@files_exist_log int, 
@file_type varchar(5)
declare 
@sql					varchar(max), 
@file_move				varchar(max), 
@file_move_data			varchar(max), 
@file_move_log			varchar(max), 
@file					int, 
@version				int,
@logicalname			varchar(500), 
@originalpath			varchar(max), 
@physicalname			varchar(500),
@ext					varchar(10),
@unique_id				varchar(10),
@Position				int, 
@DatabaseName			varchar(500), 
@BackupType				int,
@lastfile				int

declare @filelistonly_groups table (fileid int, LogicalName varchar(300), [location] varchar(1500), filename varchar(300), ext varchar(20), Type varchar(10)) 
declare @headeronly table (
BackupName				nvarchar(512),
BackupDescription		nvarchar(255),
BackupType				smallint,
ExpirationDate 			datetime,
Compressed				int,
Position 				smallint,
DeviceType 				tinyint,
UserName 				nvarchar(128),
ServerName 				nvarchar(128),
DatabaseName 			nvarchar(512),
DatabaseVersion 		int,
DatabaseCreationDate 	datetime,
BackupSize 				numeric(20,0),
FirstLSN 				numeric(25,0),
LastLSN 				numeric(25,0),
CheckpointLSN 			numeric(25,0),
DatabaseBackupLSN 		numeric(25,0),
BackupStartDate 		datetime,
BackupFinishDate 		datetime,
SortOrder 				smallint,
CodePage 				smallint,
UnicodeLocaleId 		int,
UnicodeComparisonStyle 	int,
CompatibilityLevel 		tinyint,
SoftwareVendorId 		int,
SoftwareVersionMajor 	int,
SoftwareVersionMinor 	int,
SoftwareVersionBuild 	int,
MachineName 			nvarchar(128),
Flags 					int,
BindingID 				uniqueidentifier,
RecoveryForkID			uniqueidentifier,
Collation 				nvarchar(128),
FamilyGUID 				uniqueidentifier,
HasBulkLoggedData 		bit,
IsSnapshot				bit,
IsReadOnly				bit,
IsSingleUser 			bit,
HasBackupChecksums		bit,
IsDamaged 				bit,
BeginsLogChain 			bit,
HasIncompleteMetaData 	bit,
IsForceOffline 			bit,
IsCopyOnly 				bit,
FirstRecoveryForkID 	uniqueidentifier,
ForkPointLSN 			numeric(25,0),
RecoveryModel 			nvarchar(60),
DifferentialBaseLSN 	numeric(25,0),
DifferentialBaseGUID 	uniqueidentifier,
BackupTypeDescription 	nvarchar(60),
BackupSetGUID 			uniqueidentifier,
CompressedBackupSize 	bigint,
containment 			tinyint,
KeyAlgorithm 			nvarchar(32)  default NULL,
EncryptorThumbprint 	varbinary(20)  default NULL,
EncryptorType 			nvarchar(32))

declare @filelistonly table (
LogicalName				varchar(1000),
PhysicalName			varchar(max),
Type					varchar(5),
filegroup varchar(300), col02 varchar(max),col03 varchar(max),fileid int,
col05 varchar(max),col06 varchar(max),col07 varchar(max),col08 varchar(max),
col09 varchar(max),col10 varchar(max),col11 varchar(max),filetype int,
col13 varchar(max),col14 varchar(max),col15 varchar(max),col16 varchar(max),
col17 varchar(max),col18 varchar(max),col19 varchar(max))

set nocount on
if @password = 'default'
begin
set @sql = 'restore filelistonly from disk = '+''''+@backupfile+''''
end
else
begin
set @sql = 'restore filelistonly from disk = '+''''+@backupfile+''''+' with file = 1, mediapassword = '+''''+@password+''''
end

--restore filelistonly from disk = 'm:\backup_database\Backup_database_migration\wslogdb70_110_Full_2021_06_27__16_38_37.bak'
--print(@sql)

select @version = case 
when @@version like '%SQL Server 2008%' then 10 
when @@version like '%SQL Server 2012%' then 11 
when @@version like '%SQL Server 2014%' then 12 
when @@version like '%SQL Server 2016%' then 13 
when @@version like '%SQL Server 2017%' then 14 
when @@version like '%SQL Server 2019%' then 15 
end

if @version = 12
begin
insert into @filelistonly (
LogicalName,PhysicalName,Type,
filegroup, col02, col03, fileid, col05, col06, col07, col08,
col09, col10, col11, filetype, col13, col14, col15, col16,
col17, col18)
exec(@sql)
end
else
begin
insert into @filelistonly 
exec(@sql)
end

if @password = 'default'
begin
set @sql = 'restore headeronly from disk = '+''''+@backupfile+''''
end
else
begin
set @sql = 'restore headeronly from disk = '+''''+@backupfile+''''+' with file = 1, mediapassword = '+''''+@password+''''
end

if @version = 10
begin
insert into @headeronly (
BackupName,BackupDescription,BackupType,ExpirationDate,Compressed,Position,DeviceType,UserName,ServerName,
DatabaseName,DatabaseVersion,DatabaseCreationDate,BackupSize,FirstLSN,LastLSN,CheckpointLSN,DatabaseBackupLSN,
BackupStartDate,BackupFinishDate,SortOrder,CodePage,UnicodeLocaleId,UnicodeComparisonStyle,CompatibilityLevel,
SoftwareVendorId,SoftwareVersionMajor,SoftwareVersionMinor,SoftwareVersionBuild,MachineName,Flags,BindingID,
RecoveryForkID,Collation,FamilyGUID,HasBulkLoggedData,IsSnapshot,IsReadOnly,IsSingleUser,HasBackupChecksums,
IsDamaged,BeginsLogChain,HasIncompleteMetaData,IsForceOffline,IsCopyOnly,FirstRecoveryForkID,ForkPointLSN,
RecoveryModel,DifferentialBaseLSN,DifferentialBaseGUID,BackupTypeDescription,BackupSetGUID,CompressedBackupSize)
exec(@sql)
end
else if @version = 11
begin
insert into @headeronly (
BackupName,BackupDescription,BackupType,ExpirationDate,Compressed,Position,DeviceType,UserName,ServerName,
DatabaseName,DatabaseVersion,DatabaseCreationDate,BackupSize,FirstLSN,LastLSN,CheckpointLSN,DatabaseBackupLSN,
BackupStartDate,BackupFinishDate,SortOrder,CodePage,UnicodeLocaleId,UnicodeComparisonStyle,CompatibilityLevel,
SoftwareVendorId,SoftwareVersionMajor,SoftwareVersionMinor,SoftwareVersionBuild,MachineName,Flags,BindingID,
RecoveryForkID,Collation,FamilyGUID,HasBulkLoggedData,IsSnapshot,IsReadOnly,IsSingleUser,HasBackupChecksums,
IsDamaged,BeginsLogChain,HasIncompleteMetaData,IsForceOffline,IsCopyOnly,FirstRecoveryForkID,ForkPointLSN,
RecoveryModel,DifferentialBaseLSN,DifferentialBaseGUID,BackupTypeDescription,BackupSetGUID,CompressedBackupSize,containment)
exec(@sql)
end
else if @version > 11
begin
insert into @headeronly 
exec(@sql)
end

if @option_04 = 1
begin

insert into @filelistonly_groups (fileid, LogicalName, [location], [filename], ext, [Type])
select fileid,
LogicalName, originalPath, 
case when PhysicalName like '%.%' then 
		substring(PhysicalName, 1, charindex('.',PhysicalName)-1) else PhysicalName end PhysicalName,
case when PhysicalName like '%.%' then 
		reverse(substring(reverse(PhysicalName), 1, charindex('.',reverse(PhysicalName)))) else 'no_ext' end ext,
		type
from (
select LogicalName, type, fileid,
loc OriginalPath, 
reverse(substring(reverse(PhysicalName), 1, charindex('\',reverse(PhysicalName))-1)) PhysicalName
from (
select LogicalName, PhysicalName, Type, loc.loc, files.fileid
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, filetype, row_number() over(partition by filetype order by fileid) seq_id
from @filelistonly
where filetype != dbo.virtical_array(@number_of_files_per_type, '-', 1) 
) files 
left join (
select id, filetype, loc, row_number() over (partition by filetype order by filetype) location_id
from (
select id, dbo.virtical_array(value, '-', 1) filetype, dbo.virtical_array(value, '-', 2) loc
from dbo.separator(@restore_loction_groups,';'))a
where filetype != dbo.virtical_array(@number_of_files_per_type, '-', 1)) loc
on files.filetype = loc.filetype
union all
select LogicalName, PhysicalName, Type, loc.loc, files.fileid
from (
select *, row_number() over(partition by seq order by fileid) file_group_id
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, a.filetype, 
case when a.filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1) then 
case seq_id % cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int) when 0 then cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int) 
else seq_id % cast(dbo.virtical_array(@number_of_files_per_type, '-', 2) as int)
end else 0
end seq 
from (
select LogicalName, PhysicalName, Type, filegroup, fileid, filetype, row_number() over(partition by filetype order by fileid) seq_id
from @filelistonly
where filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1) 
)a)b) files inner join (
select id, filetype, loc, row_number() over (partition by filetype order by filetype) location_id
from (
select id, dbo.virtical_array(value, '-', 1) filetype, dbo.virtical_array(value, '-', 2) loc
from dbo.separator(@restore_loction_groups,';'))a
where filetype = dbo.virtical_array(@number_of_files_per_type, '-', 1)) loc
on files.filetype = loc.filetype
and files.file_group_id = loc.location_id)a)b
order by fileid

declare @fileid int, @location varchar(1500)
declare g cursor fast_forward
for
select distinct fileid, location 
from @filelistonly_groups

end
--print(@sql)

select @lastfile = max(Position) from @headeronly

if (@option_01 = 1 or @option_02 = 1)
begin
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc+'"'+''''
	insert into @restor_loc_table
	exec (@xp_cmdshell)
end
else if @option_03 = 1
begin
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc_data+'"'+''''
	insert into @restor_loc_table_data
	exec (@xp_cmdshell)
	set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@restore_loc_log+'"'+''''
	insert into @restor_loc_table_log
	exec (@xp_cmdshell)
end	
else if @option_04 = 1
begin
	open g
	fetch next from g into @fileid, @location
	while @@FETCH_STATUS = 0
	begin
		set @xp_cmdshell = 'xp_cmdshell ''dir cd "'+@location+'"'+''''
		if @fileid = 0
		begin
			insert into @restor_loc_table_log
			exec (@xp_cmdshell)
		end
		else if @fileid = 1
		begin
			insert into @restor_loc_table_data_1
			exec (@xp_cmdshell)
		end
		else if @fileid = 2
		begin
			insert into @restor_loc_table_data_2
			exec (@xp_cmdshell)
		end
		else if @fileid = 3
		begin
			insert into @restor_loc_table_data_3
			exec (@xp_cmdshell)
		end
	fetch next from g into @fileid, @location
	end
	close g
	deallocate g
end	

if (@option_01 + @option_02) = 1
begin
		select @files_exist = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end
else if (@option_03 = 1)
begin
		select @files_exist_data = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist

		select @files_exist_log = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_log
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end

else if (@option_04 = 1)
begin
		select @files_exist_data = count(*)
		from (

		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_1
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		union all
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_2
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		union all
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_data_3
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a
		)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist

		select @files_exist_log = count(*)
		from (
		select substring(output_text, charindex(' ',output_text)+1,len(output_text)) restore_loc_files
		from (
		select ltrim(rtrim(substring(output_text, charindex('M   ',output_text)+1,len(output_text)))) output_text
		from @restor_loc_table_log
		where output_text like '%M   %'
		and output_text not like '%<DIR>%'
		and (output_text like '%.mdf%'
		or output_text like '%.ndf%'
		or output_text like '%.ldf%'))a)b
		inner join (select reverse(substring(reverse(PhysicalName),1,charindex('\',reverse(physicalname))-1)) filelist from @filelistonly) fl
		on b.restore_loc_files = fl.filelist
end

declare backupfiles_cursor cursor fast_forward for
select Position, DatabaseName, BackupType
from @headeronly
where Position between 
case when @filenumber = 'all' then 0 else @filenumber end
and
case when @filenumber = 'all' then @lastfile else @filenumber end

declare dbfiles_cursor cursor fast_forward 
for
select 
LogicalName, originalPath, 
case when PhysicalName like '%.%' then 
		substring(PhysicalName, 1, charindex('.',PhysicalName)-1) else PhysicalName end PhysicalName,
case when PhysicalName like '%.%' then 
		reverse(substring(reverse(PhysicalName), 1, charindex('.',reverse(PhysicalName)))) else 'no_ext' end ext,
		type
from (
select LogicalName, type,
reverse(substring(reverse(PhysicalName), charindex('\',reverse(PhysicalName)),len(PhysicalName))) OriginalPath, 
reverse(substring(reverse(PhysicalName), 1, charindex('\',reverse(PhysicalName))-1)) PhysicalName
from @filelistonly)a

declare dbfiles_cursor_groups cursor fast_forward 
for
select 
LogicalName, replace([location],';',''), [filename], ext, type
from @filelistonly_groups
order by fileid


set @unique_id = ltrim(rtrim(cast(left(replace(replace(replace(replace(replace(replace(replace(newid(),'A',''),'B',''),'C',''),'D',''),'E',''),'F',''),'-',''),5) as char)))

if (@option_01 + @option_02 + @option_03) = 1
begin
	open dbfiles_cursor
	fetch next from dbfiles_cursor into @logicalname, @originalpath, @physicalname, @ext, @file_type
	while @@fetch_status = 0
	begin

	if @option_01 = 1	
	begin
		if @files_exist > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	else if @option_02 = 1
	begin
		if @files_exist > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	else if @option_03 = 1
	begin
		if @file_type = 'D'
		begin
			if @files_exist_data > 0
			begin
				set @file_move_data = isnull(@file_move_data+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_data+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
			end
			else
			begin
				set @file_move_data = isnull(@file_move_data+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_data+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
			end
		end
		else if @file_type = 'L'
		begin
			if @files_exist_log > 0
			begin
				set @file_move_log = isnull(@file_move_log+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_log+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
			end
			else
			begin
				set @file_move_log = isnull(@file_move_log+',','')+'
				MOVE N'+''''+@logicalname+''''+' TO N'+''''+@restore_loc_log+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
			end
		end
	end
	fetch next from dbfiles_cursor into @logicalname, @originalpath, @physicalname, @ext, @file_type
	end
	close dbfiles_cursor 
	deallocate dbfiles_cursor 
end
else if @option_04 = 1
begin
	open dbfiles_cursor_groups
	fetch next from dbfiles_cursor_groups into @logicalname, @originalpath, @physicalname, @ext, @file_type
	while @@fetch_status = 0
	begin
	if @option_04 = 1
	begin
		if @files_exist_data > 0
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+'__'+@unique_id+case @ext when 'no_ext' then '' else @ext end+''''
		end
		else
		begin
			set @file_move = isnull(@file_move+',','')+'
			MOVE N'+''''+@logicalname+''''+' TO N'+''''+@originalpath+@physicalname+case @ext when 'no_ext' then '' else @ext end+''''
		end
	end
	fetch next from dbfiles_cursor_groups into @logicalname, @originalpath, @physicalname, @ext, @file_type
	end
	close dbfiles_cursor_groups 
	deallocate dbfiles_cursor_groups 
end

open backupfiles_cursor 
fetch next from backupfiles_cursor into @Position, @DatabaseName, @BackupType
while @@fetch_status = 0
begin

if @password = 'default' and (@option_01 + @option_02 + @option_04) = 1 
begin
set @sql = '
RESTORE '+
case when @BackupType in (1,5) then 'DATABASE' when @BackupType in (2) then 'LOG' end+' '+
case when @new_db_name = 'default' then '['+@DatabaseName+']' else '['+@new_db_name+']' end
+'
FROM DISK = N'+''''+@backupfile+''''+'
WITH FILE = '+cast(@Position as varchar)+','+
case when @BackupType = 1 then @file_move+',' else '' end+'
'+case 
when @filenumber  = 'all' and @lastfile = @position then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
when @filenumber != 'all' then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
else 'NORECOVERY' end+', '+case when @backuptype = 1 then case when @replace = 1 then 'Replace, ' else '' end else '' end+
' NOUNLOAD, STATS = '+cast(@percent as varchar)+case when @backuptype = 2 and @log_stopat != 'default' then ', '+@log_stopat else '' end 

end

else if @password = 'default' and @option_03 = 1
begin

set @sql = '
RESTORE '+
case when @BackupType in (1,5) then 'DATABASE' when @BackupType in (2) then 'LOG' end+' '+
case when @new_db_name = 'default' then '['+@DatabaseName+']' else '['+@new_db_name+']' end
+'
FROM DISK = N'+''''+@backupfile+''''+'
WITH FILE = '+cast(@Position as varchar)+','+
case when @BackupType = 1 then @file_move_data+','+@file_move_log+',' else '' end+'
'+case 
when @filenumber  = 'all' and @lastfile = @position then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
when @filenumber != 'all' then 
case when @with_recovery = 1 then 'RECOVERY' else 'NORECOVERY' end
else 'NORECOVERY' end+', '+case when @backuptype = 1 then case when @replace = 1 then 'Replace, ' else '' end else '' end+
' NOUNLOAD, STATS = '+cast(@percent as varchar)+case when @backuptype = 2 and @log_stopat != 'default' then ', '+@log_stopat else '' end 

end

if @action = 1
begin
	print(@sql)
end
else if @action = 2
begin
	exec(@sql)
end
else if @action = 3
begin
	print(@sql)
	exec(@sql)
end

fetch next from backupfiles_cursor into @Position, @DatabaseName, @BackupType
end
close backupfiles_cursor 
deallocate backupfiles_cursor 
set nocount off
end