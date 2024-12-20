## How can I determine the number of deltastores in my columnstore clustered index?

To find out the number of deltastores in your clustered columnstore index, you can query the system catalog views in SQL Server. Specifically, you can use the `sys.column_store_row_groups` view, which provides information about the rowgroups, including deltastores.

Here's a query you can use to get the number of deltastores:

```sql
SELECT 
    object_name(object_id) AS TableName,
    partition_number,
    COUNT(*) AS DeltaStoreCount
FROM 
    sys.column_store_row_groups
WHERE 
    state_description = 'OPEN' -- This indicates deltastores
GROUP BY 
    object_id, partition_number;
```

This query will return the table name, partition number, and the count of deltastores for each partition. The `state_desc = 'OPEN'` condition filters the results to include only the deltastores.
