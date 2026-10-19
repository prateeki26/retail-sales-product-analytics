# Data Model Architecture & Governance

## 1. Dimensional Architecture

The analytical model is structured as a **Dual-Fact Star Schema**, engineered to separate receipt-level financial accounting from line-item product volume.

```
+-----------------------------------+               +-----------------------------------+
|            Transactions           | (1)       (*) |      TransactionItems_Matched     |
|         (Receipt Header Fact)     |-------------->|       (Line Item Fact)            |
|-----------------------------------|               |-----------------------------------|
| ReceiptNumber (PK)                |               | ReceiptNumber (FK)                |
| Outlet                            |               | Outlet                            |
| Date                              |               | Date                              |
| PaymentMethod                     |               | ItemName                          |
| TotalAmount                       |               | ProductId (FK)                    |
| NetSales                          |               | Category                          |
| Tax                               |               +-----------------------------------+
+-----------------------------------+                                 ^
                                                                      | (*)
                                                                      |
                                                                      | (1)
                                                    +-----------------------------------+
                                                    |              Products             |
                                                    |        (Product Dimension)        |
                                                    |-----------------------------------|
                                                    | ProductId (PK)                    |
                                                    | ProductName                       |
                                                    | Variant                           |
                                                    | Category                          |
                                                    | Price                             |
                                                    | ProductMatchLabel                 |
                                                    +-----------------------------------+
```

---

## 2. Table Grains & Key Design Decisions

| Table | Grain | Primary / Foreign Keys | Metric Scope | Row Count |
| :--- | :--- | :--- | :--- | :---: |
| **`Transactions`** | **1 row per customer receipt** | `ReceiptNumber` (PK) | Financial metrics: `Total Sales Amount`, `Net Sales`, `Tax`, `Transaction Count`, `Average Transaction Value` | **53,820** |
| **`TransactionItems_Matched`** | **1 row per item sold** | `ReceiptNumber` (FK), `ProductId` (FK) | Volume & penetration metrics: `Total Items Sold`, `% Share of Items Sold`, `Receipts Containing Product` | **61,973** |
| **`Products`** | **1 row per catalog product** | `ProductId` (PK), `ProductMatchLabel` (Unique) | Product hierarchy & dimension attributes: `ProductName`, `Variant`, `Category`, `Price` | **96** |

---

## 3. The Fan-Out Revenue Overstatement Proof (The Core Interview Talking Point)

### The Problem:
In point-of-sale systems, receipts often record `TotalAmount` once at the header level. When the comma-separated `Items` column is normalized (split) into multiple rows, multi-item receipts expand.

Suppose Receipt `#101` has:
- `Friendly Coffee (Hot)`
- `Shakencano`
- Receipt `TotalAmount` = **45,000**.

If `TotalAmount` were copied or summed down to the item level:
- Row 1: `Friendly Coffee (Hot)` $\rightarrow$ 45,000
- Row 2: `Shakencano` $\rightarrow$ 45,000
- **Total Reported: 90,000** (an artificial **100% inflation** of cash collected!).

### Empirical Verification:
Across the 53,820 transactions in this dataset:
- Total Receipts: **53,820**
- Total Split Line Items: **61,973**
- Multi-Item Receipts: **6,725 receipts** contain 2 or more items.
- If `TotalAmount` were summed over `TransactionItems_Matched`:
  $$\sum \text{Item-Level TotalAmount} = \mathbf{1,518,485,000.00}$$
  $$\sum \text{Receipt-Level TotalAmount} = \mathbf{1,315,276,000.00}$$
  $$\text{Overstatement} = +\mathbf{203,209,000.00}\; (+15.45\%)$$

### The Architectural Governance:
1. **Financial Isolation**: Revenue measures (`Total Sales Amount`, `Net Sales`, `Tax`) are strictly aggregated from `Transactions`.
2. **Product Performance via Volume**: Products and Categories are evaluated by **Units Sold (`COUNTROWS`)** and **Receipt Penetration (`DISTINCTCOUNT(ReceiptNumber)`)**.
3. **Single Direction Filtering**:
   - `Transactions` (1) $\rightarrow$ `TransactionItems_Matched` (*) is **Single Direction**.
   - `Products` (1) $\rightarrow$ `TransactionItems_Matched` (*) is **Single Direction**.
   - This ensures date and outlet selections filter line items, but item-level category filters do not inadvertently alter the header financial aggregates.

---

## 4. Relationship Matrix

| Primary Table (1) | Primary Key | Foreign Table (*) | Foreign Key | Cardinality | Cross Filter | Active |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| `Transactions` | `ReceiptNumber` | `TransactionItems_Matched` | `ReceiptNumber` | 1 to Many (`1:*`) | Single | Yes |
| `Products` | `ProductId` | `TransactionItems_Matched` | `ProductId` | 1 to Many (`1:*`) | Single | Yes |
