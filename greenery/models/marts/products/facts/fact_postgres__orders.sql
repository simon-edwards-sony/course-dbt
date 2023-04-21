{{
  config(
    materialized='table'
  )
}}

WITH stg_orders AS (
  SELECT
    *
  FROM {{ ref('stg_postgres__orders') }}
), stg_promos AS (
  SELECT
    *
  FROM {{ ref('stg_postgres__promos') }}
), stg_addresses AS (
  SELECT
    *
  FROM {{ ref('stg_postgres__addresses') }}
)

SELECT
  O.ORDER_ID,
  O.USER_ID,
  O.CREATED_AT AS ORDER_DATE,
  O.ORDER_COST,
  O.SHIPPING_COST,
  O.ORDER_TOTAL,
  P.PROMO_ID AS PROMO_ID,
  P.DISCOUNT AS PROMO_DISCOUNT,
  CASE 
      WHEN P.STATUS = 'active' THEN TRUE
      WHEN P.STATUS = 'inactive' THEN FALSE
      ELSE NULL
  END AS PROMO_IS_STILL_ACTIVE,
  O.TRACKING_ID,
  O.SHIPPING_SERVICE,
  A.ADDRESS,
  A.ZIPCODE,
  A.STATE,
  A.COUNTRY,
  O.ESTIMATED_DELIVERY_AT AS ESTIMATED_DELIVERY_DATE,
  O.DELIVERED_AT AS DELIVERY_DATE,
  O.STATUS AS ORDER_STATUS
FROM stg_orders O
LEFT JOIN stg_promos P ON O.PROMO_ID = P.PROMO_ID
LEFT JOIN stg_addresses A ON O.ADDRESS_ID = A.ADDRESS_ID
