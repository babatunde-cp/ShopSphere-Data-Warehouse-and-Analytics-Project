/*****************************************************************
 SCRIPT NAME : SILVER LAYER — FULL DDL & TRANSFORMATION LOAD 
 SOURCE      : bronze.website_orders
 TARGET      : silver.website_orders
 DESCRIPTION :
     CREATES THE SILVER TABLE AND STORED PROCEDURE TO CLEAN,
     STANDARDIZE, AND LOAD WEBSITE ORDERS FROM THE BRONZE LAYER.
*****************************************************************/

SELECT * FROM bronze.website_orders
SELECT * FROM bronze.mobile_app_transactions

------------------------------------------------------------
-- 1. DUPLICATE ORDER LINES
--    Same order_id + product_id appearing more than once
------------------------------------------------------------

SELECT
    Order_id,
    Product_id,
    COUNT(*) AS Duplicate_Count
FROM bronze.website_orders
GROUP BY Order_id,Product_id
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;


-------------------------------------------------
-- 2. NULL CUSTOMER NAMES
-------------------------------------------------

SELECT
    COUNT(*)                                                  AS     Total_rows,
    SUM(CASE WHEN Customer_name IS NULL THEN 1 ELSE 0 END)    AS     Null_Names,
    SUM(CASE WHEN Customer_name IS NULL THEN 1 ELSE 0 END) * 100.0   
    / COUNT(*)                                                AS    Null_Pct
FROM bronze.website_orders

------------------------------------------------
-- 3. NULL SHIPPING ADDRESSES
------------------------------------------------

SELECT
    COUNT(*)                                                     AS     Total_rows,
    SUM(CASE WHEN Shipping_address IS NULL THEN 1 ELSE 0 END)    AS     Null_Shipping_address,
    SUM(CASE WHEN Shipping_address IS NULL THEN 1 ELSE 0 END) * 100.0   
    / COUNT(*)                                                   AS    Null_Pct
FROM bronze.website_orders


------------------------------------------------------------
-- 4. MIXED DATE FORMATS
--    Identify all distinct date patterns present
------------------------------------------------------------

SELECT
    Order_date,
    CASE
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
            THEN 'YYYY-MM-DD'
        WHEN order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN 'MM/DD/YYYY'
        WHEN order_date LIKE '[0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9]'
            THEN 'DD-Mon-YYYY'
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN 'YYYY/MM/DD'
        WHEN order_date LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
            THEN 'DD.MM.YYYY'
        ELSE 'UNKNOWN'
    END AS Detected_format
FROM bronze.website_orders
ORDER BY Detected_format;


-- Count by format
SELECT
    CASE
        WHEN Order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
            THEN 'YYYY-MM-DD'
        WHEN Order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN 'MM/DD/YYYY'
        WHEN Order_date LIKE '[0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9]'
            THEN 'DD-Mon-YYYY'
        WHEN Order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN 'YYYY/MM/DD'
        WHEN Order_date LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
            THEN 'DD.MM.YYYY'
        ELSE 'UNKNOWN'
    END AS Detected_format,
    COUNT(*) AS record_count
FROM bronze.website_orders
GROUP BY
    CASE
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'     
            THEN 'YYYY-MM-DD'
        WHEN order_date LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]'
            THEN 'MM/DD/YYYY'
        WHEN order_date LIKE '[0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9]'
            THEN 'DD-Mon-YYYY'
        WHEN order_date LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]'
            THEN 'YYYY/MM/DD'
        WHEN order_date LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]'
            THEN 'DD.MM.YYYY'
        ELSE 'UNKNOWN'
    END
ORDER BY Record_count DESC;

------------------------------------------------------------
-- 5. INCONSISTENT ORDER STATUS VALUES
------------------------------------------------------------
SELECT DISTINCT
    Order_status,
    COUNT(*) AS record_count
FROM bronze.website_orders
GROUP BY Order_status
ORDER BY record_count DESC;

------------------------------------------------------------
-- 6. NEGATIVE UNIT PRICES
------------------------------------------------------------
SELECT
    COUNT(*) AS negative_price_count
FROM bronze.website_orders
WHERE TRY_CAST(unit_price AS DECIMAL(10,2)) < 0;

-- Preview the records
SELECT
    order_id,
    product_name,
    unit_price,
    quantity,
    total_amount
FROM bronze.website_orders
WHERE TRY_CAST(unit_price AS DECIMAL(10,2)) < 0;

------------------------------------------------------------
-- 7. TOTAL AMOUNT MISMATCH
--    total_amount should equal (quantity * unit_price) - discount + shipping_cost
------------------------------------------------------------
SELECT
    Order_id,
    Product_name,
    Quantity,
    Unit_price,
    Discount,
    Shipping_cost,
    Total_amount,
    ROUND(
        TRY_CAST(quantity AS INT)
        * TRY_CAST(unit_price AS DECIMAL(10,2))
        - TRY_CAST(discount AS DECIMAL(10,2))
        + TRY_CAST(shipping_cost AS DECIMAL(10,2)),
    2) AS expected_total,
    ROUND(
        ABS(
            TRY_CAST(total_amount AS DECIMAL(10,2)) -
            (
                TRY_CAST(quantity AS INT)
                * TRY_CAST(unit_price AS DECIMAL(10,2))
                - TRY_CAST(discount AS DECIMAL(10,2))
                + TRY_CAST(shipping_cost AS DECIMAL(10,2))
            )
        ),
    2) AS variance
