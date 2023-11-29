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

Now `dbo.Orders_Header` table is a heap and will use the `*Read Committed Isolation*` Level to execute the below query.

```SQL
Select Order_id, Order_Date, Total_Amount
From dbo.Order_Header
Where Customer_id = 344;
```
and this is the result 
1. full scan
2. acquire a lock and release it immediately.

 ![alt text](https://github.com/MohamedAbdelhalem/dbatools/blob/main/Wait/Heap_full_scan.png)
