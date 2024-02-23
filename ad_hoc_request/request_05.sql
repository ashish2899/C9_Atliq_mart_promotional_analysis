-- Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns. The report will provide essential information including product name, category, and ir%. This analysis helps identify the most successful products in terms of incremental revenue across our campaigns, assisting in product optimization.

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
