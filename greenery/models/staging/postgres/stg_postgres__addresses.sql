{{
  config(
    materialized='table'
  )
}}

WITH addresses_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'addresses') }}
)

SELECT 
    ADDRESS_ID,
    ADDRESS,
    ZIPCODE,
    STATE,
    COUNTRY
FROM addresses_source