;WITH TargetData(Data, File_Name, File_Offset)
AS
(
  SELECT CONVERT(xml,event_data) AS Data, file_name, file_offset
  FROM
    sys.fn_xe_file_target_read_file
      ('c:\extevents\Expensive Queries*.xel',NULL,NULL,NULL)
)
,EventInfo([Event],[Event Time],[DB],[Statement],[SQL],[User Name]
    ,[Client],[App],[CPU Time],[Duration],[Logical Reads]
    ,[Physical Reads],[Writes],[Rows],[PlanHandle]
    ,File_Name,File_Offset)
as (
  SELECT
    Data.value('/event[1]/@name','sysname') AS [Event]
    ,Data.value('/event[1]/@timestamp','datetime') AS [Event Time]
    ,Data.value('((/event[1]/data[@name="database_id"]/value/text())
[1])','INT')
        AS [DB]
    ,Data.value('((/event[1]/data[@name="statement"]/value/text())
[1])'
        ,'nvarchar(max)') AS [Statement]
    ,Data.value('((/event[1]/data[@name="sql_text"]/value/text())
[1])'
        ,'nvarchar(max)') AS [SQL]
    ,Data.value('((/event[1]/data[@name="username"]/value/text())
[1])'
        ,'nvarchar(255)') AS [User Name]
,Data.value('((/event[1]/data[@name="client_hostname"]/value/text())
[1])'
        ,'nvarchar(255)') AS [Client]
,Data.value('((/event[1]/data[@name="client_app_name"]/value/text())
[1])'
        ,'nvarchar(255)') AS [App]
    ,Data.value('((/event[1]/data[@name="cpu_time"]/value/text())
[1])'
        ,'bigint') AS [CPU Time]
    ,Data.value('((/event[1]/data[@name="duration"]/value/text())
[1])'
        ,'bigint') AS [Duration]
,Data.value('((/event[1]/data[@name="logical_reads"]/value/text())
[1])'
        ,'int') AS [Logical Reads]
 
,Data.value('((/event[1]/data[@name="physical_reads"]/value/text())
[1])'
        ,'int') AS [Physical Reads]
    ,Data.value('((/event[1]/data[@name="writes"]/value/text())[1])'
        ,'int') AS [Writes]
    ,Data.value('((/event[1]/data[@name="row_count"]/value/text())
[1])'
        ,'int') AS [Rows]
    ,Data.value(
'xs:hexBinary(((/event[1]/action[@name="plan_handle"]/value/text())
[1]))'
            ,'varbinary(64)') AS [PlanHandle]
    ,File_Name
    ,File_Offset
  FROM
TargetData )
SELECT
  ei.*, qp.Query_Plan
FROM
  EventInfo ei
    OUTER APPLY sys.dm_exec_query_plan(ei.PlanHandle) qp
OPTION (MAXDOP 1, RECOMPILE);
