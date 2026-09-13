/********************************************************************************************
 SCRIPT NAME : BRONZE LAYER DDL & LOAD
 DESCRIPTION :
     CREATES BRONZE LAYER TABLES FOR WEBSITE AND MOBILE APP SOURCE DATA
     AND LOADS DATA USING BULK INSERT.
********************************************************************************************/
/********************************************************************************************
 SCRIPT NAME : BRONZE LAYER DDL
 DESCRIPTION :
     CREATES BRONZE LAYER TABLES FOR WEBSITE AND MOBILE APP SOURCE DATA & LOADS DATA USING BULK INSERT.
********************************************************************************************/

------------------------------------------------------------
-- WEBSITE ORDERS TABLE
------------------------------------------------------------

IF OBJECT_ID ('bronze.website_orders','U') IS NOT NULL
    DROP TABLE bronze.website_orders

CREATE TABLE bronze.website_orders (
    Order_id          NVARCHAR(50),
    Order_date        NVARCHAR(50),
    Customer_email    NVARCHAR(100),
    Customer_name     NVARCHAR(100),
    Product_id        NVARCHAR(50),
    Product_name      NVARCHAR(100),
    Category          NVARCHAR(50),
    Quantity          NVARCHAR(50),
    Unit_price        NVARCHAR(50),
    Total_amount      NVARCHAR(50),
    Discount          NVARCHAR(50),
    Shipping_cost     NVARCHAR(50),
    Order_status      NVARCHAR(50),
    Payment_method    NVARCHAR(50),
    Shipping_address  NVARCHAR(255),
    Country           NVARCHAR(50),
    Currency          NVARCHAR(10)
);


------------------------------------------------------------
-- WEBSITE ORDERS TABLE
------------------------------------------------------------

IF OBJECT_ID ('bronze.mobile_app_transactions','U') IS NOT NULL
    DROP TABLE bronze.mobile_app_transactions

CREATE TABLE bronze.mobile_app_transactions (
    Transaction_id        NVARCHAR(50),
    Transaction_timestamp NVARCHAR(50),
    User_id               NVARCHAR(50),
    User_email            NVARCHAR(100),
    Item_code             NVARCHAR(50),
    Item_description      NVARCHAR(100),
    Item_category         NVARCHAR(50),
    Qty                   NVARCHAR(50),
    Price                 NVARCHAR(50),
    Gross_total           NVARCHAR(50),
    Promo_code            NVARCHAR(50),
    Delivery_fee          NVARCHAR(50),
    Delivery_status       NVARCHAR(50),
    Payment_type          NVARCHAR(50),
    Device_type           NVARCHAR(50),
    App_version           NVARCHAR(20),
    Region                NVARCHAR(50),
    Currency_code         NVARCHAR(10)
);

------------------------------------------------------------
-- STORED PROCEDURE: bronze.load_bronze
------------------------------------------------------------

CREATE PROCEDURE bronze.load_bronze
AS
   BEGIN
       DECLARE
        @Start_time          DATETIME,   -- Time pipeline starts running
        @End_time            DATETIME,   -- Time pipeline ends running
        @Batch_start_time    DATETIME,   
        @Batch_end_time      DATETIME;

    BEGIN TRY
        SET NOCOUNT ON;

    -- Batch Start (Provide current date & time the batch starts)
    SET @Batch_start_time = GETDATE();

    PRINT 'Loading Bronze Layer';
    PRINT '=====================================================================';
    PRINT 'Batch Start Time:' + CONVERT(NVARCHAR, @Batch_start_time,  120);
    PRINT ' ';


    ------------------------------------------------------------
    -- WEBSITE ORDERS
    ------------------------------------------------------------

    PRINT 'Loading Website Source Tables';
    PRINT '-------------------------------------------------------------';

    --Website orders
    SET @Start_time = GETDATE();

    PRINT '>> Truncating Table: bronze.website_orders';
    TRUNCATE TABLE bronze.website_orders;
    
    PRINT '>> Inserting Data Into: bronze.website_orders';
    SET NOCOUNT OFF;

    BULK INSERT bronze.website_orders
    FROM 'C:\Users\HP\Documents\DWD Files\ETL Pipeline\website_orders.csv'
    WITH (
        FIRSTROW            = 2,
        FIELDTERMINATOR     = ',',
        ROWTERMINATOR       = '\n',
        TABLOCK
);

SET NOCOUNT ON;
SET @End_time = GETDATE();

PRINT ' >> Load Duration: '
           + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
           + ' seconds';
    PRINT ' >> -------------------------------------------------';
    PRINT '';
        
        
    PRINT 'WEBSITE TABLE LOADED SUCCESSFULLY';
    PRINT ' >> -------------------------------------------------';
    
    ------------------------------------------------------------
    -- MOBILE APP TRANSACTIONS
    ------------------------------------------------------------

    PRINT 'Loading Mobile App Source Tables';
    PRINT '----------------------------------------------------------------------';

    -- mobile_app_transactions
    SET @Start_time = GETDATE();

    PRINT '>> Truncating Table: bronze.mobile_app_transactions';
    TRUNCATE TABLE bronze.mobile_app_transactions;

    PRINT '>> Inserting Data Into: bronze.mobile_app_transactions';
    SET NOCOUNT OFF;

    BULK INSERT bronze.mobile_app_transactions
    FROM 'C:\Users\HP\Documents\DWD Files\ETL Pipeline\mobile_app_transactions.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        TABLOCK
    );

    SET NOCOUNT ON;
    SET @End_time = GETDATE();

    PRINT ' >> Load Duration: '
          + CAST(DATEDIFF(SECOND, @Start_time, @End_time) AS NVARCHAR)
          + ' seconds';
    PRINT ' >> -------------------------------------------------';
    PRINT '';

    PRINT 'MOBILE APP TABLES LOADED SUCCESSFULLY';
    PRINT '----------------------------------------------------------------------';

    ------------------------------------------------------------
    -- VALIDATION: ROW COUNT CHECK
    ------------------------------------------------------------

    PRINT 'Validating Row Counts...';
    PRINT '----------------------------------------------------------------------';

    DECLARE @Web_rows INT,
            @App_rows INT;

    SELECT @Web_rows = COUNT(*)
    FROM bronze.website_orders;

    SELECT @App_rows = COUNT(*)
    FROM bronze.mobile_app_transactions;

    PRINT 'Website Rows Loaded: ' + CAST(@Web_rows AS NVARCHAR);
    PRINT 'App Rows Loaded    : ' + CAST(@App_rows AS NVARCHAR);

    PRINT '----------------------------------------------------------------------';
    PRINT '';

    ------------------------------------------------------------
    -- BATCH END
    ------------------------------------------------------------

    SET @Batch_end_time = GETDATE();
    
    PRINT '======================================================================';
    PRINT 'BRONZE LAYER LOADED SUCCESSFULLY';
    PRINT 'Batch End Time  : ' + CONVERT(NVARCHAR, @Batch_end_time, 120);
    PRINT 'Total Duration  : '
          + CAST(DATEDIFF(SECOND, @Batch_start_time, @Batch_end_time) AS NVARCHAR)
          + ' seconds';
    PRINT '======================================================================';
END TRY

    BEGIN CATCH
        PRINT '======================================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR MESSAGE : ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR LINE    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '======================================================================';

        THROW;
    END CATCH
END;

EXEC bronze.load_bronze