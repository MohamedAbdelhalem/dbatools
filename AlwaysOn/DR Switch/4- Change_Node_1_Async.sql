--Enable SQLCMD mode
:CONNECT 10.55.20.1

ALTER AVAILABILITY GROUP [ag_SQLApp] MODIFY REPLICA ON 'D1SQLDBPrWV1' WITH ( AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)
go
