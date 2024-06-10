ALTER DATABASE AdventureWorks2019 ADD FILEGROUP [fg_filestream01] CONTAINS FILESTREAM;
GO

--in 1 folder
ALTER DATABASE [AdventureWorks2019] ADD FILE 
(NAME = N'Filestream_F01', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\FFS01' ) 
TO FILEGROUP [fg_filestream01];


ALTER DATABASE AdventureWorks2019 ADD FILEGROUP [fg_filestream02] CONTAINS FILESTREAM;
GO
--in multi-folders
exec xp_cmdshell 'Mkdir "C:\MSSQL\DATA\FFS01"'
exec xp_cmdshell 'Mkdir "C:\MSSQL\DATA\FFS02"'
exec xp_cmdshell 'Mkdir "C:\MSSQL\DATA\FFS03"'
exec xp_cmdshell 'Mkdir "C:\MSSQL\DATA\FFS04"'

ALTER DATABASE [AdventureWorks2019] ADD FILE 
(NAME = N'Filestream_F01', FILENAME = N'C:\MSSQL\DATA\FFS02\FSTable'), 
(NAME = N'Filestream_F02', FILENAME = N'C:\MSSQL\DATA\FFS02\FSTable'), 
(NAME = N'Filestream_F03', FILENAME = N'C:\MSSQL\DATA\FFS02\FSTable'), 
(NAME = N'Filestream_F04', FILENAME = N'C:\MSSQL\DATA\FFS02\FSTable') 
TO FILEGROUP [fg_filestream02];




ALTER DATABASE AdventureWorks2019  SET FILESTREAM (NON_TRANSACTED_ACCESS = FULL ,DIRECTORY_NAME = 'Deafult_FILESTREAM_directory');
GO



--Create FileTable
CREATE Table Documents AS FILETABLE WITH (
FileTable_Directory = 'documents', FileTable_Collate_Filename = database_default);
GO

--Powershell.exe ls "\\127.0.0.1\mssqlserver\Deafult_FILESTREAM_directory\documents"
--Copy files to this Directory and then select it to see them in database by run the below query

--if NON_TRANSACTED_ACCESS = FULL then disable allow the snapshot_isolation_state and is_read_committed_snapshot_on to prevent blocking on filetable
--or use table hint WITH (READCOMMITTEDLOCK)

SELECT  
[stream_id],
[file_stream],
[name],
[path_locator],
[parent_path_locator],
[file_type],
[cached_file_size],
[creation_time],
[last_write_time],
[last_access_time],
[is_directory],
[is_offline],
[is_hidden],
[is_readonly],
[is_archive],
[is_system],
[is_temporary]
FROM [AdventureWorks2019].[dbo].[Documents]
WITH (READCOMMITTEDLOCK)
GO

INSERT INTO [AdventureWorks2019].[dbo].[Documents] ([name],[file_stream])
SELECT
'46447150.png', * FROM OPENROWSET(BULK N'C:\documents\46447150.png', SINGLE_BLOB) AS FileData
GO

--create a normal table with filestream column

