USE master
GO
DECLARE 
    @DatabaseName NVARCHAR(255),
    @database_id int,
    @SQLStmt NVARCHAR(1000)
 
--check if temp tables exists
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE name like '#dbloginfo1%')
    DROP TABLE #dbloginfo1
 
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE name like '#VLF_Info1%')
    DROP TABLE #VLF_Info1
-- create required temp tables
 
create table #dbloginfo1
(
RecoveryUnitId INT,
FileId  INT,    
FileSize  BIGINT,          
StartOffset BIGINT,        
FSeqNo  INT,  
Status  INT,
Parity INT,
CreateLSN NVARCHAR(25)
)
 
CREATE TABLE #VLF_Info1
(
database_id INT
,[FILE_ID] INT    
,database_name NVARCHAR(255)    
,Log_Filename NVARCHAR(255)                          
,File_Size_in_MB REAL
,next_growth_in_MB REAL  
,Number_VLF  INT
,Number_VLF_For_reuse INT
,Min_Number_VLF INT
,new_VLFs_by_Autogrowth INT
,new_VLFs_avg_size REAL
,Min_VLF_Size REAL
,Max_VLF_SIZE REAL
,AVG_VLF_Size REAL
)
 
--create cursor to loop through all databases
DECLARE databases_cursor CURSOR FOR
SELECT database_id, name
FROM  sys.databases 
WHERE database_id>4
 
OPEN databases_cursor;
 
FETCH NEXT FROM databases_cursor INTO @database_id, @DatabaseName;
 
WHILE @@FETCH_Status = 0
  BEGIN
        -- collect log info
    
        --For SQL Server 2016 SP1 or earlier
        SET @SQLStmt='dbcc loginfo ([' + @DatabaseName + '])'
        
        --For SQL Server 2016 SP2 or later
        --SELECT 0 RecoveryUnitId, FILE_ID AS FileId, vlf_size_mb AS FileSize, vlf_begin_offset AS StartOffset, vlf_sequence_number AS FSeqNo, vlf_Status AS Status, vlf_parity AS Parity, vlf_create_lsn AS CreateLSN
        --FROM sys.dm_db_log_info(@database_id)
 
        INSERT #dbloginfo1 EXEC (@SQLStmt)
 
        INSERT INTO  #VLF_Info1
        (
            database_id
            ,[FILE_ID]    
            ,database_name  
            ,Log_Filename                          
            ,File_Size_in_MB
            ,next_growth_in_MB  
            ,Number_VLF 
            ,Min_VLF_Size
            ,Max_VLF_SIZE
            ,AVG_VLF_Size
        )
        SELECT 
            mf.database_id, 
            mf.[FILE_ID]
            ,db_name(mf.database_id) AS database_name, 
            mf.name AS Log_Filename, 
            CASE WHEN mf.is_percent_growth = 1 THEN CAST((mf.size*8) AS REAL) /1024 
            ELSE 0 END as File_Size_in_MB,  
            CASE WHEN mf.is_percent_growth = 1 THEN CAST((mf.size*8*mf.growth) AS REAL)/100/1024  
            ELSE CAST((8*mf.growth) AS FLOAT)/1024 END AS next_growth_in_MB
            ,li.Number_VLF
            ,li.Min_VLF_Size
            ,li.Max_VLF_SIZE
            ,li.AVG_VLF_Size
        FROM sys.master_files mf
        INNER JOIN (SELECT 
            @DatabaseName AS database_name
            , FileId
            , count(*) AS  Number_VLF
            , min(FileSize) AS Min_VLF_Size
            , max(FileSize) AS Max_VLF_SIZE
            , avg(FileSize) AS AVG_VLF_Size
            FROM #dbloginfo1 GROUP BY FileId) li
        ON db_name(mf.database_id)=li.database_name AND mf.[FILE_ID]=li.FileId
        WHERE 
           type_desc='LOG'
        -- update info based on collected data
        IF Cast(left(cast(serverproperty('productversion') AS NVARCHAR(20)),2) AS INT)<12
          BEGIN
                UPDATE #VLF_Info1 
                SET 
                    Min_Number_VLF = CASE  WHEN File_Size_in_MB < 64 THEN 4 WHEN File_Size_in_MB  > 1024 THEN 16 ELSE 8 END
                    ,new_VLFs_by_Autogrowth=CASE WHEN next_growth_in_MB < 64 THEN 4 WHEN next_growth_in_MB  > 1024 THEN 16 ELSE 8 END
                    ,Number_VLF_For_reuse=(SELECT count(*) FROM #dbloginfo1 WHERE Status=0  AND [FILE_ID]=#dbloginfo1.FileId GROUP BY FileId) 
                WHERE db_name(database_id)=@DatabaseName
 
                UPDATE #VLF_Info1 
                SET 
                    new_VLFs_avg_size=next_growth_in_MB/new_VLFs_by_Autogrowth
                WHERE db_name(database_id)=@DatabaseName
            END
        ELSE
          BEGIN
                UPDATE #VLF_Info1 
                SET 
                    Min_Number_VLF = CASE WHEN File_Size_in_MB < 64 THEN 4 WHEN File_Size_in_MB  > 1024 THEN 16 ELSE 8 END
                    ,new_VLFs_by_Autogrowth=CASE WHEN next_growth_in_MB = 0 THEN 0 ELSE CASE WHEN File_Size_in_MB/next_growth_in_MB > 8 THEN 1 ELSE CASE WHEN next_growth_in_MB < 64 THEN 4 WHEN next_growth_in_MB > 1024 THEN 16 ELSE 8 END END END
                    ,Number_VLF_For_reuse=(SELECT count(*) FROM #dbloginfo1 WHERE Status=0  AND [FILE_ID]=#dbloginfo1.FileId GROUP BY FileId) 
                WHERE db_name(database_id)=@DatabaseName
 
                UPDATE #VLF_Info1 
                SET 
                    new_VLFs_avg_size=CASE WHEN new_VLFs_by_Autogrowth = 0 THEN 0 ELSE next_growth_in_MB/new_VLFs_by_Autogrowth END 
                WHERE db_name(database_id)=@DatabaseName
            END
        -- empty temp table for reuse for next database
        TRUNCATE TABLE #dbloginfo1
 
        FETCH NEXT FROM databases_cursor INTO @database_id, @DatabaseName;
    END
 
CLOSE databases_cursor;
 
DEALLOCATE databases_cursor;
 
-- display results
SELECT
    database_id
    ,[FILE_ID]    
    ,database_name    
    ,Log_Filename                          
    ,File_Size_in_MB
    ,next_growth_in_MB  
    ,Number_VLF 
    ,Number_VLF_For_reuse
    ,Min_Number_VLF
    ,new_VLFs_by_Autogrowth
    ,new_VLFs_avg_size
    ,Min_VLF_Size
    ,Max_VLF_SIZE
    ,AVG_VLF_Size
FROM #VLF_Info1
ORDER BY Number_VLF desc
 
-- drop temp tables
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE name like '#dbloginfo1%')
    DROP TABLE #dbloginfo1
 
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE name like '#VLF_Info1%')
    DROP TABLE #VLF_Info1
