-- Find the date of the first and last order
-- How many years of sales are avilable

select
min(order_date) as first_order_date,
max(order_date) as last_order_date,
timestampdiff(month,min(order_date), max(order_date)) as order_range_months
from gold.fact_sales;

-- Find the youngest and oldest customer
select
min(birth_date) as oldest_birthdate,
timestampdiff(year,min(birth_date),now()) as oldest_age,
max(birth_date) as youngest_birthdate,
timestampdiff(year,max(birth_date),now()) as youngest_age
from gold.dim_customers;
