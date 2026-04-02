1. What are the 5 top-performing products in terms of sales?

select 
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
group by 
p.product_name
order by total_revenue desc
limit 5;

-- OR --

select 
p.product_name,
sum(f.sales_amount) as total_revenue,
row_number() over(order by sum(f.sales_amount)desc) as rank_products
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
group by 
p.product_name
order by total_revenue desc;

2. What are the 5 worst-performing products in terms of sales?

select 
p.product_name,
sum(f.sales_amount) as total_revenue
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
group by 
p.product_name
order by total_revenue asc
limit 5;

3. Find the top 10 customers who have highest orders placed 

select
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as total_orders
from gold.fact_sales f
left join  gold.dim_customers c
on c.customer_key = f.customer_key
group by
c.customer_key,
c.first_name,
c.last_name
order by total_orders asc
limit 3;
