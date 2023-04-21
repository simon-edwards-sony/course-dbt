# Section 1
### What is our user repeat rate?
**79.84%**
        
        WITH orders AS
        (
            SELECT DISTINCT
                USER_ID,
                COUNT(DISTINCT ORDER_ID) AS CNT_ORDERS
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_POSTGRES__ORDERS
            GROUP BY 1
        ), totals AS
        (
            SELECT
                COUNT(*) AS "num_customers",
                SUM(CASE WHEN CNT_ORDERS = 1 THEN 1 ELSE 0 END) AS "single_orders",
                SUM(CASE WHEN CNT_ORDERS > 1 THEN 1 ELSE 0 END) AS "repeat_orders"
            FROM orders
        )

### What are good indicators of a user who will likely purchase again?
- High number of purchases per week
- Added items to basket but not purchased

### What about indicators of users who are likely NOT to purchase again?
- Long time since last purchase
- No activity from user

### If you had more data, what features would you want to look into to answer this question?
- Grouping users that add items to basket without purchasing to create targeted promotions (we have this data)
- Holiday data - Black friday, Easter, Christmas etc
- Survey data
- Product types
- Upcoming products - New plants similar to types that are purchased frequently

# Data Marts

### Explain the product mart models you added. Why did you organize the models in the way you did?
- Created int_postgres__product_views intermediate table to combine the majority of the information required for fact_postgres__product_views:
  - Views per product
  - Which of these products were added to cart and when
  - Which of these products were checked out and when
  - Additional information such as product name, price, customer name, shipping status were included

- Created fact_postgres__product_views:
  - This includes the majority of the information from int_postgres__product_views
  - The extra metadata such as product name, price, user name are included but can be omitted as they're able to be joined from the dimensions / facts
  - This table has multiple purposes and can answer many questions such as how many products are getting views and which ones of these yield orders, all seperatable by user_id

- Created fact_postgres__orders:
  - This includes all information from stg_postgres__orders but also contains the address
  - The address was included as the address on the user could differ

- Created dim_postgres__products:
  - Contains all product info, no joins necassary
  - This could be useful if we want to check the correlation between page views and if stock levels were sufficient

- Created dim_postgres__users:
  - Contains all user info, as well as addresses