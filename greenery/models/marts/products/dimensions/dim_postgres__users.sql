{{
  config(
    materialized='table'
  )
}}

WITH stg_users AS (
  SELECT
    *
  FROM {{ source('stg_postgres', 'stg_postgres__users') }}
), stg_addresses AS (
  SELECT
    *
  FROM {{ source('stg_postgres', 'stg_postgres__addresses') }}
)

SELECT
    U.USER_ID,
    U.FIRST_NAME,
    U.LAST_NAME,
    U.FIRST_NAME || ' ' || U.LAST_NAME AS FULL_NAME,
    U.EMAIL,
    U.PHONE_NUMBER,
    U.CREATED_AT AS ACCOUNT_CREATED_DATE,
    U.UPDATED_AT AS LAST_UPDATED_DATE,
    A.ADDRESS,
    A.ZIPCODE,
    A.STATE,
    A.COUNTRY
FROM stg_users U
LEFT JOIN stg_addresses A ON U.ADDRESS_ID = A.ADDRESS_ID