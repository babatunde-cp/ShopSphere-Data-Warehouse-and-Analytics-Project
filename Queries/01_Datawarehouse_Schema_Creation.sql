/***********************************************************************************************
Script Name : Database & Schema Creation
Author : Babatunde Kareeem

Description : 
		Creates a new database named 'ShopSphereDB' after checking if it already exists.
		Initializing three schemas within the database to support a Medallion Architecture:
			- Bronze : Raw Ingestion layer - data loaded as-is from source CSV files
			- Silver : Cleaned and Standardized layer - Quality issues resolved
			- Gold : Analytical data mart - Star schema ready for reporting
Source Dats :
			- website_orders.csv         (50,000 rows - Web channel)
			- mobile_app_transaction.csv (27,000 rows - Mobile channel)
*********************************************************************************************/

USE master;

-- Drop and recreate the 'ShopSphereDB' Database

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ShopSphereDW')
BEGIN
	ALTER DATABASE ShopSphereDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ShopSphereDW;
END;
GO


-- Create the 'ShopSphereDW' Database

CREATE DATABASE ShopSphereDW;
GO

USE ShopSphereDW;

-- Create Medallion Architecture Schemas

CREATE SCHEMA bronze;      -- Raw ingestion: No transformation permitted
GO

CREATE SCHEMA silver;      -- Cleaned data : standardized, deduplicated, validated
GO

CREATE SCHEMA gold;        -- Analytical mart : Star schema for reporting and insights
GO

