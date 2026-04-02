1. Calculate the total sales per month and the running total of sales over time 

select
order_date,
total_sales,
sum(total_sales) over(order by order_date) as running_total_sales,
avg(avg_price) over(order by order_date) as moving_average_price
from
(
select
DATE_FORMAT(order_date, '%Y-%m-01') as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date is not null
group by DATE_FORMAT(order_date, '%Y-%m-01')
)t
