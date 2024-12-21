In earlier versions of SQL Server, the Redo phase on the secondary replica was handled by a `single thread per database`, which performed the redo operations serially. However, with advancements in SQL Server, particularly from `SQL Server 2016 onwards`, the redo model has been enhanced to support `multiple parallel redo worker threads per database`. This improvement allows the redo workload to be shared across multiple threads, significantly improving performance and efficiency.

Each database can now utilize multiple threads during the Redo phase, `with one thread per NUMA node`. This parallel redo model helps in better utilizing the available CPU resources and reduces the time required for the redo operations on the secondary replica.

https://techcommunity.microsoft.com/blog/sqlserver/sql-server-20162017-availability-group-secondary-replica-redo-model-and-performa/385905


In SQL Server, during the Redo phase on the secondary replica, the redo model can utilize multiple parallel redo worker threads per database. These threads are allocated one per NUMA node. The threads are assigned based on `**Physical NUMA nodes**` rather than Soft-NUMA nodes.

Soft-NUMA is a logical partitioning of CPUs within a `physical NUMA` node to improve scalability and performance, but the redo threads are aligned with the `physical NUMA` configuration to ensure optimal performance and resource utilization.
