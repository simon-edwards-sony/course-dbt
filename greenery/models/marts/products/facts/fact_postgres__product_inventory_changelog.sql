{{
  config(
    materialized='table'
  )
}}

WITH products_snapshot AS (
  SELECT
    *
  FROM {{ ref('products_snapshot') }}
)

SELECT
  SS1.dbt_valid_to AS change_date,
  SS1.product_id AS product_id,
  SS1.name AS product_name,
  SS1.inventory AS changed_from,
  SS2.inventory AS changed_to
FROM products_snapshot SS1
JOIN products_snapshot SS2 ON SS1.product_id = SS2.product_id AND SS1.dbt_valid_to = SS2.dbt_valid_from