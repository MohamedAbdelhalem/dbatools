# A clustered columnstore index can have multiple deltastores for several reasons:

1. **Concurrent Inserts**: When multiple insert operations occur simultaneously, SQL Server can create multiple deltastores to handle these concurrent operations efficiently. This helps avoid contention and ensures that inserts can proceed without waiting for a single deltastore to be processed.

2. **Partitioning**: If your table is partitioned, each partition can have its own deltastore. This allows for parallel processing and better management of data across different partitions.

3. **Data Distribution**: SQL Server may create additional deltastores to balance the load and optimize performance. This is particularly useful in scenarios with high insert rates or large volumes of data.

4. **Background Processing**: The tuple mover process, which compresses data from the deltastore into the columnstore format, runs periodically. During this time, new inserts can still occur, leading to the creation of new deltastores while the existing ones are being processed.

### Example Scenario
Imagine a high-traffic data warehouse where multiple ETL processes are inserting data into a table with a clustered columnstore index. To handle these concurrent inserts efficiently, SQL Server might create multiple deltastores. As the tuple mover compresses and closes these deltastores, new ones can be created to handle ongoing inserts.

This design ensures that the system remains performant and can handle high volumes of data efficiently.


### so how many deltastores can have 1 clustered index columnstore?

A clustered columnstore index can have multiple deltastores. Each deltastore corresponds to a rowgroup in the **OPEN** state, where new rows are temporarily stored in a rowstore format before being compressed into the columnstore format.

There isn't a strict limit on the number of deltastores a clustered columnstore index can have, but having too many deltastores can impact performance. The tuple mover process periodically compresses these deltastores into columnstore rowgroups to optimize storage and query performance.
