# Measures Dictionary

This document details every DAX measure created in the project, including its mathematical formula, business definition, formatting, and verified benchmark target.

---

## 1. Financial & Revenue Measures

### `[Total Sales Amount]`
* **DAX Expression**:
  ```dax
  Total Sales Amount = SUM(Transactions[TotalAmount])
  ```
* **Format String**: `#,##0.00` (Neutral numeric format)
* **Table**: `Transactions` (Receipt Header)
* **Business Definition**: Total gross revenue collected from customers across all receipts, including recorded sales tax.
* **Verified Benchmark**: `1,315,276,000.00`

---

### `[Total Net Sales]`
* **DAX Expression**:
  ```dax
  Total Net Sales = SUM(Transactions[NetSales])
  ```
* **Format String**: `#,##0.00`
* **Table**: `Transactions` (Receipt Header)
* **Business Definition**: Total net revenue recognized by the business before sales tax.
* **Verified Benchmark**: `1,184,933,340.54`

---

### `[Total Tax]`
* **DAX Expression**:
  ```dax
  Total Tax = SUM(Transactions[Tax])
  ```
* **Format String**: `#,##0.00`
* **Table**: `Transactions` (Receipt Header)
* **Business Definition**: Total sales tax collected across all transactions.
* **Accounting Check**: `[Total Net Sales] + [Total Tax] = 1,315,276,000.00` (Exact 0.00 variance).
* **Verified Benchmark**: `130,342,659.46`

---

## 2. Volume & Basket Size Measures

### `[Transaction Count]`
* **DAX Expression**:
  ```dax
  Transaction Count = DISTINCTCOUNT(Transactions[ReceiptNumber])
  ```
* **Format String**: `#,##0`
* **Table**: `Transactions`
* **Business Definition**: The total count of unique customer receipts processed by the POS system.
* **Verified Benchmark**: `53,820`

---

### `[Average Transaction Value]` (ATV / AOV)
* **DAX Expression**:
  ```dax
  Average Transaction Value = 
  DIVIDE(
      [Total Sales Amount],
      [Transaction Count],
      0
  )
  ```
* **Format String**: `#,##0.00`
* **Table**: `Transactions`
* **Business Definition**: The average gross spend per customer receipt across all transactions.
* **Verified Benchmark**: `24,438.42` (`1,315,276,000.00 / 53,820`)

---

### `[Average Positive Transaction Value]`
* **DAX Expression**:
  ```dax
  Average Positive Transaction Value = 
  DIVIDE(
      [Total Sales Amount],
      CALCULATE([Transaction Count], Transactions[TotalAmount] > 0),
      0
  )
  ```
* **Format String**: `#,##0.00`
* **Table**: `Transactions`
* **Business Definition**: Average spend per receipt on paying transactions, excluding the 1,733 zero-value receipts.
* **Verified Benchmark**: `25,251.52` (Matches `sql/01_sales_kpi_summary.sql`)

---

## 3. Line-Item & Product Performance Measures

### `[Total Items Sold]`
* **DAX Expression**:
  ```dax
  Total Items Sold = COUNTROWS(TransactionItems_Matched)
  ```
* **Format String**: `#,##0`
* **Table**: `TransactionItems_Matched` (Line Item Fact)
* **Business Definition**: Total count of individual product occurrences across all customer baskets.
* **Modeling Note**: Each row in `TransactionItems_Matched` represents exactly 1 unit occurrence. `TotalAmount` is intentionally excluded from this table to prevent double-counting.
* **Verified Benchmark**: `61,973`

---

### `[Average Items Per Transaction]`
* **DAX Expression**:
  ```dax
  Average Items Per Transaction = 
  DIVIDE(
      [Total Items Sold],
      [Transaction Count],
      0
  )
  ```
* **Format String**: `#,##0.00`
* **Table**: `TransactionItems_Matched`
* **Business Definition**: The average number of line items purchased per customer transaction.
* **Verified Benchmark**: `1.15 items/receipt` (`61,973 / 53,820`)

---

### `[% Share of Total Items Sold]`
* **DAX Expression**:
  ```dax
  % Share of Total Items Sold = 
  DIVIDE(
      [Total Items Sold],
      CALCULATE([Total Items Sold], ALLSELECTED(TransactionItems_Matched)),
      0
  )
  ```
* **Format String**: `0.00%`
* **Table**: `TransactionItems_Matched`
* **Business Definition**: Percentage of total unit sales accounted for by a selected product or category.
* **Verified Benchmarks**:
  - `Coffee`: **36.18%** (22,422 units)
  - `Menu Gedhe`: **20.30%** (12,581 units)
  - `Other`: **16.13%** (9,995 units)
  - `Tea`: **13.71%** (8,494 units)
  - `Snacks`: **9.41%** (5,832 units)
  - `Add on`: **4.27%** (2,649 units)
