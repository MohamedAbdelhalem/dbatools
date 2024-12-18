# Locks Compatability with each other and with Isolation Levels

locks example for a select statement

Table ***Orders_Header***

Order_id|Order_Date|Customer_id|Total_items|Total_Amount
--------|----------|-----------|-----------|------------
1|10/11/2023|1424|3|234
2|10/12/2023|200|12|433
**3**|**10/12/2023**|**344**|**5**|**555**
4|10/12/2023|1001|9|900
5|10/13/2023|22|3|155
6|10/13/2023|21|2|212
**7**|**10/14/2023**|**344**|**43**|**1044**
**8**|**10/15/2023**|**344**|**10**|**20**
9|10/15/2023|10|1|3000
10|10/16/2023|222|7|299
…|…|…|…|…			

SQL Query against Isolation Levels
```SQL
create table dbo.Orders_Header
(Order_id int, Order_Date datetime, Customer_id int, Total_items int, Total_Amount int)
go

insert into dbo.Orders_Header values 
(1, '10/11/2023', 1424, 3, 234),
(2, '10/12/2023', 200, 12, 433),
(3, '10/12/2023', 344, 5, 555),
(4, '10/12/2023', 1001, 9, 900),
(5, '10/13/2023', 22, 3, 155),
(6, '10/13/2023', 21, 2, 212),
(7, '10/14/2023', 344, 43, 1044),
(8, '10/15/2023', 344, 10, 20),
(9, '10/15/2023', 10, 1, 3000),
(10,'10/16/2023', 222, 7, 299)
```

Now `dbo.Orders_Header` table is a heap and will use the **Read Committed Isolation Level** to execute the below query.

```SQL
Select Order_id, Order_Date, Total_Amount
From dbo.Order_Header
Where Customer_id = 344;
```
and this is the result 
1. full scan
2. acquire a lock and release it immediately.

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/Heap_read_committed.png)

Then now we will try to use **Serializable Isolation Level** with `dbo.Orders_Header` table as it is still a heap.

```SQL
set transaction isolation level Serializable
```

the first thing you will see here is that the RangeS-S lock will not work (Shared Range - Shared) that is the main reason you are using Serializable Read to lock any read or modify, insert, or delete between this range because there is no Index key to get the serial range on it.

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/Heap_serializable_read.png)


but when we add a nonclustered index we can see different figures.

```SQL
create nonclustered index ix_customer_id_orders_header on dbo.Orders_Header (customer_id);
```

```
Set Transaction Isolation Level Read Committed
go
Select Order_id, Customer_id, Order_Date, Total_Amount
From dbo.Orders_Header 
Where Customer_id in (103,1000)
-- just 2 records
```

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/noncluster_index_on_clusterIndexTable_read_committed_covered_query.png)


```
Set Transaction Isolation Level Repeatable Read
go
Select Order_id, Customer_id, Order_Date, Total_Amount
From dbo.Orders_Header 
Where Customer_id in (103,1000)
-- just 2 records
```

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/noncluster_index_on_clusterIndexTable_repeatable_read_covered_query.png)


```
Set Transaction Isolation Level Serializable
go
Select Order_id, Customer_id, Order_Date, Total_Amount
From dbo.Orders_Header 
Where Customer_id in (103,1000)
-- just 2 records
```

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/noncluster_index_on_clusterIndexTable_serializable_covered_query.png)

