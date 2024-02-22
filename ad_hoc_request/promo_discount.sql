-- Creating a view for discounted price.

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