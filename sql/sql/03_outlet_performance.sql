-- Project: Retail Sales & Product Performance Analytics
-- Query: Outlet Performance Analysis

SELECT
    Outlet AS outlet,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN CAST(TotalAmount AS REAL) > 0 THEN 1
            ELSE 0
        END
    ) AS positive_total_transactions,

    SUM(
        CASE
            WHEN CAST(TotalAmount AS REAL) = 0 THEN 1
            ELSE 0
        END
    ) AS zero_total_transactions,

    ROUND(
        SUM(CAST(TotalAmount AS REAL)), 2
    ) AS total_amount_including_tax,

    ROUND(
        SUM(CAST(NetSales AS REAL)), 2
    ) AS total_net_sales_excluding_tax,

    ROUND(
        AVG(
            CASE
                WHEN CAST(TotalAmount AS REAL) > 0
                THEN CAST(TotalAmount AS REAL)
            END
        ), 2
    ) AS average_positive_receipt_total

FROM transactions

GROUP BY Outlet

ORDER BY total_amount_including_tax DESC;