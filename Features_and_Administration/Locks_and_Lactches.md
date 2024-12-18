I have a table named 'employees' with 5 pages and there are 3 sessions interacting with these pages. 
For example, SPID 77 wants to read from page 1000, which is not in memory (not cached). 
SPID 78 wants to read pages 1000 and 1001, with page 1001 already cached in the data buffer pool (clean cache). 
Lastly, SPID 79 wants to insert into page 1001 and update page 1002, both of which are not in the buffer pool.

Can you provide examples of the roles of latches and locks, as well as the types of locks and latches used in this scenario?

Let's break down the scenario with the three sessions (SPIDs) and see how latches and locks come into play:

### Scenario Breakdown

1. **SPID 77**: Wants to read from page 1000, which is not in memory.
2. **SPID 78**: Wants to read pages 1000 and 1001. Page 1001 is already in the buffer pool (clean cache).
3. **SPID 79**: Wants to insert into page 1001 and update page 1002, both of which are not in the buffer pool.

### Latches and Locks in Action

#### SPID 77 (Reading Page 1000)
- **Latch**: Since page 1000 is not in memory, SQL Server will need to load it from disk. It will acquire a **PAGEIOLATCH_SH** (shared I/O latch) to read the page into the buffer pool.
- **Lock**: Once the page is in memory, SPID 77 will acquire a **shared lock (S)** on page 1000 to read the data, ensuring no other transaction can modify it while it's being read.

#### SPID 78 (Reading Pages 1000 and 1001)
- **Latch**:
  - For page 1000 (not in memory), SQL Server will acquire a **PAGEIOLATCH_SH** to load it into the buffer pool.
  - For page 1001 (already in memory), SQL Server will acquire a **PAGELATCH_SH** (shared latch) to ensure the page is not modified while being read.
- **Lock**: SPID 78 will acquire **shared locks (S)** on both pages 1000 and 1001 to read the data.

#### SPID 79 (Inserting into Page 1001 and Updating Page 1002)
- **Latch**:
  - For page 1001 (in memory), SQL Server will acquire a **PAGELATCH_EX** (exclusive latch) to modify the page.
  - For page 1002 (not in memory), SQL Server will acquire a **PAGEIOLATCH_EX** to load it into the buffer pool and then a **PAGELATCH_EX** to modify it.
- **Lock**:
  - For the insert operation on page 1001, SPID 79 will acquire an **exclusive lock (X)** to ensure no other transaction can read or modify the data during the insert.
  - For the update operation on page 1002, SPID 79 will acquire an **exclusive lock (X)** to ensure the data is not read or modified by other transactions during the update.

### Summary of Latches and Locks
- **Latches**: Ensure the consistency and integrity of in-memory structures during physical operations.
  - **PAGEIOLATCH_SH**: For reading pages from disk into memory.
  - **PAGELATCH_SH**: For reading pages already in memory.
  - **PAGEIOLATCH_EX**: For writing pages from disk into memory.
  - **PAGELATCH_EX**: For modifying pages already in memory.
- **Locks**: Ensure transactional consistency and isolation.
  - **Shared Lock (S)**: For reading data.
  - **Exclusive Lock (X)**: For writing or modifying data.

By using both latches and locks, SQL Server ensures that data is read and written safely and consistently, even when multiple sessions are accessing the same pages.

