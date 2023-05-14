Checking all the four files to understand its column names and types.
SELECT * FROM dim_customer;
SELECT * FROM dim_product;
SELECT * FROM fact_sales_monthly;
SELECT * FROM fact_manufacturing_cost;

1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
SELECT 
	channel, market
FROM dim_customer
WHERE
customer = "Atliq Exclusive" AND region= "APAC";

2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg
WITH cte1 AS (WITH cte AS(SELECT DISTINCT(product_code) AS new_product_code,
cost_year FROM fact_manufacturing_cost ORDER BY cost_year)
SELECT
	sum(CASE WHEN cost_year='2020' then 1 else NULL end) AS unique_product_2020,
	sum(CASE WHEN cost_year='2021' THEN 1 ELSE NULL end) AS unique_product_2021 
FROM cte) SELECT unique_product_2020, unique_product_2021,
	if(unique_product_2021>unique_product_2020,
	ROUND((ABS(unique_product_2021-unique_product_2020)*100/unique_product_2020),2),
	ROUND((ABS(unique_product_2021-unique_product_2020)*100/unique_product_2021),2)) AS percentage_chg
FROM cte1;

3. Provide a report WITH all the unique product count for each segment sort them in desc order
SELECT * FROM dim_product;
SELECT DISTINCT(segment) AS segment, COUNT(DISTINCT(product_code)) AS product_count FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, segment, product_count_2020, product_count_2021,difference
WITH cte3 AS(SELECT p.segment, COUNT(DISTINCT(p.product_code)) AS product_count_2020 FROM dim_product p
INNER JOIN fact_sales_monthly s ON p.product_code = s.product_code WHERE fiscal_year =2020
GROUP BY segment ORDER BY product_count_2020 desc),
cte4 AS(SELECT p.segment, COUNT(DISTINCT(p.product_code)) AS product_count_2021 FROM dim_product p
INNER JOIN fact_sales_monthly s ON p.product_code = s.product_code WHERE fiscal_year =2021
GROUP BY segment ORDER BY product_count_2021 desc)
SELECT cte3.segment, product_count_2020, product_count_2021,(product_count_2021-product_count_2020) AS Difference
FROM cte3 INNER JOIN cte4 ON cte3.segment =cte4.segment ORDER BY Difference DESC;

5. Get the products that have the highest AND lowest manufacturing costs. The final output should contain these fields product_code, product ,manufacturing_cost
SELECT * FROM (SELECT p.product_code, p.product, m.manufacturing_cost FROM dim_product p
INNER JOIN fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY manufacturing_cost DESC LIMIT 1) A
UNION
SELECT * FROM(SELECT p.product_code, p.product, m.manufacturing_cost FROM dim_product p
INNER JOIN fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY manufacturing_cost ASC LIMIT 1) B;

6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 AND in the Indian market. The final output contains these fields customer_code,customer , average_discount_percentage.
WITH cte6 AS(WITH cte7 AS(SELECT c.customer_code, c.customer, i.pre_invoice_discount_pct FROM dim_customer c
INNER JOIN fact_pre_invoice_deductions i ON c.customer_code = i.customer_code WHERE fiscal_year=2021 AND market="India")
SELECT cte7.*,(SELECT AVG(pre_invoice_discount_pct) FROM cte7) AS average_value FROM cte7)
SELECT customer_code, customer, ROUND(pre_invoice_discount_pct*100,2) AS average_discount_pct FROM cte6 WHERE 
pre_invoice_discount_pct > average_value ORDER BY average_discount_pct DESC LIMIT 5;

7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low AND high-performing months AND take strategic decisions. The final report contains these columns: Month ,Year ,Gross sales Amount
SELECT date_format(date, "%M") AS Month, year(date) AS Year, ROUND(SUM(gross_price),2) AS Gross_sales_amount FROM fact_sales_monthly
INNER JOIN fact_gross_price ON fact_sales_monthly.product_code=fact_gross_price.product_code
INNER JOIN dim_customer ON dim_customer.customer_code=fact_sales_monthly.customer_code
WHERE customer = "Atliq Exclusive"
GROUP BY Month, Year;

8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,quarter, total_sold_quantity
SELECT * FROM fact_sales_monthly LIMIT 5;

/* As fiscal year starts FROM 9/2019 we are re-assigning the month using CASE WHEN in the below solution */

WITH cte8 AS(SELECT date, month(date) as Month, sold_quantity FROM fact_sales_monthly
WHERE fiscal_year = 2020)SELECT CASE WHEN Month IN (9,10,11) THEN '1'
				WHEN Month IN (12,1,2) THEN '2'
				WHEN Month IN (3,4,5) THEN '3'
				WHEN Month IN (6,7,8) THEN '4'
                                END AS Quarter, SUM(sold_quantity) AS total_sold_quantity
                                FROM cte8
                                GROUP BY quarter
                                ORDER BY total_sold_quantity DESC;
