# ShopSphere Data Warehouse & Analytics Project

Welcome to the **ShopSphere Data Warehouse and Analytics Project** 🚀

This repository showcases a **complete end-to-end data warehousing and analytics build** for a global e-commerce retailer operating two independent sales channels — a legacy website platform and a fast-growing mobile app.

Built as a **hands-on portfolio project**, it applies core data engineering and analytics practices: Medallion Architecture design, multi-source data integration, data quality management, and SQL-driven business analysis.

---

## 🚀 Project Objectives

### Data Warehouse Build (Data Engineering)

**Goal:** Design a modern data warehouse in **SQL Server** that consolidates transaction data from two channels into a single, analysis-ready model.

**Scope covered:**
- **Sources**: Two independent systems (Website + Mobile App), delivered as raw CSV exports
- **Cleaning**: Resolved mixed date formats, inconsistent status codes, corrupted currency encoding, duplicate rows, and null values
- **Integration**: Unified both sources into one star schema built for analytical querying
- **Timeframe**: Full 2-year history (January 2023 – December 2024)
- **Documentation**: Data model documented for both technical and business audiences

---

## 📊 Analytics & Reporting (Data Analysis)

**Goal:** Turn the warehouse into SQL-driven answers to real business questions.

- **Customer Behaviour** — RFM segmentation across 22,155 unique customers
- **Product Performance** — Revenue and volume across 80 products in 6 categories
- **Sales Trends** — Two years of monthly revenue across both channels
- **Promo Effectiveness** — Performance analysis of promo codes by type and tier
- **Strategic Recommendation** — Data-backed $500,000 ad spend allocation

---

## 🏗️ Medallion Architecture

Built on a standard three-layer pipeline:

```
Bronze (Raw Ingestion)
    └── Silver (Cleaning & Standardization)
            └── Gold (Star Schema & Analytics)
```

| Layer  | Purpose | Load Type |
|--------|---------|-----------|
| Bronze | Raw ingestion — no transformations, all columns NVARCHAR | TRUNCATE + BULK INSERT |
| Silver | Cleaning, deduplication, type casting, standardization | TRUNCATE + CTE INSERT |
| Gold   | Star schema — surrogate keys, USD conversion, quality flags | Full rebuild |

---

## 🗄️ Data Model

The Gold layer is a **dimensional star schema** built for fast analytical querying.

### Fact Table

**`fact_orders`**
- Total amount (source currency)
- Total amount USD (converted)
- Total amount recalculated USD (derived from components)
- Quantity, unit price, discount, shipping cost
- Order status
- Channel (Website / Mobile App)
- Data quality flags

### Dimension Tables

| Table | Description |
|-------|-------------|
| `dim_date` | Full calendar spine — `date_key` in YYYYMMDD format |
| `dim_customer` | Unified customer identity across both channels, with cross-channel flag |
| `dim_product` | 80 unified products across both channels |
| `dim_geography` | Country-level — US, UK, Germany, France |
| `dim_payment` | Payment methods, categorized as Card or Digital Wallet |
| `dim_promo` | Promo codes, typed by Seasonal / Flash / Welcome / VIP / Other |
| `dim_device` | iOS / Android / N/A (website orders) |

This design keeps queries fast and reporting intuitive across both channels.

---

## 🧪 Data Quality & Transformation

Applied in the Silver layer:

| Issue | Treatment |
|-------|-----------|
| Duplicate records | Removed via `ROW_NUMBER()` after normalization |
| Mixed date/timestamp formats | Pattern-matched with CASE logic → `TRY_CAST` to DATE/DATETIME |
| Null customer names | Replaced with `'Unknown'` |
| Null shipping addresses | Replaced with `'Not Provided'` |
| Null user emails | Replaced with `'Guest'` |
| Inconsistent status codes | Mapped to canonical values (Completed, Shipped, Pending, Cancelled, Delivered, Returned) |
| Corrupted currency encoding | Byte-level matching → ISO codes (USD/GBP/EUR) |
| Inconsistent product ID formats | Normalized to a single `PROD-NNN` format |
| Category aliases (23 variants) | Mapped to 6 canonical categories |
| Negative unit prices | Flagged (`is_negative_price`), excluded from revenue |
| Total amount mismatches | Flagged (`is_total_mismatch`); recalculated total added in Gold |

---

## 📈 Analytical Deliverables

### 1. 📋 Overview KPIs
Executive-level metrics across Revenue, Volume, Customer, Product, Geography, and Operational Health.

### 2. 👥 RFM Customer Segmentation
Scores every registered customer on Recency, Frequency, and Monetary value using `NTILE(5)`. Assigns 9 segment labels — from Champion to Lost — with a full channel breakdown.

### 3. 🛒 Market Basket Analysis
Finds product pairs most frequently bought together via self-join on website orders. Calculates support, confidence (A→B and B→A), and lift for every product combination.

### 4. 🎟️ Promo Code Effectiveness
Compares promo vs. non-promo orders on AOV, revenue contribution, redemption rate, estimated discount value, and customer spend tier.

