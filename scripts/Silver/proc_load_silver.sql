/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/



DELIMITER //

DROP PROCEDURE IF EXISTS silver.process_silver;

CREATE PROCEDURE silver.process_silver()
BEGIN

 DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred in bronze processing' AS error_message;
    END;

-- CUST_INFO---

TRUNCATE TABLE Silver.crm_cust_info;

insert into silver.crm_cust_info(
cst_id,
 cst_key,
 cst_firstname,
 cst_lastname,
 cst_marital_status,
 cst_gndr,
 cst_create_date
)
select 

cst_id, 
cst_key, 
trim(cst_firstname) as cst_firstname, 
trim(cst_lastname) as cst_lastname, 

case when upper(trim(cst_marital_status)) = 's' then 'SINGLE'
	when upper(trim(cst_marital_status)) = 'm' then 'MARRIED'
else 'n/a'
end cst_marital_status,

case when upper(trim(cst_gndr)) = 'f' then 'FEMALE'
     when upper(trim(cst_gndr)) = 'm' then 'MALE'
else 'n/a'
end cst_gndr,

cst_create_date

from(
select *,
row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id is not null
)t where flag_last = 1;


-- ==============================================================================================================================================
-- PRD_INFO---

TRUNCATE TABLE silver.crm_prd_info;

insert into silver.crm_prd_info(           

prd_id, 
cat_id, 
prd_key, 
prd_nm, 
prd_cost, 	
prd_line, 
prd_start_dt, 
prd_end_dt
)       


select 

 prd_id, 
 replace(substring(prd_key, 1,5), '-', '_') as cat_id,
 substring(prd_key, 7, length(prd_key)) as prd_key,
 prd_nm, 
 case when(prd_cost) = 0 then null
 else prd_cost
end prd_cost, 
 case upper(trim(prd_line))
 when 'M' then 'MOUNTAIN'
 when 'R' then 'ROAD'
 when 'S' then 'OTHER SALES'
 when 'T' then 'TOURING'
 else 'n/a'
 end as prd_line,
 
 prd_start_dt,
DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dt

from bronze.crm_prd_info

where  substring(prd_key, 7, length(prd_key))  in (

 select sls_prd_key from bronze.crm_sales_details);

-- ===============================================================================================================================================
-- SALES_DETAILS---

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
	sls_cust_id,
    sls_order_dt, 
    sls_ship_dt, 
    sls_due_dt, 
    sls_sales, 
    sls_quantity, 
    sls_price
)
select
 
    sls_ord_num,
    sls_prd_key,
	sls_cust_id,
  
CASE 
    WHEN sls_order_dt IS NULL 
         OR sls_order_dt = 0
         OR LENGTH(CAST(sls_order_dt AS CHAR)) != 8
    THEN NULL
    ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
END sls_order_dt,

case when sls_ship_dt = 0 or length(sls_ship_dt) !=8 then null
ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
end as sls_ship_dt,
case when sls_due_dt = 0 or length(sls_due_dt) !=8 then null
ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
end as sls_due_dt,

CASE 
        WHEN sls_sales IS NULL 
             OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

sls_quantity,

    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price


from silver.crm_sales_details;

-- ===============================================================================================================================================

-- CUST_AZ12---

TRUNCATE TABLE silver.erp_cust_az12;


insert into silver.erp_cust_az12(
CID, 
BDATE, 
GEN 

)

select 
case when cid like 'NAS%' then substring(cid, 4, length(cid))
else cid
end as cid,

case when bdate> now() then null
else bdate
end as bdate,

    CASE
        WHEN UPPER(TRIM(REPLACE(gen, '\r', ''))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(gen, '\r', ''))) IN ('M', 'MALE') THEN 'male'
        ELSE 'N/A'
    END AS gender
FROM bronze.erp_cust_az12;


-- ===============================================================================================================================================

-- LOC_A101---

TRUNCATE TABLE silver.erp_loc_a101;


insert into silver.erp_loc_a101(
CID, 
CNTRY
)
select distinct
replace (cid, '_', '') cid,
CASE 
    WHEN UPPER(TRIM(REPLACE(cntry, '\r', ''))) = 'DE' THEN 'Germany'

    WHEN UPPER(TRIM(REPLACE(cntry, '\r', ''))) IN ('US','USA') 
    THEN 'United States'

    WHEN TRIM(REPLACE(cntry, '\r', '')) = '' OR cntry IS NULL 
    THEN 'N/A'

    ELSE TRIM(REPLACE(cntry, '\r', ''))
END AS cntry

FROM bronze.erp_loc_a101;



/*SELECT distinct
    cntry,
    LENGTH(cntry),
    HEX(cntry)
from bronze.erp_loc_a101;*/

-- ===================================================================================================================================================

-- PX_CAT_G1V2---

TRUNCATE TABLE silver.erp_PX_CAT_G1V2;


insert into silver.erp_PX_CAT_G1V2(
ID, 
CAT, 
SUBCAT, 
MAINTENANCE
)

select
ID, 
CAT, 
SUBCAT, 
MAINTENANCE
from bronze.erp_PX_CAT_G1V2;



SELECT * FROM silver.crm_cust_info;
SELECT * FROM silver.crm_prd_info;
SELECT * FROM silver.crm_sales_details;
SELECT * FROM silver.erp_cust_az12;
SELECT * FROM silver.erp_loc_a101;
SELECT * FROM silver.erp_PX_CAT_G1V2;

END //

DELIMITER ;
