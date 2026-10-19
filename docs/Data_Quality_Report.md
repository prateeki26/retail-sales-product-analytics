# Data Quality & Validation Report

## 1. Executive Reconciliation Summary

All data transformations and models were audited against the raw source files (`data/Transactions.csv`, `data/Products.csv`) and the analytical SQLite database (`retail_analytics.db`).

| Validation Check | Source Data / SQL Target | Power Query / Model Result | Variance | Status |
| :--- | :---: | :---: | :---: | :---: |
| **Receipt Count (`Transactions`)** | 53,820 | 53,820 | 0 | **PASS** |
| **Distinct `ReceiptNumber`** | 53,820 | 53,820 | 0 | **PASS** (100% Unique PK) |
| **Gross Total Amount** | 1,315,276,000.00 | 1,315,276,000.00 | 0.00 | **PASS** |
| **Net Sales Total** | 1,184,933,340.54 | 1,184,933,340.54 | 0.00 | **PASS** |
| **Tax Total** | 130,342,659.46 | 130,342,659.46 | 0.00 | **PASS** |
| **Net + Tax Accounting Integrity** | 1,315,276,000.00 | 1,315,276,000.00 | 0.00 | **PASS** (Net + Tax = Total) |
| **Split Item Occurrences** | 61,973 | 61,973 | 0 | **PASS** |
| **Product Catalogue Rows** | 96 | 96 | 0 | **PASS** |
| **Catalogue Label Uniqueness** | 96 | 96 | 0 | **PASS** (0 Duplicates) |
| **Matched Line Items** | 61,973 | 61,973 | 0 | **PASS** (100% Matched) |
| **Unmatched Line Items (`ProductId is null`)** | 0 | 0 | 0 | **PASS** (0 Unmatched) |

---

## 2. In-Depth Data Profiling Results

### A. Receipts Table (`Transactions`)
* **Total Transactions**: 53,820 receipts.
* **Positive Revenue Receipts**: 52,087 receipts (96.78%).
* **Zero Total Receipts**: 1,733 receipts (3.22%).
  - Profiling reveals these transactions have `TotalAmount = 0`, `NetSales = 0`, and `Tax = 0`.
  - These represent promotional items, loyalty redemptions, staff drinks, or complimentary orders.
  - They are preserved in the model to maintain accurate foot-traffic counts and operational demand analysis.
* **Negative Values**: **0 negative receipts**. There are no recorded product returns, refunds, or reversals in the dataset.
* **Date Range**: January 2, 2025 through September 30, 2025 (272 continuous days across 9 months).
* **Missing Dates or Nulls**: 0 null dates.

### B. Product Catalog (`Products`)
* **Total SKUs**: 96 items across 6 categories.
* **Primary Key**: `ProductId` (integer 1 to 96, 100% unique).
* **Price Range**:
  - Minimum Price: `0.00` (e.g., `Add on Aren`, `Add on Simple Syrup`).
  - Maximum Price: `30,000.00` (`Americano Ice Houseblend Gedhe`, `Friendly Coffee Hot Gedhe`).
  - Mean Price: `21,468.75`.
* **Standardized Matching Labels**:
  - Formula: `ProductName & " (" & Variant & ")"` (unless Variant is null, blank, or `"-"`).
  - All 96 items produced distinct labels (`Products_DuplicateCheck` = 0 rows).

### C. Matching Integrity (`TransactionItems_Matched`)
* Delimiter splitting on `", "` across 53,820 receipts produced 61,973 line items.
* Joining `ItemName` against `ProductMatchLabel` via Left Outer Join resulted in:
  - **Matched Rows**: 61,973 (100.00%).
  - **Unmatched Rows**: 0 (0.00%).
  - **Join Row Variance**: `0` (no dropped rows, no Cartesian fan-out).

---

## 3. Financial Reconciliations by Outlet

| Outlet | Receipt Count | % Receipts | Total Amount | Net Sales | Tax | Avg Receipt Total |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **`SHOP001`** | 26,250 | 48.77% | 644,108,000.00 | 580,277,481.03 | 63,830,518.97 | 24,537.45 |
| **`SHOP003`** | 16,753 | 31.13% | 409,504,000.00 | 368,922,524.74 | 40,581,475.26 | 24,443.62 |
| **`SHOP002`** | 10,817 | 20.10% | 261,664,000.00 | 235,733,334.77 | 25,930,665.23 | 24,189.89 |
| **Total** | **53,820** | **100.00%** | **1,315,276,000.00** | **1,184,933,340.54** | **130,342,659.46** | **24,438.42** |
