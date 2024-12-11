In Change Data Capture (CDC) in SQL Server, the modification time for each statement (insert, update, or delete) can be tracked using the `__$start_lsn` and `__$end_lsn` columns in the CDC change tables.

### Explanation of Columns:
- **`__$start_lsn`**: This column contains the log sequence number (LSN) at the start of the change.
- **`__$end_lsn`**: This column contains the LSN at the end of the change (for committed transactions).

To convert these LSN values into datetime values, you can use the system function `sys.fn_cdc_map_lsn_to_time`. This function maps an LSN to its corresponding datetime value.

### Example:
Here’s an example of how you can use `sys.fn_cdc_map_lsn_to_time` to get the modification datetime for changes captured by CDC:

```sql
SELECT 
    *,
    sys.fn_cdc_map_lsn_to_time(__$start_lsn) AS ChangeStartTime,
    sys.fn_cdc_map_lsn_to_time(__$end_lsn) AS ChangeEndTime
FROM 
    cdc.dbo_YourTableName_CT
```

This query will give you the datetime values for when each change started and ended, corresponding to the captured changes in the CDC change table `cdc.dbo_YourTableName_CT`.

### Steps:
1. **Query the CDC change table**: Retrieve the change data, including the `__$start_lsn` and `__$end_lsn` columns.
2. **Map LSN to Datetime**: Use `sys.fn_cdc_map_lsn_to_time` to convert the LSN values to datetime values.

By using this approach, you can get the exact modification times for each data change tracked by CDC.
