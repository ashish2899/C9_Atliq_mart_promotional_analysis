-- Produce a report that calculates the Incremental Sold Quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%. The report will include three key fields: category, isu%, and rank order. This information will assist in assessing the category-wise success and impact of the Diwali campaign on incremental sales.

-- Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the percentage increase/decrease in quantity sold (after promo) compared to quantity sold (before promo)

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