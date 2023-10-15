WITH ResourceMonitorCte
AS (
           -- select & run this query for a list of records in the queue
    SELECT ROW_NUMBER() OVER (ORDER BY Buffer.Record.value( '@time', 'BIGINT' )
                                     , Buffer.Record.value( '@id', 'BIGINT' ) ) AS [RowNumber]
         , Data.ring_buffer_type AS [Type]
         , Buffer.Record.value( '(ResourceMonitor/Notification)[1]', 'NVARCHAR(128)' ) AS [ResourceNotification]
         , Buffer.Record.value( '@time', 'BIGINT' ) AS [time]
         , Buffer.Record.value( '@id', 'BIGINT' ) AS [Id]
         , Data.EventXML
    FROM (SELECT CAST(Record AS XML) AS EventXML
               , ring_buffer_type
          FROM sys.dm_os_ring_buffers
          WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS Data
    CROSS APPLY EventXML.nodes('//Record') AS Buffer(Record)
   )
SELECT first.[Type]
     , summary.[ResourceNotification]
            , summary.[count]
     , --DATEADD( second
       --        , first.[Time] - info.ms_ticks /1000.0
       --        , CURRENT_TIMESTAMP ) AS [FirstTime],
      --DATEADD( second
       --        , cast(last.[Time] as bigint) - cast(info.ms_ticks  as bigint) / (1000.0 + .0001)
       --        , CURRENT_TIMESTAMP ) AS [LastTime],
      first.EventXML AS [FirstRecord]
     , last.EventXML AS [LastRecord]
FROM (SELECT [ResourceNotification]
           , COUNT(*) AS [count]
           , MIN(RowNumber) AS [FirstRow]
           , MAX(RowNumber) AS [LastRow]
      FROM ResourceMonitorCte
      GROUP BY [ResourceNotification] ) AS summary
JOIN ResourceMonitorCte AS first
ON first.RowNumber = summary.[FirstRow]
JOIN ResourceMonitorCte AS last
ON last.RowNumber = summary.[LastRow]
CROSS JOIN sys.dm_os_sys_info AS info
ORDER BY [ResourceNotification]; 