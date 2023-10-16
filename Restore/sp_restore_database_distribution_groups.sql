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
go

