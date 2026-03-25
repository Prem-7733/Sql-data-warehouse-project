/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/



SELECT'=============================';

SELECT 'Loading Bronze Layer';

SELECT'=============================';

SELECT'=============================';

SELECT 'Loading CRM TABLE';

SELECT'=============================';

SELECT '>>Truncating Table: bronze.crm_cust_info';

SET @batch_start_time = NOW();

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>>Inserting data into: bronze.crm_cust_info';
LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'crm_cust_info Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');

SELECT '>>Truncating Table: bronze.crm_prd_info';

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_prd_info;

SELECT '>>Inserting data into: bronze.crm_prd_info';

LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'prd_info Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');

SELECT '>>Truncating Table: bronze.crm_sales_details';

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_sales_details;

SELECT '>>Inserting data into: bronze.crm_sales_details';

LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'sales_details Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');




SELECT '>>Truncating Table: bronze.erp_cust_az12';

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>>Inserting data into: bronze.erp_cust_az12';

LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'cust_az12 Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');



SELECT '>>Truncating Table: bronze.erp_loc_a101';

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>>Inserting data into: bronze.erp_loc_a101';

LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT CONCAT(
    'loc_a101 Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');



SELECT '>>Truncating Table: bronze.erp_PX_CAT_G1V2';

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

SELECT '>>Inserting data into: bronze.erp_PX_CAT_G1V2';

LOAD DATA LOCAL INFILE '/Users/premadimalla/Downloads/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_PX_CAT_G1V2
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SET @end_time = NOW();

SET @batch_end_time = NOW();

SELECT CONCAT(
    'PX_CAT_G1V2 Load Time: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' sec');





DELIMITER //

DROP PROCEDURE IF EXISTS bronze.process_bronze;

CREATE PROCEDURE bronze.process_bronze()
BEGIN

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred in bronze processing' AS error_message;
    END;
    
    -- transformations / joins / inserts
   SELECT COUNT(*) AS crm_cust_info_count 
FROM bronze.crm_cust_info;

SELECT COUNT(*) AS crm_prd_info_count 
FROM bronze.crm_prd_info;

SELECT COUNT(*) AS crm_sales_details_count 
FROM bronze.crm_sales_details;

SELECT COUNT(*) AS erp_cust_az12_count 
FROM bronze.erp_cust_az12;

SELECT COUNT(*) AS erp_loc_a101_count 
FROM bronze.erp_loc_a101;

SELECT COUNT(*) AS erp_px_cat_g1v2_count 
FROM bronze.erp_PX_CAT_G1V2;
END //

DELIMITER ;


CALL bronze.process_bronze();
