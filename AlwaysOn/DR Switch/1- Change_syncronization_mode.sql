--Node 2
ALTER AVAILABILITY GROUP [ag_SQLApp] MODIFY REPLICA ON 'D1SQLDBPrWV2' WITH ( AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)
go
--Node 3
ALTER AVAILABILITY GROUP [ag_SQLApp] MODIFY REPLICA ON 'D2SQLDBDrWV1' WITH ( AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)
go
--Node 4
ALTER AVAILABILITY GROUP [ag_SQLApp] MODIFY REPLICA ON 'D2SQLDBDrWV2' WITH ( AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)

