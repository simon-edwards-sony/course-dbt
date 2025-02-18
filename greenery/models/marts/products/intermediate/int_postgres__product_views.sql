{{
  config(
    materialized='table'
  )
}}

WITH stg_products AS (
  SELECT
    *
  FROM {{ ref('stg_postgres__products') }}
), stg_users AS
(
  SELECT
    *
  FROM {{ ref('stg_postgres__users') }}
), stg_events AS
(
  SELECT
    *
  FROM {{ ref('stg_postgres__events') }}
), stg_orders AS
(
  SELECT
    *
  FROM {{ ref('stg_postgres__orders') }}
), product_view_events AS
(
  SELECT
    EVENT_ID::text AS VIEW_ID,
    PRODUCT_ID::text AS PRODUCT_ID,
    PAGE_URL,
    SESSION_ID::text AS SESSION_ID,
    USER_ID,
    CREATED_AT AS VIEW_DATE,
    ROW_NUMBER() OVER (PARTITION BY SESSION_ID, PRODUCT_ID ORDER BY CREATED_AT ASC) AS SESSION_VIEW_COUNT,
    ROW_NUMBER() OVER (PARTITION BY SESSION_ID, PRODUCT_ID ORDER BY CREATED_AT DESC) AS SESSION_VIEW_COUNT_INV
  FROM stg_events
  WHERE EVENT_TYPE = 'page_view'
), add_to_cart_events AS
(
  SELECT
    SESSION_ID,
    PRODUCT_ID,
    MAX(CREATED_AT) AS ADD_TO_CART_DATE
  FROM stg_events
  WHERE EVENT_TYPE = 'add_to_cart'
  GROUP BY 1,2
), order_events AS
(
  SELECT
    SESSION_ID,
    ORDER_ID,
    MAX(CASE WHEN EVENT_TYPE = 'checkout' THEN CREATED_AT END) AS CHECKOUT_DATE,
    MAX(CASE WHEN EVENT_TYPE = 'package_shipped' THEN CREATED_AT END) AS SHIP_DATE
  FROM stg_events
  WHERE EVENT_TYPE IN ('checkout', 'package_shipped') AND ORDER_ID IS NOT NULL
  GROUP BY 1,2
)

SELECT
  VE.VIEW_ID,
  VE.SESSION_ID,
  VE.PRODUCT_ID,
  P.NAME::text AS PRODUCT_NAME,
  P.PRICE AS PRODUCT_PRICE,
  VE.PAGE_URL AS PRODUCT_URL,
  VE.USER_ID AS USER_ID,
  U.FIRST_NAME || ' ' || U.LAST_NAME AS USER_FULL_NAME,
  OE.ORDER_ID,
  O.STATUS AS ORDER_STATUS,
  VE.SESSION_VIEW_COUNT,
  VE.VIEW_DATE,
  CE.ADD_TO_CART_DATE,
  OE.CHECKOUT_DATE,
  OE.SHIP_DATE,
  O.DELIVERED_AT AS DELIVERY_DATE
FROM product_view_events VE
LEFT JOIN add_to_cart_events CE ON VE.SESSION_ID = CE.SESSION_ID AND VE.PRODUCT_ID = CE.PRODUCT_ID AND VE.SESSION_VIEW_COUNT_INV = 1
LEFT JOIN order_events OE ON VE.SESSION_ID = OE.SESSION_ID AND CE.ADD_TO_CART_DATE IS NOT NULL
LEFT JOIN stg_products P ON VE.PRODUCT_ID = P.PRODUCT_ID
LEFT JOIN stg_users U ON VE.USER_ID = U.USER_ID
LEFT JOIN stg_orders O ON OE.ORDER_ID = O.ORDER_ID
ORDER BY VIEW_DATE