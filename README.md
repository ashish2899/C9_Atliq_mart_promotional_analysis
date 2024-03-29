# Atliq Marts Promotional Analysis

<div align="right">

#### Created By - Ashish Kamble @Aspiring Data Analyst _[Linkeldin Profile](https://www.linkedin.com/in/ashish-ak/)_

</div>

#### Live Dashboard at Novypro [Live_link_Novypro]()

#### Linkeldin post for this project with presentation video [Link]()

#### Presentation ppt at Canva [Link]()

#

### Table of Content

1. [Create a view for discount price](#create-a-view-for-discount-price-promo_discount)
2. [Ad_hoc Request](#ad_hoc-requests)
   - [Request_01](#request_01)
   - [Request_02](#request_02)
   - [Request_03](#request_03)
   - [Request_04](#request_04)
   - [Request_05](#request_05)
3. [Incremental Revenue](#incremental-revenue)

#

### Create a view for discount price _[promo_discount](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/promo_discount.sql)_

```SQL
    CREATE VIEW `promo_discount` AS
        SELECT
            event_id,
            store_id,
            campaign_id,
            product_code,
            base_price,
            quantity_sold_before_promo,
            promo_type,
            (CASE
                WHEN promo_type LIKE '50% OFF' THEN ROUND(base_price * 0.5,2)
                WHEN promo_type LIKE '33% OFF' THEN ROUND(base_price * 0.67,2)
                WHEN promo_type LIKE '25% OFF' THEN ROUND(base_price * 0.75,2)
                WHEN promo_type LIKE 'BOGOF' THEN ROUND(base_price / 2,2)
                WHEN promo_type LIKE '500 Cashback' THEN ROUND(base_price - 500,2)
                ELSE base_price
            END) AS discount_price,
            quantity_sold_after_promo
        FROM fact_events
```

### AD_HOC Requests

#

###### _<span style="color:#c400f5">[Request_01]</span>_

Provide a list of products with a base price greater than 500 and that are featured in promo type of 'BOGOF' (Buy One Get One Free). This information will help us identify high-value products that are currently being heavily discounted, which can be useful for evaluating our pricing and promotion strategies.

#### [SQL Query](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/request_01.sql) :-

```SQL
    SELECT
        DISTINCT e.product_code,
        p.product_name,
        e.base_price
    FROM fact_events e
    JOIN dim_products p
        ON e.product_code = p.product_code
    WHERE e.base_price > 500 AND e.promo_type = 'BOGOF'
```

#### Result :-

| product_code | product_name                   | base_price |
| ------------ | ------------------------------ | ---------: |
| P08          | Atliq_Double_Bedsheet_set      |       1190 |
| P14          | Atliq_waterproof_Immersion_Rod |       1020 |

---

###### _<span style="color:#c400f5">[Request_02]</span>_

Generate a report that provides an overview of the number of stores in each city. The results will be sorted in descending order of store counts, allowing us to identify the cities with the highest store presence. The report includes two essential fields: city and store count, which will assist in optimizing our retail operations.

#### [SQL Query](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/request_02.sql) :-

```SQL
    SELECT
        city,
        COUNT(*) AS store_count
    FROM dim_stores
    GROUP BY city
    ORDER BY store_count DESC;
```

#### Result :-

| city          | store_count |
| ------------- | ----------- |
| Bengaluru     | 10          |
| Chennai       | 8           |
| Hyderabad     | 7           |
| Coimbatore    | 5           |
| Visakhapatnam | 5           |
| Madurai       | 4           |
| Mysuru        | 4           |
| Mangalore     | 3           |
| Trivandrum    | 2           |
| Vijayawada    | 2           |

---

###### _<span style="color:#c400f5">[Request_03]</span>_

Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields:

- campaign_name,
- total_revenue(before_promotion),
- total_revenue(after_promotion).

  **This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)**

#### [SQL Query](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/request_03.sql) :-

```SQL
    SELECT
        c.campaign_name,
        ROUND(SUM(pd.base_price * pd.quantity_sold_before_promo)/1000000, 2) AS total_revenue_before_promotion_mln,
        ROUND(SUM(pd.discount_price * pd.quantity_sold_after_promo)/1000000, 2) AS total_revenue_after_promotion_mln
    FROM promo_discount pd
    JOIN dim_campaigns c
        ON pd.campaign_id = c.campaign_id
    GROUP BY c.campaign_name
    ORDER BY c.campaign_name;
```

#### Result :-

| campaign_name | total_revenue_before_promotion_mln | total_revenue_after_promotion_mln |
| ------------- | ---------------------------------: | --------------------------------: |
| Diwali        |                              82.57 |                            160.29 |
| Sankranti     |                              58.13 |                              87.7 |

---

###### _<span style="color:#c400f5">[Request_04]</span>_

Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields:

- category,
- isu%, and
- rank order.

This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.

###### _<span style="color:#0fb503">**Note:**</span> ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity sold (after promo) compared to quantity sold (before promo)_

#### [SQL Query](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/request_04.sql) :-

```SQL
    WITH isu_pct AS (
        SELECT
            p.category,
            ROUND(
                ((SUM(pd.quantity_sold_after_promo) - SUM(pd.quantity_sold_before_promo)) / SUM(pd.quantity_sold_before_promo)) * 100 ,2
            ) AS isu
        FROM promo_discount pd
        JOIN dim_products p
            ON pd.product_code = p.product_code
        WHERE pd.campaign_id = 'CAMP_DIW_01'
        GROUP BY p.category
    )

    SELECT
        *,
        RANK() OVER (ORDER BY isu DESC) AS rank_order
    FROM isu_pct
    ORDER BY isu DESC;
```

#### Result :-

| category          |    isu | rank_order |
| ----------------- | -----: | ---------: |
| Home Appliances   | 244.23 |          1 |
| Combo1            | 202.36 |          2 |
| Home Care         |  79.63 |          3 |
| Personal Care     |  31.06 |          4 |
| Grocery & Staples |  18.05 |          5 |

---

### Incremental Revenue

To calculate the incremental revenue percentage, you can follow these steps:

- Calculate the revenue before promotion: `revenue_before = base_price * quantity_sold_before_promo`
- Calculate the revenue after promotion: `revenue_after = discount_price * quantity_sold_after_promo`
- Calculate the incremental revenue: `incremental_revenue = revenue_after - revenue_before`
- Calculate the percentage increase: `incremental_revenue_percentage = (incremental_revenue / revenue_before) * 100`

Here's how you can do it in SQL:

sql

```SQL
SELECT
    (
        (
            SUM(
                discount_price * quantity_sold_after_promo
            ) - SUM(
                base_price * quantity_sold_before_promo
            )
        ) / SUM(
            base_price * quantity_sold_before_promo
        )
    ) * 100 AS incremental_revenue_percentage
FROM
    promo_discount;
```

This SQL query will give you the incremental revenue percentage across all records in your table. Adjust the table name and column names accordingly based on your actual schema.

---

###### _<span style="color:#c400f5">[Request_05]</span>_

Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

#### [SQL Query](https://github.com/ashish2899/C9_Atliq_mart_promotional_analysis/blob/main/ad_hoc_request/request_05.sql) :-

```SQL
    SELECT
        p.product_name,
        p.category,
        ROUND((
            (
                SUM(
                    pd.discount_price * pd.quantity_sold_after_promo
                ) - SUM(
                    pd.base_price * pd.quantity_sold_before_promo
                )
            ) / SUM(
                pd.base_price * pd.quantity_sold_before_promo
            )
        ) * 100,2) AS incremental_revenue_percentage
    FROM promo_discount pd
    JOIN dim_products p
        ON pd.product_code = p.product_code
    GROUP BY p.product_name, p.category
    ORDER BY incremental_revenue_percentage DESC
    LIMIT 5;
```

#### Result :-

| product_name                         | category        | incremental_revenue_percentage |
| ------------------------------------ | --------------- | -----------------------------: |
| Atliq_Home_Essential_8_Product_Combo | Combo1          |                         136.11 |
| Atliq_waterproof_Immersion_Rod       | Home Appliances |                          83.09 |
| Atliq_High_Glo_15W_LED_Bulb          | Home Appliances |                          81.49 |
| Atliq_Double_Bedsheet_set            | Home Care       |                          79.13 |
| Atliq_Curtains                       | Home Care       |                          77.67 |

---
