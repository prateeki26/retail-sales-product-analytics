# Retail Sales & Product Performance Analytics

## Project Overview
This repository contains a **validated Power BI portfolio project** that demonstrates end‑to‑end analytics for a retail business. The solution showcases:
- **Data ingestion & transformation** via Power Query (M scripts) – splitting transaction items, matching products, and generating validation queries.
- **Data validation** using a Validation Scorecard that checks for duplicate product labels, unmatched product IDs, and other quality rules.
- **A semantic model** with five core tables (`Transactions`, `Products`, `TransactionItems`, `TransactionItems_Matched`, `Validation_Scorecard`).
- **A rich report** (`Retail_Sales_Analytics.pbip`) built entirely with DAX measures and visual configurations.
- **Supporting SQL scripts** that reproduce the analytical queries against the source database.

## Dataset Overview (not included)
The original dataset resides outside this repository (CSV files and a SQLite DB).  It contains:
- **53,820** transaction (receipt) rows.
- **61,973** item‑level rows.
- **Total sales amount** ≈ **1,315,276,000** (currency‑neutral).
- **Average transaction value** **24,438.42**.

> **Note:** To run the Power Query scripts you must have a copy of the source data and update the file paths in the `.m` files accordingly. The repository does **not** include any raw data for privacy reasons.

## Report Pages & Visuals
| Page | Visual | Purpose |
|------|--------|---------|
| Executive Overview | KPI cards – Total Sales, Transaction Count, Average Transaction Value, Total Items Sold | High‑level performance summary |
|  | Monthly sales & transaction trend (line‑chart) | Shows sales and transaction counts per month |
|  | Sales by outlet (bar‑chart) | Outlet‑wise revenue ranking |
|  | Items sold by product (bar‑chart) – **Top 10 Products** (Top N filter, descending by *Total Items Sold*) |
|  | Items sold by category (stacked bar) | Category contribution |
|  | Slicers – Date, Outlet, Category | Interactive filtering |

The **Top 10 Products** visual includes an explicit `TopN` filter limiting the result set to the ten highest‑selling products, sorted descending by *Total Items Sold*.

## Technologies Used
- **Power BI Desktop** (v2.159.883.0) – PBIP project format
- **Power Query (M)** – data shaping scripts
- **DAX** – measures for KPIs and calculations
- **SQL** – reference queries for verification
- **Git & GitHub** – source control and portfolio hosting

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/prateeki26/retail-sales-product-analytics.git
   ```
2. Open `Retail_Sales_Analytics.pbip` in Power BI Desktop.
3. Update the Power Query source paths in the `powerquery/` folder to point at your local copies of the CSV files (e.g., `E:\path\to\data\transactions.csv`).
4. Refresh the model – the data validation queries will run automatically and populate the Validation Scorecard.
5. Explore the report pages and interact with the slicers.

## Key Findings
- The validation step confirmed **zero unmatched product IDs** and **zero duplicate product labels**.
- Sales are heavily concentrated in the top 10 products (as shown by the dedicated visual).
- Monthly trends reveal a strong seasonal peak in Q3 2025.

## Repository Structure
```
Retail_Sales_Analytics/
├─ .gitignore
├─ Retail_Sales_Analytics.pbip               # Entry point
├─ Retail_Sales_Analytics.Report/           # Report definition
├─ Retail_Sales_Analytics.SemanticModel/    # Semantic model files
├─ sql/                                     # SQL analysis scripts
│   ├─ 01_sales_kpi_summary.sql
│   ├─ 02_monthly_sales_trends.sql
│   ├─ 03_outlet_performance.sql
│   ├─ 04_payment_method_analysis.sql
│   ├─ 05_product_name_matching_check.sql
│   ├─ 06_top_products.sql
│   └─ 07_category_analysis.sql
├─ powerquery/                              # Power Query M scripts
│   ├─ All_Validation_Queries_Bundle.m
│   ├─ Master_Validation_Scorecard.m
│   ├─ Matching_Validation_Summary.m
│   ├─ Products_DuplicateCheck.m
│   ├─ TransactionItems_Matched.m
│   └─ UnmatchedItems_Audit.m
├─ docs/                                    # Documentation
│   ├─ Data_Model_Architecture.md
│   ├─ Data_Quality_Report.md
│   ├─ Known_Limitations.md
│   ├─ Measures_Dictionary.md
│   ├─ Project_Walkthrough.md
│   └─ Report_Layout_Blueprint.md
└─ README.md                               # This file
```
