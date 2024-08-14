--Create this table first to save the patches result fro any table
CREATE TABLE DML_DATA_COLLECTION 
   (	
	GID NUMBER, 
	SchemaName VARCHAR2(400), 
	TableName VARCHAR2(400), 
	ColumnName VARCHAR2(400), 
	FROM_VALUE VARCHAR2(400), 
	TO_VALUE VARCHAR2(400), 
	TABLE_TOTAL_ROWS NUMBER, 
	ROWS_PER_PATCH NUMBER, 
	DML_SCRIPT VARCHAR2(4000)
   );
/

--parameters
declare 
dml_operation	varchar2(100) := 'delete';
--Expected values for DML Operations
--Delete
--Select COUNT(*)
--Select COUNT
--Insert
bulk		number := 1000; -- the actual number or rows per patch.
using_CI	number := 1; --this parameter means it will automatically use the cluster index column.
--When a clustered index key column is not utilized and no alternative is available, use a standard column as the subsequent option.
--then use a Non-clustered index column BUT THIS COLUMN MUST BE UNIQUE 
--e.g. 
--[NUMBER] with Identity
--[DATE] with default sysdate  
enable_search   number := 0; --place here "1" to apply the where_condition parameter below.
where_condition varchar2(999) := 'Where SalesOrderID between 46659 and 64600';
column_name	varchar2(255) := 'OrderDate'; 
column_type	varchar2(255) := 'DATE';
source_db	varchar2(355);
source_table	varchar2(355) := 'SalesOrderHeader';
destinationDB	varchar2(355) := 'AdventureWorks2019';
destinationTB	varchar2(355) := 'SalesOrderHeader';

--variables
sqlscript	varchar2(8000);
all_columns	varchar2(8000);
v_column        varchar2(255) := '';
col_cursor 	SYS_REFCURSOR;
cur_select 	varchar2(999) := 'select column_name from user_tab_columns where table_name = upper(';
begin

select user into source_db from dual;

OPEN col_cursor FOR cur_select||''''||source_table||''''||') order by column_id';
loop fetch col_cursor into v_column;
exit when  col_cursor%notfound;
all_columns := NVL(all_columns||',',' ')||v_column;
end loop;
close col_cursor;

all_columns := substr(all_columns,instr(all_columns,',')+1,length(all_columns)-instr(all_columns,','));
--dbms_output.put_line(all_columns);

if dml_operation in ('delete','select *','select count(*)')
then
    if using_CI = 1
    then
        select
        c.column_name, c.data_type INTO column_name, column_type  
        from user_indexes i, user_tables t, user_tab_columns c, user_ind_columns ic 
        where i.table_name = t.table_name
        and t.table_name = c.table_name
        and t.table_name = ic.table_name
        and c.column_name = ic.column_name
        and t.table_name = upper(source_table)
        and ic.column_position = 1;
    end if;
end if;
if dml_operation in ('insert') and destinationTB != 'default' and destinationDB != 'default'
then
    if using_CI = 1
    then
        select
        c.column_name, c.data_type INTO column_name, column_type  
        from user_indexes i, user_tables t, user_tab_columns c, user_ind_columns ic 
        where i.table_name = t.table_name
        and t.table_name = c.table_name
        and t.table_name = ic.table_name
        and c.column_name = ic.column_name
        and t.table_name = upper(source_table)
        and ic.column_position = 1;
    end if;
end if;

sqlscript := 'INSERT INTO DML_DATA_COLLECTION 
SELECT GID, 
'||''''||source_db||''''||','||''''||source_table||''''||','||''''||column_name||''''||',
'||case 
when column_type in ('DATE') then 'TO_CHAR(MIN(dataValues),''YYYY-MM-DD HH24:MI:SS'')' 
when column_type in ('NUMBER') then 'MIN(dataValues)'
end||' From_'||column_name||', 
'||case 
when column_type in ('DATE') then 'TO_CHAR(MAX(dataValues),''YYYY-MM-DD HH24:MI:SS'')' 
when column_type in ('NUMBER') then 'MAX(dataValues)'
end||' To_'||column_name||', 
TO_CHAR(SUM(COUNT(*)) over(), ''99G999G999G9999'') Table_total_rows, 
TO_CHAR(COUNT(*), ''99G999G999G9999'') Rows_per_patch, '||case 
when column_type in ('NUMBER') then 
''''||case dml_operation when 'insert' then 'INSERT INTO '||destinationDB||'.'||destinationTB||' ('||all_columns||') 
SELECT '||all_columns else dml_operation end||
' FROM '||source_db||'.'||source_table||' WHERE '||column_name||' BETWEEN ''||TO_CHAR(MIN(DATAVALUES))||'' AND ''||TO_CHAR(max(DATAVALUES))||'''' DML_SCRIPT'
when column_type in ('DATE') then 
''''||case dml_operation when 'insert' then 'INSERT INTO '||destinationDB||'.'||destinationTB||' ('||all_columns||') 
SELECT '||all_columns else dml_operation end||
' FROM '||source_db||'.'||source_table||' WHERE '||column_name||' BETWEEN TO_DATE(''||''''''''||TO_CHAR(MIN(DATAVALUES),''YYYY-MM-DD HH24:MI:SS'')||''''''''||'',''''YYYY-MM-DD HH24:MI:SS'''') AND TO_DATE(''||''''''''||TO_CHAR(MAX(DATAVALUES),''YYYY-MM-DD HH24:MI:SS'')||''''''''||'',''''YYYY-MM-DD HH24:MI:SS'''')'' DML_SCRIPT'
else
''''||case dml_operation when 'insert' then 'INSERT INTO '||destinationDB||'.'||destinationTB||' ('||all_columns||') 
SELECT '||all_columns else dml_operation end||
' FROM '||source_db||'.'||source_table||' WHERE '||column_name||' BETWEEN ''||''''''''||TO_CHAR(MIN(DATAVALUES))||''''''''||'' AND ''||''''''''||TO_CHAR(max(DATAVALUES))||''''''''||'''' DML_SCRIPT'
end ||'
FROM (
SELECT 
CEIL(ROW_NUMBER() OVER(ORDER BY '||column_name||')/ ('||to_char(bulk)||' * 1.000000001)) GID, 
'||column_name||' DATAVALUES 
FROM '||source_table||'
'||case when enable_search = 0 then '' else where_condition end||')a
GROUP BY GID
ORDER BY GID';

dbms_output.put_line(sqlscript);
EXECUTE IMMEDIATE sqlscript;
COMMIT;
end;
/

--TRUNCATE TABLE DML_DATA_COLLECTION 
--select * from DML_DATA_COLLECTION 


