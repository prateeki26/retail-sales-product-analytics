# Project Walkthrough & Data Analyst Interview Guide

This guide explains the end-to-end engineering, business intelligence reasoning, and story structure for presenting this project during data analyst technical interviews.

---

## 1. The 60-Second Elevator Pitch

> *"In this project, I built a complete retail sales and product performance analytics solution in Power BI and SQLite, analyzing over 53,000 transactions and 61,000 line items across three retail locations.*
>
> *The central data engineering challenge was that the raw point-of-sale data stored purchased items as comma-separated text strings at the receipt header grain. I used Power Query M to normalize and unpivot these items into discrete line items, then mapped them to a 96-item product catalog using a standardized label matching algorithm.*
>
> *Architecturally, I implemented a dual-fact dimensional star schema that strictly separated receipt-level financials from item-level volumes, completely preventing the common 'fan-out' trap that would have inflated revenue by 15% (over 200 million). Finally, I authored verified DAX measures and built an executive dashboard covering sales trends, outlet performance, and SKU demand distributions."*

---

## 2. Technical Interview Questions & Model Answers

### Q1: "How did you handle the comma-separated items column in Power Query?"
**Model Answer**:
> *"The raw POS table had an `Items` column containing strings like `'Friendly Coffee (Hot), Shakencano'`. In Power Query, I first referenced the base table and stripped out financial metrics (`TotalAmount`, `NetSales`, `Tax`) to isolate the grain. 
> 
> Next, I split the column on delimiter `', '` into a list, expanded the list into individual rows, trimmed whitespace, and filtered empty rows. This normalized the dataset from 53,820 receipts into exactly 61,973 item occurrences while preserving `ReceiptNumber`, `Outlet`, and `Date` on every line item."*

---

### Q2: "How did you join line items to your product catalogue, and why did you use a Left Outer join?"
**Model Answer**:
> *"The product catalogue stored `ProductName` and `Variant` in separate columns. I constructed a standardized lookup key in M: if `Variant` was null, blank, or hyphen, I kept `ProductName`; otherwise, I concatenated `ProductName & ' (' & Variant & ')'`.
> 
> I merged this against transaction items using a **Left Outer Join**. I avoided Inner Joins because if an item name had a typo or was missing from the catalogue, an Inner Join would silently drop that transaction row, falsifying our transaction volume. 
> 
> To validate the join, I created a dedicated audit query filtering for `ProductId = null`. The audit returned 0 rows, proving 100% of our 61,973 items successfully matched."*

---

### Q3: "What is the 'fan-out' problem, and how did you prevent revenue double-counting in DAX?"
**Model Answer**:
> *"Because receipt totals like `TotalAmount` were recorded once per receipt, copying that amount to every item on a multi-item receipt creates duplicate revenue. If a customer spent 35,000 on two items, attributing 35,000 to both items would report 70,000 in sales.
> 
> Across our 6,700+ multi-item receipts, this would have inflated reported revenue from 1.315 billion to 1.518 billion—an overstatement of over 203 million (+15.4%).
> 
> I resolved this by keeping `Transactions` as the Receipt Header Fact and `TransactionItems_Matched` as the Line Item Fact, connecting them with a 1-to-many single-direction relationship. Financial metrics (`SUM(TotalAmount)`, `SUM(NetSales)`) are calculated strictly from the header table, while product and category performance are analyzed using unit volume (`COUNTROWS`) and basket penetration (`DISTINCTCOUNT`)."*

---

### Q4: "Why didn't you add a currency symbol to the report?"
**Model Answer**:
> *"As a data analyst, I never assume business metadata that isn't established in documentation or source dictionaries. While product prices (5,000 to 30,000) and Indonesian menu names strongly suggest Indonesian Rupiah (IDR), the source documentation did not confirm it.
> 
> Rather than assuming USD or INR and misleading stakeholders, I maintained currency-neutral formatting (`#,##0.00`) and documented the limitation. In an enterprise environment, I would confirm currency codes with the data engineering or finance team."*

---

## 3. Dashboard Layout & Navigation Flow

1. **Top Slicers Bar**:
   - Allows users to slice by `Date Range`, `Outlet`, and `Product Category`.
2. **KPI Header Row**:
   - Instant visibility into Gross Revenue (1.32B), Total Transactions (53.8K), Average Spend (24.4K), and Units Sold (62.0K).
3. **Mid-Level Trends & Location Analysis**:
   - Monthly trend line/column combo shows revenue seasonality peaking in June/July 2025.
   - Outlet bar chart immediately highlights `SHOP001` as the powerhouse generating ~49% of all sales.
4. **Bottom-Level Product Performance**:
   - Top 10 Products horizontal bar chart visualizes fast-moving SKUs.
   - Donut chart breaks down category volume share, showing Coffee and Menu Gedhe driving over 56% of total unit sales.
