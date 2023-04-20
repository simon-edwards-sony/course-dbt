{{
  config(
    materialized='table'
  )
}}

WITH users_source AS (
  SELECT
    *
  FROM {{ source('postgres', 'users') }}
)

SELECT 
    USER_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE_NUMBER,
    CREATED_AT,
    UPDATED_AT,
    ADDRESS_ID
FROM users_source