### Could you please explain why a memory-optimized non-clustered index only supports forward-ordered scans?

Memory-optimized non-clustered indexes in SQL Server are designed to support efficient data retrieval for various types of queries. Here’s how they work and why they only support forward ordered scans:

1. **Structure**: Memory-optimized non-clustered indexes use a structure similar to traditional B-tree indexes but are optimized for in-memory operations. They maintain pointers to the rows in the memory-optimized table, allowing for quick lookups and range scans.

2. **Forward Ordered Scans**: These indexes support forward ordered scans, meaning they can efficiently retrieve rows in the order specified by the index. This is particularly useful for queries that use `ORDER BY` clauses or range predicates (e.g., `BETWEEN`, `<`, `>`).

3. **No Backward Scans**: Unlike traditional disk-based indexes, memory-optimized non-clustered indexes do not support backward scans. This is because the internal structure is optimized for forward traversal, which simplifies the index design and improves performance for the most common query patterns.

4. **Use Cases**: Forward ordered scans are beneficial for:
   - **Range Queries**: Efficiently retrieving rows within a specified range.
   - **Ordered Retrieval**: Returning rows in a specific order without needing an additional sort operation.
   - **Point Lookups**: Quickly finding rows based on equality predicates (e.g., `=`).

Here’s an example to illustrate:

```sql
CREATE TABLE Customers
(
    CustomerID INT NOT NULL PRIMARY KEY NONCLUSTERED,
    Name NVARCHAR(100),
    JoinDate DATETIME
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

CREATE NONCLUSTERED INDEX idx_JoinDate ON Customers (JoinDate);
```

In this example, the `idx_JoinDate` index allows efficient forward ordered scans for queries like:

```sql
SELECT * FROM Customers ORDER BY JoinDate;
SELECT * FROM Customers WHERE JoinDate BETWEEN '2023-01-01' AND '2023-12-31';
```

These queries benefit from the index's ability to quickly traverse the rows in the specified order.
