{{
  config(
    materialized='table'
  )
}}

WITH promos_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'promos') }}
)

SELECT 
    PROMO_ID,
    ROUND(DISCOUNT, 2) AS DISCOUNT,
    STATUS
FROM promos_source