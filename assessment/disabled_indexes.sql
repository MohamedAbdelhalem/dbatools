SELECT DISTINCT SCHEMA_NAME(a.schema_id) AS 'SchemaName', OBJECT_NAME(a.object_id) AS 'TableName', a.object_id AS 'object_id', b.name AS 'IndexName', b.index_id AS 'index_id', b.type AS 'Type', b.type_desc AS 'IndexType', b.is_disabled AS 'Disabled' 
FROM sys.objects a (NOLOCK) 
JOIN sys.indexes b (NOLOCK) ON b.object_id = a.object_id AND a.is_ms_shipped = 0 
AND a.object_id NOT IN (SELECT major_id FROM sys.extended_properties (NOLOCK) WHERE name = N'microsoft_database_tools_support') 
WHERE b.is_disabled = 1 
ORDER BY 1,2 
