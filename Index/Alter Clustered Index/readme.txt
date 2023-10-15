If you have an activity to change the data type of the clustered index from int to bigint or varchar to nvarchar, 
Well, to that you have to drop first the clustered index itself but if you have for this table multi-nonclustered indexes and also computed columns, 
So, this altering (the clustered index) will take a huge time if this table has many records with big size.
So, to minimize the downtime of this activity regarding this/these table/s to have to do the below steps 

Okay why this activity will take an additional time if you don't drop the non-clustered indexes and computed columns (with non-clustered indexes) first:
---------------------------------------------------------------------------------------------------------------------------------------------------------
Because when you drop the clustered index you will convert the table from clustered index to Heap so, 
it will convert the non-clustered indexes for the lookup key from clustered index key to rowid key every,
then when you will finish the altering of this clustered index key column from int to bigint or varchar to nvarchar 
you will create the clustered index again then you will convert back the table from Heap to clustered index table and the it will rebuild the non-clustered indexes again to change the lookup key from rowid key to the new clustered index key

to avoid rebuilding the nonclustered indexes 2 times and do the rebuild 1 time to minimize the downtime, then we will do the below steps by achieve the scripts on this folder

1- drop the non-clustered indexes (almost no time 1 or 2 seconds maximum).
2- drop the computed columns if: (almost no time 1 or 2 seconds maximum)
    a. it is touching the CI column like ID column contain values like idenity_no-finantial year-branch id e.g. 123-2324-147854
    b. if the computed columns with persisted and you need to change it to non-persisted.
3- drop the clustered index
4- alter the clustered index key column
5- create again the clustered index 
6- create the computed columns (almost no time 1 or 2 seconds maximum if they are non-persisted)
7- create the non-clustered indexes but if you have enterprise edition then you can have the ability to use with (online=on) feature to avoid the blocking during the non-clustered index creation.
