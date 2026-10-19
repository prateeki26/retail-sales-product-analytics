-- Project: Retail Sales & Product Performance Analytics
-- Query: Product Category Analysis

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
        Category,
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
        p.ProductId,
        p.Category
    FROM item_split AS i
    INNER JOIN product_catalog AS p
        ON LOWER(TRIM(i.item_name))
         = LOWER(TRIM(p.product_label))
    WHERE i.item_name <> ''
)

SELECT
    Category AS product_category,
    COUNT(*) AS item_occurrences,
    COUNT(DISTINCT ReceiptNumber)
        AS receipts_containing_category,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM matched_items),
        2
    ) AS percentage_of_item_occurrences
FROM matched_items
GROUP BY Category
ORDER BY item_occurrences DESC;