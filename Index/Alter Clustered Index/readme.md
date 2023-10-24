If you have an activity to change the data type of the clustered index from int to BIGINT or varchar to Nvarchar, 
Well, to that you have to drop first the clustered index itself but if you have this table of multi-nonclustered indexes and also computed columns, 
So, this altering (the clustered index) will take a huge time if this table has many records with big sizes.
So, to minimize the downtime of this activity regarding this/these table/s to have to do the below steps 

Okay why this activity will take additional time if you don't drop the non-clustered indexes and computed columns (with non-clustered indexes) first:
---------------------------------------------------------------------------------------------------------------------------------------------------------
Because when you drop the clustered index you will convert the table from clustered index to Heap so, 
it will convert the non-clustered indexes for the lookup key from clustered index key to ROWID key every,
then when you finish altering this clustered index key column from int to BIGINT or varchar to Nvarchar 
you will create the clustered index again then you will convert back the table from Heap to clustered index table and then it will rebuild the non-clustered indexes again to change the lookup key from the ROWID key to the new clustered index key

to avoid rebuilding the nonclustered indexes 2 times and do the rebuild 1 time to minimize the downtime, we will do the below steps by achieving the scripts on this folder

1. drop the non-clustered indexes (almost no time 1 or 2 seconds maximum).
2. drop the computed columns if: (almost no time 1 or 2 seconds maximum)
    a. it is touching the CI column like the ID column containing values like idenity_no-financial year-branch id e.g. 123-2324-147854
    b. if the computed columns persist you need to change it to non-persisted.
3. drop the clustered index
4. alter the clustered index key column
5. create again the clustered index 
6. create the computed columns (almost no time 1 or 2 seconds maximum if they are non-persisted)
7. create the non-clustered indexes but if you have an enterprise edition then you can have the ability to use with (online=on) feature to avoid the blocking during the non-clustered index creation.
