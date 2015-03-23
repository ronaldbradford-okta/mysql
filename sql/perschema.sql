################################################################################
# Name     :  perschema.sql
# Purpose  :  List details of the specific schema
# Author   :  Ronald Bradford  http://ronaldbradford.com
# Version  :  2 03-June-2009
################################################################################

SELECT   NOW(), VERSION();

# Per Schema Queries

SET @schema = IFNULL(@schema,DATABASE());

# One Line Schema Summary
SELECT   table_schema,
         SUM(data_length+index_length)/1024/1024 AS total_mb,
         SUM(data_length)/1024/1024 AS data_mb,
         SUM(index_length)/1024/1024 AS index_mb,
         COUNT(*) AS tables,
         CURDATE() AS today
FROM     information_schema.tables
WHERE    table_schema=@schema
GROUP BY table_schema;

# Schema Engine/Collation Summary
SELECT   table_schema,engine,table_collation,
         COUNT(*) AS tables
FROM     information_schema.tables
WHERE    table_schema=@schema
GROUP BY table_schema,engine,table_collation;


# Schema Table Usage
SELECT @schema as table_schema, CURDATE() AS today;
SELECT   if(length(table_name)>20,concat(left(table_name,18),'..'),table_name) AS table_name,
         engine,row_format as format, table_rows, avg_row_length as avg_row,
         round((data_length+index_length)/1024/1024,2) as total_mb, 
         round((data_length)/1024/1024,2) as data_mb, 
         round((index_length)/1024/1024,2) as index_mb
FROM     information_schema.tables 
WHERE    table_schema=@schema
ORDER BY 6 DESC;

# Schema Table BLOB/TEXT Usage
SELECT   table_schema,table_name,column_name,data_type 
FROM     information_schema.columns 
WHERE    table_schema= @schema
AND      ( data_type LIKE '%TEXT' OR data_type like '%BLOB');

# Large varchars
SELECT   table_schema,table_name,column_name,character_maximum_length 
FROM     information_schema.columns 
WHERE    data_type='varchar' 
AND      character_maximum_length > 255 
AND      table_schema = @schema;

SELECT   table_schema,table_name,column_name,data_type,extra 
FROM     information_schema.columns 
WHERE    data_type='bigint' 
AND      extra LIKE '%auto_increment%' 
AND      table_schema = @schema;

SELECT   'routines', COUNT(*) FROM information_schema.routines  WHERE routine_schema= @schema
UNION
SELECT   'views', COUNT(*) FROM information_schema.views WHERE table_schema= @schema
UNION
SELECT   'triggers', COUNT(*) FROM information_schema.triggers WHERE trigger_schema= @schema;

SET @schema = NULL;

