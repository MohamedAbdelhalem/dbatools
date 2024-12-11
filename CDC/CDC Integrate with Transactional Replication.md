CDC (Change Data Capture) can be integrated with transactional replication, but they serve different purposes and are typically used together in complementary ways rather than as a direct integration.

### How They Work Together:
1. **CDC for Real-Time Data Capture**: CDC captures changes made to the source database in real-time or near real-time and stores them in change tables.
2. **Transactional Replication for Data Replication**: Transactional replication uses the captured changes to replicate data from the source database to one or more destination databases.

### Benefits of Using CDC with Transactional Replication:
- **Reduced Data Volume**: CDC ensures that only the changes (inserts, updates, deletes) are captured and replicated, reducing the amount of data transferred and improving performance.
- **Real-Time Data Synchronization**: By combining CDC with transactional replication, you can achieve real-time or near real-time data synchronization between the source and destination databases.
- **Minimized Impact on Source Database**: Since CDC captures changes incrementally, it minimizes the impact on the source database's performance.
