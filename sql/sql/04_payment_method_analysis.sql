-- Project: Retail Sales & Product Performance Analytics
-- Query: Payment Method Analysis

SELECT
    PaymentMethod AS payment_method,

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
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM transactions),
        2
    ) AS percentage_of_transactions,

    ROUND(
        AVG(
            CASE
                WHEN CAST(TotalAmount AS REAL) > 0
                THEN CAST(TotalAmount AS REAL)
            END
        ), 2
    ) AS average_positive_receipt_total

FROM transactions

GROUP BY PaymentMethod

ORDER BY total_amount_including_tax DESC;