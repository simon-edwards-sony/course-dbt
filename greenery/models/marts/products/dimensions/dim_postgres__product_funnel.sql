{{
  config(
    materialized='table'
  )
}}

WITH int_product_views AS (
  SELECT
    *
  FROM {{ ref('int_postgres__product_views') }}
), session_agg AS
(
  SELECT
    SESSION_ID,
    SUM(CASE WHEN ADD_TO_CART_DATE IS NOT NULL THEN 1 ELSE 0 END) AS ADDED_TO_CART,
    SUM(CASE WHEN CHECKOUT_DATE IS NOT NULL THEN 1 ELSE 0 END) AS CHECKOUTS
  FROM int_product_views
  GROUP BY 1
)

SELECT
  COUNT(*) product_views_total,
  SUM(CASE WHEN ADDED_TO_CART > 0 THEN 1 ELSE 0 END) AS added_to_cart_total,
  SUM(CASE WHEN CHECKOUTS > 0 THEN 1 ELSE 0 END) AS checkouts_total,
  ROUND(DIV0(added_to_cart_total, product_views_total), 4) AS added_to_cart_pct,
  ROUND(DIV0(checkouts_total, product_views_total), 4) AS checkouts_pct,
  product_views_total - added_to_cart_total AS added_to_cart_dropoff_total,
  product_views_total - checkouts_total AS checkouts_dropoff_total,
  ROUND(1 - added_to_cart_pct, 4) AS added_to_cart_dropoff_pct,
  ROUND(1 - checkouts_pct, 4) AS checkouts_dropoff_pct,
  ROUND(DIV0(checkouts_total, added_to_cart_total), 4) AS checkouts_pct_fromcart,
  added_to_cart_total - checkouts_total AS checkouts_dropoff_total_fromcart,
  ROUND(1 - checkouts_pct_fromcart, 4) AS checkouts_dropoff_pct_fromcart
FROM session_agg