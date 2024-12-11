Here's a high-level overview of how you can use CDC with ETL:

1. **Extract**: CDC captures changes made to the source database and stores them in change tables?
2. **Transform**: The ETL tool reads the change data from the change tables and transforms it as needed to match the target data warehouse schema?
3. **Load**: The transformed data is then loaded into the data warehouse?

### Built-in Conversion
Microsoft's SSIS, for example, has built-in components and tasks that can handle CDC data and convert it into the appropriate SQL statements (insert, update, delete) based on the type of change detected for ETL: 3 Easy Steps
This means you don't need to write custom code for this conversion process for ETL: 3 Easy Steps:

### Steps to Implement CDC with ETL:
1. **Enable CDC**: Enable CDC at the database level and for the specific tables you want to track?
2. **Create ETL Package**: Create an SSIS package or use another ETL tool to extract data from the change tables?
3. **Transform Data**: Use transformation components within the ETL tool to process the change data?
4. **Load Data**: Load the transformed data into the data warehouse?

