# Does "open" in the state_description column of sys.column_store_row_groups mean it is not compressed?

You are correct. In the `sys.column_store_row_groups` view, the `state_description` column indicates the state of each rowgroup. When the `state_description` is **OPEN**, it means that the rowgroup is still in a rowstore format and is accepting new records. It has not yet been compressed into the columnstore format.

Here are the possible states for a rowgroup:

- **OPEN**: The rowgroup is accepting new records and is in rowstore format.
- **CLOSED**: The rowgroup has been filled but not yet compressed by the tuple mover process.
- **COMPRESSED**: The rowgroup has been filled and compressed into the columnstore format.
- **INVISIBLE**: A hidden compressed segment in the process of being built from data in a delta store.
- **TOMBSTONE**: The rowgroup was formerly in the deltastore and is no longer used¹.

So, an **OPEN** rowgroup is indeed not compressed and is still in the rowstore format.
