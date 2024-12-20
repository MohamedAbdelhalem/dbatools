In SQL Server, a **rowgroup** is a fundamental component of a columnstore index. It is a group of rows that are compressed together into a columnar format. Here are some key points about rowgroups:

1. **Size**: Each rowgroup can contain up to 1,048,576 rows.
2. **Compression**: Data within a rowgroup is compressed together, which reduces storage requirements and speeds up query processing.
3. **States**: Rowgroups can be in different states, such as OPEN, CLOSED, COMPRESSED, or TOMBSTONE:
   - **OPEN**: Accepting new records and still in rowstore format.
   - **CLOSED**: Filled but not yet compressed.
   - **COMPRESSED**: Fully compressed and optimized for query performance.
   - **TOMBSTONE**: All data has been deleted and the rowgroup is marked for removal.

Rowgroups are essential for the performance and efficiency of columnstore indexes, especially in large-scale data warehousing and analytics scenarios.

