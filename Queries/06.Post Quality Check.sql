------------------------------------------------------------
-- POST-LOAD QUALITY CHECKS WEBSITE ORDERS - SILVER
------------------------------------------------------------

SELECT * 
FROM silver.website_orders;

SELECT * 
FROM silver.mobile_app_transactions;


-- 1. Duplicates (should return 0 rows)
SELECT order_id, product_id, COUNT(*) AS cnt
FROM silver.website_orders
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- 2. Unparsed dates (should return 0)
SELECT COUNT(*) AS unparsed_dates
FROM silver.website_orders
WHERE order_date IS NULL
  AND order_date_raw IS NOT NULL;

-- 3. Order status distribution (should be 6 clean values only)
SELECT DISTINCT order_status, COUNT(*) AS cnt
FROM silver.website_orders
GROUP BY order_status
ORDER BY cnt DESC;

-- 4. Negative price flag distribution
SELECT is_negative_price, COUNT(*) AS cnt
FROM silver.website_orders
GROUP BY is_negative_price;

-- 5. Total mismatch flag distribution
SELECT is_total_mismatch, COUNT(*) AS cnt
FROM silver.website_orders
GROUP BY is_total_mismatch;

-- 6. Currency (┬ú should now be gone — only USD, GBP, EUR, Unknown)
SELECT DISTINCT currency, COUNT(*) AS cnt
FROM silver.website_orders
GROUP BY currency
ORDER BY cnt DESC;

-- 7. Product ID format check (should return 0 invalid rows)
SELECT product_id
FROM silver.website_orders
WHERE product_id NOT LIKE 'PROD-[0-9][0-9][0-9]'
ORDER BY product_id;

-- 8. Null customer names (should return 0)
SELECT COUNT(*) AS remaining_null_names
FROM silver.website_orders
WHERE customer_name IS NULL OR customer_name = '';

-- 9. Null shipping addresses (should return 0)
SELECT COUNT(*) AS remaining_null_addresses
FROM silver.website_orders
WHERE shipping_address IS NULL OR shipping_address = '';

-- 10. Final row count
SELECT COUNT(*) AS silver_row_count FROM silver.website_orders;




------------------------------------------------------------
-- POST-LOAD QUALITY CHECKS MOBILE APPLICATIONS - SILVER 
------------------------------------------------------------

-- 1. Duplicates (should return 0 rows)
SELECT transaction_id, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 2. Unparsed timestamps (should return 0)
SELECT COUNT(*) AS unparsed_timestamps
FROM silver.mobile_app_transactions
WHERE transaction_timestamp IS NULL
  AND transaction_timestamp_raw IS NOT NULL;

-- 3. Delivery status distribution (5 canonical values only)
SELECT DISTINCT delivery_status, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY delivery_status
ORDER BY cnt DESC;

-- 4. Item category distribution (6 canonical values only)
SELECT DISTINCT item_category, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY item_category
ORDER BY cnt DESC;

-- 5. Total mismatch flag distribution
SELECT is_total_mismatch, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY is_total_mismatch;

-- 6. Currency distribution (USD, GBP, EUR, Unknown only)
SELECT DISTINCT currency_code, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY currency_code
ORDER BY cnt DESC;

-- 7. Item code format check (should return 0 invalid rows)
SELECT item_code
FROM silver.mobile_app_transactions
WHERE item_code NOT LIKE 'PROD-[0-9][0-9][0-9]'
ORDER BY item_code;

-- 8. Null user emails (should return 0)
SELECT COUNT(*) AS remaining_null_emails
FROM silver.mobile_app_transactions
WHERE user_email IS NULL OR user_email = '';

-- 9. Device type distribution (iOS and Android only)
SELECT DISTINCT device_type, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
GROUP BY device_type
ORDER BY cnt DESC;

-- 10. Promo code sample (all uppercase, no special chars)
SELECT DISTINCT promo_code, COUNT(*) AS cnt
FROM silver.mobile_app_transactions
WHERE promo_code IS NOT NULL
GROUP BY promo_code
ORDER BY cnt DESC;

-- 11. Row count sanity check
SELECT COUNT(*) AS silver_row_count
FROM silver.mobile_app_transactions;




------------------------------------------------------------
-- POST-LOAD QUALITY CHECKS -- GOLD LAYER
------------------------------------------------------------

-- 1. Row counts across all tables
SELECT 'dim_date'        AS table_name, COUNT(*) AS row_count FROM gold.dim_date
UNION ALL
SELECT 'dim_customer',                  COUNT(*) FROM gold.dim_customer
UNION ALL
SELECT 'dim_product',                   COUNT(*) FROM gold.dim_product
UNION ALL
SELECT 'dim_geography',                 COUNT(*) FROM gold.dim_geography
UNION ALL
SELECT 'dim_payment',                   COUNT(*) FROM gold.dim_payment
UNION ALL
SELECT 'dim_promo',                     COUNT(*) FROM gold.dim_promo
UNION ALL
SELECT 'dim_device',                    COUNT(*) FROM gold.dim_device
UNION ALL
SELECT 'fact_orders',                   COUNT(*) FROM gold.fact_orders;



-- 2. Confirm no orphaned FK keys in fact_orders
SELECT COUNT(*) AS null_date_keys     FROM gold.fact_orders WHERE date_key     IS NULL;
SELECT COUNT(*) AS null_customer_keys FROM gold.fact_orders WHERE customer_key IS NULL;
SELECT COUNT(*) AS null_product_keys  FROM gold.fact_orders WHERE product_key  IS NULL;
SELECT COUNT(*) AS null_payment_keys  FROM gold.fact_orders WHERE payment_key  IS NULL;
SELECT COUNT(*) AS null_promo_keys    FROM gold.fact_orders WHERE promo_key    IS NULL;
SELECT COUNT(*) AS null_device_keys   FROM gold.fact_orders WHERE device_key   IS NULL;

-- 3. Channel split in fact_orders
SELECT channel, COUNT(*) AS row_count
FROM gold.fact_orders
GROUP BY channel;


-- 4. Currency distribution in fact
SELECT currency, COUNT(*) AS cnt
FROM gold.fact_orders
GROUP BY currency
ORDER BY cnt DESC;


-- 5. USD conversion sanity check
SELECT TOP 10
    order_id,
    channel,
    currency,
    total_amount,
    total_amount_usd
FROM gold.fact_orders
WHERE currency != 'USD'
ORDER BY total_amount DESC;


-- 6. Confirm dim_promo types loaded correctly
SELECT promo_code, discount_pct, promo_type
FROM gold.dim_promo
ORDER BY promo_type;

-- 7. Confirm dim_customer preferred_channel distribution
SELECT preferred_channel, COUNT(*) AS cnt
FROM gold.dim_customer
GROUP BY preferred_channel
ORDER BY cnt DESC;

-- 8. Confirm dim_payment categories
SELECT payment_method, payment_category
FROM gold.dim_payment
ORDER BY payment_category;

-- 9. Date range in fact
SELECT
    MIN(d.full_date) AS earliest_order,
    MAX(d.full_date) AS latest_order
FROM gold.fact_orders f
JOIN gold.dim_date d ON f.date_key = d.date_key;

-- 10. Total revenue sanity check
SELECT
    channel,
    COUNT(*)                        AS total_orders,
    SUM(total_amount_usd)           AS total_revenue_usd,
    AVG(total_amount_usd)           AS avg_order_value_usd
FROM gold.fact_orders
WHERE is_negative_price = 0
GROUP BY channel;

