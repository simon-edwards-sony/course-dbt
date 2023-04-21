WITH fact_orders AS (
  SELECT
    *
  FROM {{ source('fact_postgres', 'fact_postgres__orders') }}
)

SELECT
    ORDER_ID,
    SUM(ORDER_COST + SHIPPING_COST)::float - SUM(PROMO_DISCOUNT)::float AS ORDER_TOTAL_CALC,
    SUM(ORDER_TOTAL)::text AS ORDER_TOTAL_ACTUAL
FROM fact_orders
GROUP BY 1
HAVING NOT (ORDER_TOTAL_CALC = ORDER_TOTAL_ACTUAL)