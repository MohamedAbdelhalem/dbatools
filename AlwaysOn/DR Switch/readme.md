You have a planned activity to switch to the DR site and you need to failover to node 1 in DR.

nodes|replica_server|replica_server_ip
----|--------------|---------
1|D1SQLDBPrWV1|172.10.20.1
2|D1SQLDBPrWV2|172.10.20.2
3|D2SQLDBDrWV1|10.55.20.1
4|D2SQLDBDrWV2|10.55.20.2

Then you have to do the below 4 steps using the above scripts:

1. Make node 2 **asynchronous** and nodes 3 and 4 **synchronous**.
2. Failover to node 3.
3. Change the Vote on nodes (1,2) = 0, nodes (3,4) = 1.
4. Make node 1 **asynchronous**.

