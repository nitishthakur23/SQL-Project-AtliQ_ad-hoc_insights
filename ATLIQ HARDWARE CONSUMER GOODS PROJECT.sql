# Resume Project Challenge - 4
/* Request 1: Provide the list of markets in which customer "Atliq Exclusive" operates its
 business in the APAC region. */
SELECT
	market
FROM dim_customer
WHERE
	customer="Atliq Exclusive" AND
    region="APAC"
GROUP BY market
ORDER BY market;
    
/* Request 2: What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg */
/*WITH CTE1 AS (
	SELECT 
		product_code, SUM(sold_quantity) AS unique_products_2020
	FROM fact_sales_monthly 
	WHERE fiscal_year=2020
	GROUP BY product_code),
CTE2 AS (
	SELECT 
		product_code, SUM(sold_quantity) AS unique_products_2021
	FROM fact_sales_monthly 
	WHERE fiscal_year=2021
	GROUP BY product_code)
SELECT 
	product_code,
    CTE1.unique_products_2020,
    CTE2.unique_products_2021
FROM CTE1
JOIN CTE2 USING (product_code);

SELECT 
	product_code,
    unique_products_2020,
    unique_products_2021,
    ROUND((unique_products_2021-unique_products_2020)*100/unique_products_2020, 2) AS pct_chg
FROM products_2020
JOIN products_2021 USING (product_code);*/

WITH CTE1 AS (
	SELECT 
		COUNT(DISTINCT(product_code)) AS unique_products_2020
	FROM fact_sales_monthly 
    WHERE fiscal_year=2020),
CTE2 AS (
	SELECT 
		COUNT(DISTINCT(product_code)) AS unique_products_2021
	FROM fact_sales_monthly 
    WHERE fiscal_year=2021)
SELECT 
	*,
    ROUND((CTE2.unique_products_2021-CTE1.unique_products_2020)*100/CTE1.unique_products_2020,2) AS percentage_chg 
FROM CTE1, CTE2;
    
    
/* Request 3: Provide a report with all the unique product counts for each segment and
 sort them in descending order of product counts. The final output contains
 2 fields; segment, product_count */
SELECT * FROM dim_product;
SELECT 
	segment,
	COUNT(product_code) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

/* Request 4: Follow-up: Which segment had the most increase in unique products in
 2021 vs 2020? The final output contains these fields,
 segment
 product_count_2020
 product_count_2021
 difference */
/*SELECT 
	segment,
    ROUND(unique_products_2020/1000, 2) AS product_2020_K,
    ROUND(unique_products_2021/1000, 2) AS product_2021_K,
    ROUND((unique_products_2021-unique_products_2020)/1000, 2) AS difference_K
FROM segment_wise_products_2020 
JOIN segment_wise_products_2021
	USING (segment)
ORDER BY difference_K DESC;

SELECT 
	segment,
    ROUND(unique_products_2020/1000000, 2) AS product_count_2020_MLN,
    ROUND(unique_products_2021/1000000, 2) AS product_count_2021_MLN,
    ROUND((unique_products_2021-unique_products_2020)/1000000, 2) AS difference_MLN
FROM segment_wise_products_2020 
JOIN segment_wise_products_2021
	USING (segment)
ORDER BY difference_MLN DESC;*/

WITH CTE1 AS (
SELECT 
	segment,
	COUNT(DISTINCT(product_code)) AS product_count_2020
FROM fact_sales_monthly
JOIN dim_product 
	USING (product_code)
WHERE fiscal_year=2020
GROUP BY segment),
CTE2 AS (
SELECT 
	segment,
	COUNT(DISTINCT(product_code)) AS product_count_2021
FROM fact_sales_monthly
JOIN dim_product 
	USING (product_code)
WHERE fiscal_year=2021
GROUP BY segment)
SELECT 
	*,
    product_count_2021-product_count_2020 AS difference
FROM CTE1
JOIN CTE2
	USING (segment);

/* Request 5: Get the products that have the highest and lowest manufacturing costs.The final output should contain these fields,
 product_code
 product
 manufacturing_cost */
CREATE TEMPORARY TABLE manufacturing_costs AS 
	SELECT 
		mc.product_code,
		p.product,
		mc.manufacturing_cost,
		mc.cost_year
	FROM fact_manufacturing_cost mc
	JOIN dim_product p
		USING (product_code);
        
SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
ORDER BY manufacturing_cost DESC LIMIT 1;

SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
ORDER BY manufacturing_cost LIMIT 1;

-- TOP 5 Products with Highest manufacturing costs in 2020 -- 
SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
WHERE cost_year=2020
ORDER BY manufacturing_cost DESC
LIMIT 5;

-- TOP 5 Products with Lowest manufacturing costs in 2020 -- 
SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
WHERE cost_year=2020
ORDER BY manufacturing_cost 
LIMIT 5;

-- TOP 5 Products with Highest manufacturing costs in 2021 -- 
SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
WHERE cost_year=2021
ORDER BY manufacturing_cost DESC
LIMIT 5;

-- TOP 5 Products with Lowest manufacturing costs in 2021 -- 
SELECT 
	product_code,
    product,
    manufacturing_cost
FROM manufacturing_costs
WHERE cost_year=2021
ORDER BY manufacturing_cost 
LIMIT 5;

/* Request 6: Generate a report which contains the top 5 customers who received an
 average high pre_invoice_discount_pct for the fiscal year 2021 and in the
 Indian market. The final output contains these fields,
 customer_code
 customer
 average_discount_percentage */
SELECT * FROM fact_pre_invoice_deductions; -- customer_code, fy, PID_pct
SELECT * FROM dim_customer; -- customer_code, customer, platform, channel, market, sub_zone, region
SELECT
	customer_code,
    customer,
    ROUND(AVG(pre_invoice_discount_pct),4)*100 AS average_discount_percentage
FROM fact_pre_invoice_deductions
JOIN dim_customer 
	USING (customer_code)
WHERE 
	fiscal_year=2021 AND 
    market="India"
GROUP BY customer_code, customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

/* Request 7: Get the complete report of the Gross sales amount for the customer “Atliq
 Exclusive” for each month. This analysis helps to get an idea of low and
 high-performing months and take strategic decisions.
 The final report contains these columns:
 Month
 Year
 Gross sales Amount */
SELECT 
	MONTHNAME(s.date) AS Calendar_Month,
	get_fiscal_month(s.date) AS Fiscal_Month, 
    fiscal_year AS Fiscal_Year,
    ROUND(SUM(p.gross_price*s.sold_quantity),2) AS Gross_sales_amount
FROM fact_sales_monthly s
JOIN dim_customer c
	USING (customer_code)
JOIN fact_gross_price p
	USING (product_code, fiscal_year)
WHERE customer="Atliq Exclusive"
GROUP BY s.date,Fiscal_Month,Fiscal_Year
ORDER BY date; 

/* Request 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
# output contains these fields sorted by the total_sold_quantity,
# Quarter
# total_sold_quantity */
SELECT
	get_fiscal_qtr(date) AS Quarter,
    SUM(sold_quantity) AS Total_Sold_Quantity
FROM fact_sales_monthly
WHERE fiscal_year=2020
GROUP BY Quarter
ORDER BY Total_Sold_Quantity DESC;

/* Request 9: Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage */
WITH CTE1 AS (
	SELECT 
		channel,
		ROUND(SUM(gross_price*sold_quantity)/1000000, 2) AS Gross_Sales_MLN
	FROM fact_sales_monthly
	JOIN dim_customer
		USING (customer_code)
	JOIN fact_gross_price
		USING (product_code, fiscal_year)
	WHERE fiscal_year=2021
	GROUP BY channel
	ORDER BY Gross_Sales_MLN DESC)
SELECT
	*, ROUND(Gross_Sales_MLN*100/SUM(Gross_Sales_MLN) OVER (), 2) AS percentage
FROM CTE1;

/* Request 10: Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields:
		division
		product_code
		product
		total_sold_quantity
		rank_order
*/
SELECT * FROM fact_sales_monthly; -- fy, sold_qty, p_code, c_code
SELECT * FROM dim_product; -- div, product
WITH CTE1 AS (
		SELECT 
			p.division,
			s.product_code,
			p.product,
			SUM(s.sold_quantity) AS Total_Sold_Quantity
		FROM fact_sales_monthly s
		JOIN dim_product p
			USING (product_code)
		WHERE fiscal_year=2021
		GROUP BY 
			p.division,
			s.product_code,
			p.product),
CTE2 AS (
		SELECT
			*,
			DENSE_RANK() OVER(PARTITION BY division ORDER BY Total_Sold_Quantity DESC) AS rank_order
		FROM CTE1)
SELECT 
	*
FROM CTE2
WHERE rank_order <= 3;





