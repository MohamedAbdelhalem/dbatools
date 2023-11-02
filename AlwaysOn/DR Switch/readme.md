You have a planned activity to switch to the DR site and you need to failover to node 1 in DR.

nodes|node_type|type_id|replica_server|replica_server_ip
-----|---------|-------|--------------|----------------
1|Prod|1|D1SQLDBPrWV1|172.10.20.1
2|Prod|2|D1SQLDBPrWV2|172.10.20.2
3|DR|1|D2SQLDBDrWV1|10.55.20.1
4|DR|2|D2SQLDBDrWV2|10.55.20.2

Then you have to do the below 4 steps using the above scripts:

#|script name|description
-|-----------|-----------
1| Change_syncronization_mode.sql| Make node 2 **asynchronous** and nodes 3 and 4 **synchronous**.
2| Failover_to_Node_3.sql| Failover to node 3.
3| Change_Vote_for_all_Nodes.sql| Change the Vote on nodes (1,2) = 0, nodes (3,4) = 1.
4| Change_Node_1_Async.sql| Make node 1 **asynchronous**.