FROM bronze.website_orders
WHERE
    ABS(
        TRY_CAST(total_amount AS DECIMAL(10,2)) -
        (
            TRY_CAST(quantity AS INT)
            * TRY_CAST(unit_price AS DECIMAL(10,2))
            - TRY_CAST(discount AS DECIMAL(10,2))
            + TRY_CAST(shipping_cost AS DECIMAL(10,2))
        )
    ) > 0.01
ORDER BY variance DESC;


------------------------------------------------------------
-- 8. MESSY CURRENCY VALUES
------------------------------------------------------------
SELECT DISTINCT
    currency,
    COUNT(*) AS record_count
FROM bronze.website_orders
GROUP BY currency
ORDER BY record_count DESC;

------------------------------------------------------------
-- 9. INCONSISTENT PRODUCT ID FORMATS
------------------------------------------------------------
SELECT DISTINCT
    product_id,
    LEFT(product_id, PATINDEX('%[0-9]%', product_id) - 1) AS prefix_detected
FROM bronze.website_orders
ORDER BY prefix_detected;

-- Count by format pattern
SELECT
    CASE
        WHEN product_id LIKE 'PROD-[0-9]%' THEN 'PROD-NNN'
        WHEN product_id LIKE 'prod-[0-9]%' THEN 'prod-NNN'
        WHEN product_id LIKE 'P[0-9]%'     THEN 'PNNN'
        WHEN product_id LIKE 'PROD[0-9]%'  THEN 'PRODNNN'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS record_count
FROM bronze.website_orders
GROUP BY
    CASE
        WHEN product_id LIKE 'PROD-[0-9]%' THEN 'PROD-NNN'
        WHEN product_id LIKE 'prod-[0-9]%' THEN 'prod-NNN'
        WHEN product_id LIKE 'P[0-9]%'     THEN 'PNNN'
        WHEN product_id LIKE 'PROD[0-9]%'  THEN 'PRODNNN'
        ELSE 'OTHER'
    END
ORDER BY record_count DESC;

------------------------------------------------------------
-- 10. CUSTOMER EMAIL CASING
------------------------------------------------------------
SELECT DISTINCT
    Customer_email
FROM bronze.website_orders
WHERE customer_email != LOWER(customer_email)
ORDER BY customer_email;

------------------------------------------------------------
-- 11. UNWANTED SPACES IN Customer Name
------------------------------------------------------------
SELECT Customer_name
FROM bronze.website_orders
WHERE customer_name != TRIM(customer_name);

------------------------------------------------------------
-- 12. UNWANTED SPACES IN Product name
------------------------------------------------------------
SELECT Product_name
FROM bronze.website_orders
WHERE product_name != TRIM(product_name);





/***************************************************************************
 SCRIPT NAME : SILVER LAYER — EXPLORATION & DATA QUALITY CHECKS
 SOURCE      : bronze.mobile_app_transactions
 DESCRIPTION :
     PRE-TRANSFORMATION CHECKS TO UNDERSTAND DATA QUALITY ISSUES
     BEFORE SILVER LAYER CLEANING.
**************************************************************************/

------------------------------------------------------------
-- 1. DUPLICATE TRANSACTIONS
------------------------------------------------------------
SELECT
    Transaction_id,
    COUNT(*) AS duplicate_count
FROM bronze.mobile_app_transactions
GROUP BY Transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

------------------------------------------------------------
-- 2. NULL USER EMAILS (~8% expected)
------------------------------------------------------------
SELECT
    COUNT(*)                                              AS total_rows,
    SUM(CASE WHEN User_email IS NULL THEN 1 ELSE 0 END)   AS null_emails,
    SUM(CASE WHEN User_email IS NULL THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)                                        AS null_pct
FROM bronze.mobile_app_transactions;

------------------------------------------------------------
-- 3. MIXED TIMESTAMP FORMATS
------------------------------------------------------------
SELECT
    CASE
        WHEN transaction_timestamp LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] %'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9] %'
            THEN 'MM/DD/YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9] %'
            THEN 'DD-Mon-YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9] %'
            THEN 'DD.MM.YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] %'
            THEN 'YYYY/MM/DD HH:MM:SS'
        WHEN TRY_CAST(transaction_timestamp AS BIGINT) IS NOT NULL
            THEN 'Unix Timestamp'
        ELSE 'UNKNOWN'
    END AS detected_format,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY
    CASE
        WHEN transaction_timestamp LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] %'
            THEN 'YYYY-MM-DD HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9] %'
            THEN 'MM/DD/YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9]-[A-Z][a-z][a-z]-[0-9][0-9][0-9][0-9] %'
            THEN 'DD-Mon-YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9] %'
            THEN 'DD.MM.YYYY HH:MM:SS'
        WHEN transaction_timestamp LIKE '[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] %'
            THEN 'YYYY/MM/DD HH:MM:SS'
        WHEN TRY_CAST(transaction_timestamp AS BIGINT) IS NOT NULL
            THEN 'Unix Timestamp'
        ELSE 'UNKNOWN'
    END
