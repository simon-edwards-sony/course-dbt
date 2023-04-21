{{
  config(
    materialized='table'
  )
}}

WITH orders_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'orders') }}
)

SELECT 
    ORDER_ID,
    USER_ID,
    PROMO_ID,
    ADDRESS_ID,
    CREATED_AT,
    ROUND(ORDER_COST, 2) AS ORDER_COST,
    ROUND(SHIPPING_COST, 2) AS SHIPPING_COST,
    ROUND(ORDER_TOTAL, 2) AS ORDER_TOTAL,
    TRACKING_ID,
    SHIPPING_SERVICE,
    ESTIMATED_DELIVERY_AT,
    DELIVERED_AT,
    STATUS
FROM orders_source