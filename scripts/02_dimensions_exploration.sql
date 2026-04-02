-- Explore all the countries all our customers come from --

select distinct country from gold.dim_customers;

-- Explore all categories 'The major divisions' --

select distinct category,subcategory, product_name from gold.dim_products;