### 5. 💰 $500K Ad Spend Recommendation
Revenue-proportional budget allocation across channel, geography, device, and product category — calculated directly from the fact table.

📄 **[View Full Insights & Recommendations →](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Exploration%20and%20Analysis/Insights_and_Recommendations.md)**

---

## 🛠️ Tools & Technologies

| Category | Technology |
|----------|-----------|
| Database | Microsoft SQL Server |
| Language | T-SQL |
| Architecture | Medallion (Bronze / Silver / Gold) |
| Data Modeling | Star Schema (Kimball) |
| Source Data | 2 CSV sources, 76,685+ rows combined |
| Ingestion | BULK INSERT |
| Transformation | CTEs, window functions, `TRY_CAST` |
| Analytics | SQL — RFM, basket analysis, KPI reporting |
| Version Control | Git & GitHub |

---

## 📁 Repository Structure

```
ShopSphere-Data-Warehouse-and-Analytics-Project/
│
├── Datasets/
│   ├── mobile_app_transactions.csv
│   └── website_orders.csv
│
├── Queries/
│   ├── 01_Datawarehouse___Schema_Creation.sql
│   ├── 02_Bronze_Layer_query.sql
│   ├── 03_Cleaning_text_query.sql
│   ├── 04_Silver_Layer_query.sql
│   ├── 05_Gold_Layer_query.sql
│   ├── 06_Post_Quality_Check.sql
│   └── 07_Full_Pipeline_run.sql
│
├── Exploration and Analysis/
│   ├── 08_Analysis_query.sql
│   └── Insights_and_Recommendations.md
│
├── LICENSE
└── README.md
```

---

## 🔄 Pipeline Orchestration

All load procedures run through a single master orchestrator:

```sql
EXEC run_full_pipeline
```

**Execution order:**
1. `bronze.load_bronze`
2. `silver.load_silver_website_orders`
3. `silver.load_silver_mobile_app_transactions`
4. `gold.load_gold`

Error handling and batch timing are logged at every stage.

---

## ▶️ How to Run

**Prerequisites:**
- Microsoft SQL Server 2019 or later
- SSMS or Azure Data Studio
- CSV dataset files

**Steps:**
1. Run [`01_Datawarehouse___Schema_Creation.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/01_Datawarehouse___Schema_Creation.sql) — creates the database and all three schemas
2. Update the file paths in [`02_Bronze_Layer_query.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/02_Bronze_Layer_query.sql) to point to your local CSVs, then run it
3. Run [`03_Cleaning_text_query.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/03_Cleaning_text_query.sql) to profile and identify data quality issues
4. Run [`04_Silver_Layer_query.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/04_Silver_Layer_query.sql), then [`05_Gold_Layer_query.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/05_Gold_Layer_query.sql)
5. Run [`06_Post_Quality_Check.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/06_Post_Quality_Check.sql) to validate Silver and Gold outputs
6. **Or** skip steps 2–4 by running [`07_Full_Pipeline_run.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/07_Full_Pipeline_run.sql) to execute Bronze → Silver → Gold in one shot
7. Run [`08_Analysis_query.sql`](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Exploration%20and%20Analysis/08_Analysis_query.sql) to generate all analytical outputs

---

## 📂 Quick Links

| Resource | Link |
|----------|------|
| Database & Schema Creation | [01_Datawarehouse___Schema_Creation.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/01_Datawarehouse___Schema_Creation.sql) |
| Bronze Layer | [02_Bronze_Layer_query.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/02_Bronze_Layer_query.sql) |
| Data Cleaning Checks | [03_Cleaning_text_query.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/03_Cleaning_text_query.sql) |
| Silver Layer | [04_Silver_Layer_query.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/04_Silver_Layer_query.sql) |
| Gold Layer | [05_Gold_Layer_query.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/05_Gold_Layer_query.sql) |
| Post-Load Quality Checks | [06_Post_Quality_Check.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/06_Post_Quality_Check.sql) |
| Full Pipeline (One-Click) | [07_Full_Pipeline_run.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Queries/07_Full_Pipeline_run.sql) |
| Analysis Queries | [08_Analysis_query.sql](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Exploration%20and%20Analysis/08_Analysis_query.sql) |
| Insights & Recommendations | [Insights_and_Recommendations.md](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/Exploration%20and%20Analysis/Insights_and_Recommendations.md) |

---

## 📖 Data Quality Notes

> **Known limitation — mobile app total mismatch:** The `is_total_mismatch` flag fires on a large share of mobile app transactions by design. The app's `gross_total` bakes in a promo discount that isn't stored as a separate column. The gap between `total_amount_usd` and `total_amount_recalc_usd` on app rows represents the estimated promo discount value. This is a source-system characteristic, not a pipeline defect.

---

## 📜 License

Licensed under the **MIT License** — see [LICENSE](https://github.com/babatunde-cp/ShopSphere-Data-Warehouse-and-Analytics-Project/blob/main/LICENSE) for details.

---

*Built by **Babatunde Kareem***
*Next iteration: incremental load pattern + indexing/performance optimization*
