{{
  config(
    materialized='table'
  )
}}

WITH products_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'products') }}
)

SELECT 
    PRODUCT_ID,
    NAME,
    PRICE,
    INVENTORY
FROM products_source