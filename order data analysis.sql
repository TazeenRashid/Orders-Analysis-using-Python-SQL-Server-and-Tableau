--find top 10 highest reveue generating products 
select top 10 product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

--find top 5 highest selling products in each region


with cte as (select region, product_id, sum(sale_price) as sales,
	ROW_NUMBER() OVER (partition by region order by sum(sale_price) desc) as rnk
	from df_orders

	group by region, product_id)
select region, product_id, sales
from cte
where rnk<=5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte1 as (select MONTH(order_date) as order_Month, YEAR(order_date) as order_Year, sum(sale_price) as Sales
	from df_orders
	group by MONTH(order_date), YEAR(order_date)),
cte2 as (select order_Month,  SUM(CASE WHEN order_Year = 2022 THEN Sales ELSE 0 END) AS Sales2022, 
        SUM(CASE WHEN order_Year = 2023 THEN Sales ELSE 0 END) AS Sales2023
	from cte1 group by order_Month)
select order_Month, "Sales2022", "Sales2023",
CONCAT(CAST(ROUND((Sales2023 - Sales2022) * 100 / NULLIF(Sales2023, 0), 2) AS DECIMAL(4,2)), '%') AS growth
from cte2 

order by order_Month;

--for each category which month had highest sales 
with cte1 as (select MONTH(order_date) as order_Month, YEAR(order_date) as order_Year, category, sum(sale_price) as Sales,
	ROW_NUMBER() over (partition by category order by sum(sale_price) desc) as rnk
	from df_orders
	where YEAR(order_date)=2023
	group by MONTH(order_date), YEAR(order_date), category)
select category, order_Month, order_Year, Sales
from cte1
where rnk<=1 
order by Sales desc;

--which sub category had highest growth by profit in 2023 compare to 2022
with cte1 as (select sub_category, YEAR(order_date) as order_Year, sum(profit) as totalProfit
	from df_orders
	group by sub_category, YEAR(order_date)),
cte2 as (select sub_category,  SUM(CASE WHEN order_Year = 2022 THEN totalProfit ELSE 0 END) AS Profit2022, 
        SUM(CASE WHEN order_Year = 2023 THEN totalProfit ELSE 0 END) AS Profit2023
	from cte1 group by sub_category)
select top 1 sub_category, "Profit2022", "Profit2023",
CAST(ROUND((Profit2023 - Profit2022) * 100 / NULLIF(Profit2023, 0), 2) AS DECIMAL(7,2)) AS Profit_growth
from cte2 

order by Profit_growth desc;

