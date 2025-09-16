{{ config(materialized='table') }}

SELECT
    to_hex(md5(to_utf8(CAST(a.product_key as VARCHAR)))) as product_key,
    a.product_name,
    a.product_sku,
    a.product_color,
    b.subcategory_name,
    c.category_name
FROM {{ ref("stg_products") }} a
LEFT JOIN {{ ref("stg_product_subcategories") }} b
    ON a.product_subcategory_key = b.product_subcategory_key
LEFT JOIN {{ ref("stg_product_categories") }} c
    ON b.product_category_key = c.product_category_key