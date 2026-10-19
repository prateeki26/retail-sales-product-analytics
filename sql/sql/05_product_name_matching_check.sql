-- Project: Retail Sales & Product Performance Analytics
-- Query: Product Name Matching Check

WITH RECURSIVE item_split AS (
    SELECT
        ReceiptNumber,

        TRIM(
            SUBSTR(
                Items || ',',
                1,
                INSTR(Items || ',', ',') - 1
            )
        ) AS item_name,

        SUBSTR(
            Items || ',',
            INSTR(Items || ',', ',') + 1
        ) AS remaining_items

    FROM transactions
    WHERE Items IS NOT NULL
      AND TRIM(Items) <> ''

    UNION ALL

    SELECT
        ReceiptNumber,

        TRIM(
            SUBSTR(
                remaining_items,
                1,
                INSTR(remaining_items, ',') - 1
            )
        ) AS item_name,

        SUBSTR(
            remaining_items,
            INSTR(remaining_items, ',') + 1
        ) AS remaining_items

    FROM item_split
    WHERE remaining_items <> ''
),

product_catalog AS (
    SELECT
        ProductId,

        CASE
            WHEN Variant IS NULL
              OR TRIM(Variant) IN ('', '-')
            THEN TRIM(ProductName)

            ELSE TRIM(ProductName)
                 || ' (' || TRIM(Variant) || ')'
        END AS product_label

    FROM products
),

matched_items AS (
    SELECT
        i.ReceiptNumber,
        i.item_name,
        p.ProductId

    FROM item_split AS i

    LEFT JOIN product_catalog AS p
        ON LOWER(TRIM(i.item_name))
         = LOWER(TRIM(p.product_label))

    WHERE i.item_name <> ''
)

SELECT
    CASE
        WHEN ProductId IS NULL THEN 'Unmatched'
        ELSE 'Matched'
    END AS match_status,

    COUNT(*) AS item_occurrences,

    COUNT(DISTINCT ReceiptNumber) AS receipts_affected

FROM matched_items

GROUP BY
    CASE
        WHEN ProductId IS NULL THEN 'Unmatched'
        ELSE 'Matched'
    END

ORDER BY match_status;