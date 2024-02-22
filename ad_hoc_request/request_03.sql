-- Generate a report that displays each campaign along with the total revenue generated before and after the campaign? The report includes three key fields: campaign_name, total_revenue(before_promotion),total_revenue(after_promotion). This report should help in evaluating the financial impact of our promotional campaigns. (Display the values in millions)

SELECT
    c.campaign_name,
    ROUND(SUM(pd.base_price * pd.quantity_sold_before_promo)/1000000, 2) AS total_revenue_before_promotion_mln,
    ROUND(SUM(pd.discount_price * pd.quantity_sold_after_promo)/1000000, 2) AS total_revenue_after_promotion_mln
FROM promo_discount pd
JOIN dim_campaigns c
    ON pd.campaign_id = c.campaign_id
GROUP BY c.campaign_name
ORDER BY c.campaign_name;
