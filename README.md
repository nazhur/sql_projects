### Ad-Hoc Analysis

#### A big Thanks to codebasics.com for providing this dataset.

#### Challenge: Provide Insights to Management in Consumer Goods Domain

#### Domain:  Consumer Goods | Function: Executive Management

Atliq Hardwares (imaginary company) is one of the leading computer hardware producers in India and well expanded in other countries too.

However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. They want to expand their data analytics team by adding several junior data analysts. Tony Sharma, their data analytics director wanted to hire someone who is good at both tech and soft skills. Hence, he decided to conduct a SQL challenge which will help him understand both the skills.

#### Task:  

Imagine yourself as the applicant for this role and perform the following task

1.    Check ‘ad-hoc-requests.pdf’ - there are 10 ad hoc requests for which the business needs insights.
2.    You need to run a SQL query to answer these requests. 
3.    The target audience of this dashboard is top-level management - hence you need to create a presentation to show the insights.
4.    Be creative with your presentation, audio/video presentation will have more weightage.


#### Checking all the four files to understand its column names and types.
```
SELECT * FROM dim_customer;
SELECT * FROM dim_product;
SELECT * FROM fact_sales_monthly;
SELECT * FROM fact_manufacturing_cost;
```

#### 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
```
SELECT 
	channel, market
FROM dim_customer
WHERE
customer = "Atliq Exclusive" AND region= "APAC";
```

#### 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg
```
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
```

#### 3. Provide a report WITH all the unique product count for each segment sort them in desc order
```
SELECT * FROM dim_product;
SELECT DISTINCT(segment) AS segment, COUNT(DISTINCT(product_code)) AS product_count FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;
```

#### 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, segment, product_count_2020, product_count_2021,difference

```
WITH cte3 AS(SELECT p.segment, COUNT(DISTINCT(p.product_code)) AS product_count_2020 FROM dim_product p
INNER JOIN fact_sales_monthly s ON p.product_code = s.product_code WHERE fiscal_year =2020
GROUP BY segment ORDER BY product_count_2020 desc),
cte4 AS(SELECT p.segment, COUNT(DISTINCT(p.product_code)) AS product_count_2021 FROM dim_product p
INNER JOIN fact_sales_monthly s ON p.product_code = s.product_code WHERE fiscal_year =2021
GROUP BY segment ORDER BY product_count_2021 desc)
SELECT cte3.segment, product_count_2020, product_count_2021,(product_count_2021-product_count_2020) AS Difference
FROM cte3 INNER JOIN cte4 ON cte3.segment =cte4.segment ORDER BY Difference DESC;
```


#### 5. Get the products that have the highest AND lowest manufacturing costs. The final output should contain these fields product_code, product ,manufacturing_cost
```
SELECT * FROM (SELECT p.product_code, p.product, m.manufacturing_cost FROM dim_product p
INNER JOIN fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY manufacturing_cost DESC LIMIT 1) A
UNION
SELECT * FROM(SELECT p.product_code, p.product, m.manufacturing_cost FROM dim_product p
INNER JOIN fact_manufacturing_cost m ON p.product_code = m.product_code
ORDER BY manufacturing_cost ASC LIMIT 1) B;
```

#### 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 AND in the Indian market. The final output contains these fields customer_code,customer , average_discount_percentage.
```
WITH cte6 AS(WITH cte7 AS(SELECT c.customer_code, c.customer, i.pre_invoice_discount_pct FROM dim_customer c
INNER JOIN fact_pre_invoice_deductions i ON c.customer_code = i.customer_code WHERE fiscal_year=2021 AND market="India")
SELECT cte7.*,(SELECT AVG(pre_invoice_discount_pct) FROM cte7) AS average_value FROM cte7)
SELECT customer_code, customer, ROUND(pre_invoice_discount_pct*100,2) AS average_discount_pct FROM cte6 WHERE 
pre_invoice_discount_pct > average_value ORDER BY average_discount_pct DESC LIMIT 5;
```

#### 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low AND high-performing months AND take strategic decisions. The final report contains these columns: Month ,Year ,Gross sales Amount
```
SELECT date_format(date, "%M") AS Month, year(date) AS Year, ROUND(SUM(gross_price),2) AS Gross_sales_amount FROM fact_sales_monthly
INNER JOIN fact_gross_price ON fact_sales_monthly.product_code=fact_gross_price.product_code
INNER JOIN dim_customer ON dim_customer.customer_code=fact_sales_monthly.customer_code
WHERE customer = "Atliq Exclusive"
GROUP BY Month, Year;
```

#### 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,quarter, total_sold_quantity
```
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
```

 
#### 9. Which channel helped to bring more gross sales in the fiscal year 2021 AND the percentage of contribution? The final output contains these fields channel ,gross_sales_mln ,percentage
```
WITH cte9 AS(SELECT c.channel, ROUND(SUM(s.sold_quantity*g.gross_price)/1000000,2) AS gross_sales_mln
FROM fact_sales_monthly s LEFT JOIN
fact_gross_price g ON s.product_code = g.product_code LEFT JOIN
dim_customer c ON s.customer_code = c.customer_code
WHERE s.fiscal_year = 2021 GROUP BY c.channel)
SELECT *, ROUND(gross_sales_mln*100/sum(gross_sales_mln) OVER(),2) AS percentage FROM cte9;
```

#### 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields. division, product_code product, total_sold_quantity ,rank_order
```
WITH cte10 AS(WITH cte11 AS(WITH cte12 AS(SELECT p.division, s.product_code, p.product, s.sold_quantity FROM fact_sales_monthly s
LEFT JOIN dim_product p ON s.product_code = p.product_code
WHERE s.fiscal_year=2021)
SELECT division, product_code, product, sum(sold_quantity) AS total_sold_quantity FROM cte12
GROUP BY product) 
SELECT cte11.*, RANK() over(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order FROM
cte11) SELECT * FROM cte10 WHERE rank_order < 4;
```

/*
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
*/

