{{
  config(
    materialized='table'
  )
}}

WITH stg_products AS (
  SELECT
    *
  FROM {{ ref('stg_postgres__products') }}
)

SELECT
    PRODUCT_ID,
    NAME AS PRODUCT_NAME,
    PRICE AS PRODUCT_PRICE,
    INVENTORY AS PRODUCT_INVENTORY
FROM stg_products