## There are two formats in columnstore: deltastore when the state_description value is "OPEN" and rowgroup when the state_description value is "CLOSED" or "COMPRESSED". Is this correct?

You're almost correct, but let's clarify the details:

1. **Deltastore (multi Delta groups)**: 
   - **OPEN**: This state indicates that the rowgroup is in the deltastore and is still in rowstore format. It is accepting new records and has not yet been compressed.

2. **Rowgroup**:
   - **CLOSED**: This state means that the rowgroup has been filled but not yet compressed. It is no longer accepting new records and is waiting to be processed by the tuple mover.
   - **COMPRESSED**: This state indicates that the rowgroup has been compressed into the columnstore format. It is optimized for query performance and storage efficiency.

So, the **OPEN** state corresponds to the deltastore (rowstore format), while the **CLOSED** and **COMPRESSED** states correspond to rowgroups (columnstore format).
