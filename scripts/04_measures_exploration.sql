-- Generate that shows all key metrics of business

select 'total sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
union all
select 'total quantity' , sum(quantity)  from gold.fact_sales
union all
select 'average Price', avg(price) from gold.fact_sales
union all
select 'total nr.orders' , count(distinct order_number) from gold.fact_sales
union all
select 'total nr.products' , count(product_name)  from gold.dim_products
union all
select 'total nr.customers' , count(customer_key)  from gold.dim_customers;
