# Known Limitations & Data Governance Disclosures

In enterprise analytics, documenting known data limitations and edge cases is essential for transparency and stakeholder alignment.

---

## 1. Currency Ambiguity
* **Observation**: Transaction amounts range into hundreds of millions (Total Gross: `1,315,276,000.00`), with individual item prices between `5,000` and `30,000`. Product names contain Indonesian terms (`"Air Mineral"`, `"Menu Gedhe"`, `"Gula Aren"`).
* **Limitation**: The raw CSV files and SQLite database schema lack an explicit ISO currency code (e.g. `IDR`, `USD`, `INR`).
* **Governance Action**: All amounts are formatted using neutral numeric representations (`#,##0.00`) without currency prefixes. Stakeholders must be informed that while prices empirically align with Indonesian Rupiah (IDR), currency certification remains pending financial sign-off.

---

## 2. Lack of Item-Level Historical Price Tracking
* **Observation**: In `Transactions.csv`, only the receipt-level `TotalAmount`, `NetSales`, and `Tax` are provided. The line-item table `TransactionItems_Matched` contains the product occurrences, but does not record the exact line-item transaction price charged at checkout.
* **Limitation**: If product catalogue prices change over time, calculating item-level revenue using `Products[Price]` would introduce historical pricing inaccuracies (Type 1 slowly changing dimension issue). Furthermore, calculating revenue as `Price * Quantity` might not reconcile to `TotalAmount` due to basket-level discounts or tax rounding.
* **Governance Action**: Product and category performance are strictly analyzed by **item volume** (`COUNTROWS`) and **basket frequency** (`DISTINCTCOUNT(ReceiptNumber)`), ensuring total financial reporting remains 100% reconciled to the official POS header ledger.

---

## 3. Zero-Value Promotional Receipts
* **Observation**: Exactly **1,733 receipts (3.22%)** out of 53,820 transactions have `TotalAmount = 0.00`, `NetSales = 0.00`, and `Tax = 0.00`.
* **Limitation**: Including these zero-dollar receipts in `Average Transaction Value` yields `24,438.42`, whereas calculating the average across only revenue-generating receipts yields `25,251.52`.
* **Governance Action**: Both metrics are provided in the measures dictionary (`[Average Transaction Value]` vs. `[Average Positive Transaction Value]`). Zero-dollar receipts are retained in the transaction table to ensure operational demand, footfall, and inventory deductions are fully captured.

---

## 4. Single Cross-Filter Direction by Design
* **Observation**: The relationship between `Transactions` and `TransactionItems_Matched` is set to `Single` direction (`Transactions` $\rightarrow$ `TransactionItems_Matched`).
* **Consequence**: Slicing the dashboard by `Category` or `ItemName` updates the item-level charts (Top 10 Products, Category Share, Items Sold), but does not filter the `Total Sales Amount` card or the `Sales by Outlet` chart.
* **Rationale**: This is a deliberate architectural constraint to prevent Cartesian revenue inflation (the multi-item basket fan-out problem).

---

## 5. Date Grain
* **Observation**: Transactions span from January 2, 2025 to September 30, 2025 (9 months). No data exists for Q4 2025.
* **Limitation**: Year-over-year (YoY) time intelligence measures cannot be computed without a preceding full calendar year of data (2024).
* **Governance Action**: Monthly trend analysis is evaluated using month-over-month (MoM) trajectory and seasonal comparison across the available 9 months.
