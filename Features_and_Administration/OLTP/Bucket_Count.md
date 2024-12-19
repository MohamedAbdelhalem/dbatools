Does bucket_count need me to monitor if the number was exceeded and how to maintain it?

Yes, monitoring the `BUCKET_COUNT` for hash indexes on memory-optimized tables is important to ensure optimal performance. Here’s what you need to know:

1. **Initial Setting**: When you create a hash index, you specify the `BUCKET_COUNT`, which ideally should be set to 1-2 times the number of distinct values in the index key This helps minimize hash collisions and maintain efficient data access.

2. **Monitoring**: Over time, as your data grows, the number of distinct values might exceed the initial `BUCKET_COUNT`. You can monitor the health of your hash indexes using the `sys.dm_db_xtp_hash_index_stats` dynamic management view (DMV). This view provides statistics such as the total bucket count, empty bucket count, average chain length, and maximum chain length.

3. **Adjusting `BUCKET_COUNT`**: If you notice performance degradation due to high hash collisions (indicated by long chains), you might need to adjust the `BUCKET_COUNT`. Unfortunately, you cannot directly alter the `BUCKET_COUNT` of an existing hash index. Instead, you would need to drop the index and recreate it with a higher `BUCKET_COUNT`.

4. **Best Practices**: Regularly review the performance and statistics of your hash indexes. If your table is expected to grow significantly, consider setting a higher `BUCKET_COUNT` initially to accommodate future growth.

