--about range right or left it has a simple difference between these two options
--if we choose right partition 1 will be empty or has the previous values
--if we choose left partition 1 will have values start of that

--let say multi examples

--1. datetime partition key
--RIGHT
CREATE PARTITION FUNCTION [PARTITION_F_YEARS_RIGHT](INT)
AS
RANGE RIGHT FOR VALUES (
2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 
2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 
2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 
2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031);

--for this partition function 
--partition 1 will have values < 2000
--partition 2 will have values = 2000
--partition 3 will have values = 2001
--partition 4 will have values = 2002
--and so on

--so in this case if you desire to truncate Year 2020 
--you will use partiton number 22

TRUNCATE TABLE [dbo].[PARTITION_TABLE] WITH (PARTITIONS (22));

--LEFT 
CREATE PARTITION FUNCTION [PARTITION_F_YEARS_RIGHT](INT)
AS
RANGE LEFT FOR VALUES (
2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 
2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 
2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 
2024, 2025, 2026, 2027, 2028, 2029, 2030, 2031);

--for this partition function 
--partition 1 will have values<= 2000
--partition 2 will have values = 2001
--partition 3 will have values = 2002
--partition 4 will have values = 2003
--partition 5 will have values = 2004
--and so on

--so in this case if you desire to truncate Year 2020 
--you will use partiton number 21

TRUNCATE TABLE [dbo].[PARTITION_TABLE] WITH (PARTITIONS (21));
