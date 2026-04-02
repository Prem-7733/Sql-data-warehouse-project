-- Explore all the objects in the database --

select * from information_schema.tables;

-- Explore all the objects in the database --

select * from information_schema.columns
where table_name = 'dim_customers';
