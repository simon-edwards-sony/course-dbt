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
    DISCOUNT,
    STATUS
FROM promos_source