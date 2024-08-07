<details>
<summary>generate_alter_stmt_with_comments_to_unwanted_years.sql</summary>

 I am explaining here the script of **generate_HASH_view_years.sql** and what it can do for you to solve a problem.

an example:
you have a database called **Data_Warehouse_Billing** but this database is very big and you decided to split it into years database let's say:

Databases                    |
---------------------------- |
Data_Warehouse_Billing_2010  |
Data_Warehouse_Billing_2011  |
Data_Warehouse_Billing_2012  |
Data_Warehouse_Billing_2013  |
Data_Warehouse_Billing_2014  |
Data_Warehouse_Billing_2015  |

and so on...

and an ETL will use the main database **Data_Warehouse_Billing** to insert on it instead of inserting individually on each year e.g. **Data_Warehouse_Billing_2023** so you create a multi-views with the same name of the tables but with the below script design

``` SQL

 CREATE VIEW [dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] 
 AS
 SELECT * FROM [Data_Warehouse_Billing_2012].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2013].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2014].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2015].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2016].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2017].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2018].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2019].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2020].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2021].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2022].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2023].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2024].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2025].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_Max].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12]  

```
let's say you have more than **3,000 views** and you need to do some maintenance on some years e.g. **2012, 2013, 2019, 2021, and 2022** and you need to convert the tables into partitions and that will take a big amount of time, so you need to remove these years from the views to not stop the ETL from working.

so the script will generate for you an **ALTER statement** with **commenting out** these years and the generated script will be like the below.

``` SQL
 ALTER VIEW [dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] 
 AS
-- SELECT * FROM [Data_Warehouse_Billing_2012].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
-- SELECT * FROM [Data_Warehouse_Billing_2013].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2014].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2015].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2016].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2017].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2018].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
-- SELECT * FROM [Data_Warehouse_Billing_2019].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2020].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
-- SELECT * FROM [Data_Warehouse_Billing_2021].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
-- SELECT * FROM [Data_Warehouse_Billing_2022].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2023].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2024].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2025].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_Max].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12]   
 ```
</details>
<details>
<summary>grant_view_with_dependencies.sql</summary>

when you have 1 view selecting from multi-databases, and you need to grant selection to these objects in each database automatically, this script can automate these steps.

like this view and you have **+3,000 views** like that.
``` SQL
 CREATE VIEW [dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] 
 AS
 SELECT * FROM [Data_Warehouse_Billing_2012].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2013].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2014].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2015].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2016].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2017].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2018].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2019].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2020].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2021].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2022].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2023].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2024].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_2025].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12] UNION ALL  
 SELECT * FROM [Data_Warehouse_Billing_Max].[dbo].[FENJ_FUNDS_TRANSFER#HIS_M12]  

```
</details>
