{{
  config(
    materialized='table'
  )
}}

WITH order_items_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'order_items') }}
)

SELECT 
    ORDER_ID,
    PRODUCT_ID,
    QUANTITY
FROM order_items_source