ORDER BY record_count DESC;


------------------------------------------------------------
-- 4. DELIVERY STATUS VARIANTS
------------------------------------------------------------
SELECT
    Delivery_status,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY Delivery_status
ORDER BY record_count DESC;


------------------------------------------------------------
-- 5. ITEM CATEGORY VARIANTS
--    Expect aliases: Tech, Apparel, H&K, Fitness etc.
------------------------------------------------------------
SELECT
    item_category,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY item_category
ORDER BY record_count DESC;


------------------------------------------------------------
-- 6. GROSS TOTAL MISMATCH
--    gross_total should equal (qty * price) + delivery_fee
------------------------------------------------------------
SELECT
    COUNT(*) AS mismatch_count
FROM bronze.mobile_app_transactions
WHERE
    ABS(
        ISNULL(TRY_CAST(gross_total AS DECIMAL(10,2)), 0)
        - (
            ISNULL(TRY_CAST(qty AS INT), 0)
            * ISNULL(TRY_CAST(price AS DECIMAL(10,2)), 0)
            + ISNULL(TRY_CAST(delivery_fee AS DECIMAL(10,2)), 0)
        )
    ) > 0.01;

------------------------------------------------------------
-- 7. NEGATIVE PRICES
------------------------------------------------------------
SELECT
    COUNT(*) AS negative_price_count
FROM bronze.mobile_app_transactions
WHERE TRY_CAST(price AS DECIMAL(10,2)) < 0;


------------------------------------------------------------
-- 8. CURRENCY CODE VARIANTS
------------------------------------------------------------
SELECT
    currency_code,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY currency_code
ORDER BY record_count DESC;


--------------------------------------------
-- 9. ITEM CODE FORMAT VARIANTS
--------------------------------------------
SELECT
    CASE
        WHEN item_code LIKE 'APP-[0-9]%'      THEN 'APP-NNN'
        WHEN item_code LIKE 'MOB-PROD-[0-9]%' THEN 'MOB-PROD-NNN'
        WHEN item_code LIKE 'M[0-9]%'         THEN 'MNNN'
        WHEN item_code LIKE 'PROD-[0-9]%'     THEN 'PROD-NNN'
        WHEN item_code LIKE 'PROD[0-9]%'      THEN 'PRODNNN'
        ELSE 'OTHER'
    END AS format_pattern,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY
    CASE
        WHEN item_code LIKE 'APP-[0-9]%'      THEN 'APP-NNN'
        WHEN item_code LIKE 'MOB-PROD-[0-9]%' THEN 'MOB-PROD-NNN'
        WHEN item_code LIKE 'M[0-9]%'         THEN 'MNNN'
        WHEN item_code LIKE 'PROD-[0-9]%'     THEN 'PROD-NNN'
        WHEN item_code LIKE 'PROD[0-9]%'      THEN 'PRODNNN'
        ELSE 'OTHER'
    END
ORDER BY record_count DESC;


------------------------------------------------------------
-- 10. DEVICE TYPE VARIANTS
------------------------------------------------------------
SELECT
    device_type,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
GROUP BY device_type
ORDER BY record_count DESC;


------------------------------------------------------------
-- 11. PROMO CODE SAMPLE
--     Check casing and special character mess
------------------------------------------------------------
SELECT DISTINCT
    promo_code,
    COUNT(*) AS record_count
FROM bronze.mobile_app_transactions
WHERE promo_code IS NOT NULL
GROUP BY promo_code
ORDER BY record_count DESC;

------------------------------------------------------------
-- 12. UNWANTED SPACES
------------------------------------------------------------
SELECT COUNT(*) AS spaces_in_description
FROM bronze.mobile_app_transactions
WHERE item_description != TRIM(item_description);

SELECT COUNT(*) AS spaces_in_category
FROM bronze.mobile_app_transactions
WHERE item_category != TRIM(item_category);


-- What are the UNKNOWN timestamp formats?
SELECT DISTINCT TOP 20
    transaction_timestamp
FROM bronze.mobile_app_transactions
WHERE transaction_timestamp NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] %'
  AND TRY_CAST(transaction_timestamp AS BIGINT) IS NULL
ORDER BY transaction_timestamp;

-- What are the OTHER item code formats?
SELECT DISTINCT
    item_code
FROM bronze.mobile_app_transactions
WHERE item_code NOT LIKE 'APP-[0-9]%'
  AND item_code NOT LIKE 'MOB-PROD-[0-9]%'
  AND item_code NOT LIKE 'M[0-9]%'
  AND item_code NOT LIKE 'PROD-[0-9]%'
  AND item_code NOT LIKE 'PROD[0-9]%'
ORDER BY item_code;