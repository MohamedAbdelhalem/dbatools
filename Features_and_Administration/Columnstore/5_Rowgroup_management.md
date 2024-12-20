## Logically, in the case of a columnstore index, when I reach 1,048,576 rows, the tuple mover will compress and close the rowgroup. However, what happens when the rows in the rowgroup are below 1,048,576? Are they compressed or not, and are the columns split into segments or not?

When a rowgroup in a columnstore index has fewer than 1,048,576 rows, it can still be compressed, but the behavior depends on the specific circumstances:

1. **Compression of Smaller Rowgroups**: If a rowgroup has fewer than 1,048,576 rows, it can still be compressed by the tuple mover. This often happens during index creation or rebuild operations, where all rows are compressed regardless of the rowgroup size.

2. **Residual Rowgroups**: These are rowgroups that contain fewer than 1,048,576 rows and are compressed. They are typically the result of the final batch of rows during a bulk load or an index rebuild.

3. **Segments Creation**: Even if a rowgroup has fewer than 1,048,576 rows, the columns within that rowgroup are still split into segments. Each segment corresponds to a column in the rowgroup and is compressed to optimize storage and query performance.

4. **Performance Considerations**: While smaller rowgroups can be compressed, having many small rowgroups can negatively impact the performance and compression efficiency of the columnstore index. Therefore, it's generally better to have larger rowgroups.

### Example Scenario
- **Bulk Load**: If you bulk load 500,000 rows, these rows will form a single rowgroup that is compressed and stored in columnar format.
- **Regular Inserts**: If you insert rows in smaller batches, they will initially go into the deltastore. Once the deltastore accumulates enough rows (typically around 102,400), the tuple mover will compress these rows into a columnstore format, even if the resulting rowgroup is smaller than 1,048,576 rows.

