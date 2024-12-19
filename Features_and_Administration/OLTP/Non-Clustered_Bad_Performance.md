Bad performance on a memory-optimized non-clustered index can occur under several conditions. Here are some common scenarios and their causes:

1. **Inefficient Query Patterns**: If your queries are not well-suited to the index structure, performance can suffer. For example, non-clustered indexes are optimized for forward ordered scans. Queries that require backward scans or complex joins might not perform well.

2. **High Data Modification Rates**: Memory-optimized tables are designed for high-performance data access, but if there are frequent inserts, updates, or deletes, the overhead of maintaining the non-clustered index can impact performance. This is especially true if the index is on a column with high cardinality (many unique values).

3. **Suboptimal Index Design**: If the index is not designed to match the query patterns, it can lead to poor performance. For example, if the index does not cover the columns used in the query's `WHERE` clause or `ORDER BY` clause, SQL Server might not use the index efficiently.

4. **Memory Pressure**: Memory-optimized tables and indexes rely on available memory. If your system is under memory pressure, performance can degrade. This can happen if there are too many memory-optimized objects or if other processes are consuming significant memory.

5. **Fragmentation**: Although memory-optimized indexes do not suffer from traditional fragmentation, they can still experience performance issues if the data distribution is uneven. Monitoring and adjusting the index design can help mitigate this.

6. **Concurrency Issues**: High levels of concurrent access can lead to contention, especially if the index is on a column that is frequently updated. This can cause performance bottlenecks.

To troubleshoot and mitigate these issues, consider the following steps:

- **Analyze Query Plans**: Use SQL Server Management Studio (SSMS) to view the actual execution plans of your queries. This can help identify if the index is being used effectively or if there are any bottlenecks.

- **Monitor Index Statistics**: Regularly check the performance statistics of your indexes using DMVs like `sys.dm_db_xtp_index_stats` and `sys.dm_db_xtp_hash_index_stats`.

- **Optimize Index Design**: Ensure that your indexes are designed to match your query patterns. Consider adding covering indexes or adjusting existing indexes to better support your workload²(https://techcommunity.microsoft.com/blog/sqlserver/in-memory-oltp-indexes---part-2-performance-troubleshooting-guide-/385725).

- **Manage Memory**: Monitor memory usage and ensure that your system has enough memory to support your memory-optimized tables and indexes.
