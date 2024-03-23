CREATE EVENT SESSION [Expensive Queries]
ON SERVER
ADD EVENT
    sqlserver.sql_statement_completed
    (
ACTION (
            sqlserver.client_app_name
            ,sqlserver.client_hostname
            ,sqlserver.database_id
            ,sqlserver.plan_handle
            ,sqlserver.sql_text
 
            ,sqlserver.username
        )
WHERE (
            (
                cpu_time >= 3000000 or -- Time in microseconds
                logical_reads >= 10000 or
                writes >= 10000
) AND
            sqlserver.is_system = 0
        )
), ADD EVENT
    sqlserver.rpc_completed
    (
ACTION (
            sqlserver.client_app_name
            ,sqlserver.client_hostname
            ,sqlserver.database_id
            ,sqlserver.plan_handle
            ,sqlserver.sql_text
            ,sqlserver.username
) WHERE (
            (
                cpu_time >= 3000000 or
                logical_reads >= 10000 or
                writes >= 10000
) AND
            sqlserver.is_system = 0
        )
)
ADD TARGET
    package0.event_file
    (
        SET FILENAME = 'c:\ExtEvents\Expensive Queries.xel'
    )
WITH (
        ,max_dispatch_latency=30 seconds
    );
