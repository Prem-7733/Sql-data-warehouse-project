select
year(order_date) as order_year,
month(order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date),month(order_date)
order by year(order_date),month(order_date);


-- OR --

select

DATE_FORMAT(order_date, '%Y-%m-01') as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by DATE_FORMAT(order_date, '%Y-%m-01')
order by DATE_FORMAT(order_date, '%Y-%m-01')
