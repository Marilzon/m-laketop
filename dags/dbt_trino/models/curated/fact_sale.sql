{{ config(materialized='table') }}

SELECT
    a.order_date,
    a.order_number,
    to_hex(md5(to_utf8(CAST(a.product_key as VARCHAR)))) as product_key,
    to_hex(md5(to_utf8(c.country))) as country_key,
    (a.order_quantity * b.product_price) as revenue,
    (a.order_quantity * b.product_cost) as cost,
    (a.order_quantity * b.product_price) - (a.order_quantity * b.product_cost) as profit
FROM {{ ref("stg_sales") }} a
LEFT JOIN {{ ref("stg_products") }} b
    ON a.product_key = b.product_key
LEFT JOIN {{ ref("stg_territories") }} c
    ON a.territory_Key = c.sales_territory_key