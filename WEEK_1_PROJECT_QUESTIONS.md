#  How many users do we have?
**130 Users**
        
        SELECT COUNT(DISTINCT USER_ID)
        FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_USERS

# On average, how many orders do we receive per hour?
**7.52**

        SELECT ROUND(AVG(TOTAL_ORDERS), 2) AS "AVG_ORDERS_PER_HOUR"
        FROM
        (
            SELECT 
                DATE_TRUNC(hour, CREATED_AT) AS ORDER_HOUR,
                COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_ORDERS
            GROUP BY 1
        )

# On average, how long does an order take from being placed to being delivered?
**93.4 Hours / 3.89 Days**

        SELECT
            ROUND(AVG(TIMEDIFF(minutes, CREATED_AT, DELIVERED_AT) / 60), 2) AS HOURS_TO_DELIVER,
            ROUND(AVG(TIMEDIFF(minutes, CREATED_AT, DELIVERED_AT) / 1440), 2) AS DAYS_TO_DELIVER
        FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_ORDERS
        WHERE STATUS = 'delivered'

# How many users have only made one purchase? Two purchases? Three+ purchases?
**1 Order = 25 Users**

**2 Orders = 28 Users**

**3+ Orders = 71 Users**

        SELECT
            CASE 
                WHEN NUM_ORDERS >= 3 THEN '3+' 
                ELSE CAST(NUM_ORDERS AS VARCHAR)
            END AS ORDER_TOTAL,
            COUNT(USER_ID) AS NUM_USERS
        FROM
        (
            SELECT 
                USER_ID,
                COUNT(ORDER_ID) AS NUM_ORDERS
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_ORDERS
            GROUP BY 1
        )
        GROUP BY 1
        ORDER BY 1

# On average, how many unique sessions do we have per hour?
**16.33**
        
        SELECT ROUND(AVG(NUM_SESSIONS), 2) AS "AVG_SESSIONS"
        FROM
        (
            SELECT DISTINCT
                DATE_TRUNC(hour, CREATED_AT) AS SESSION_HOUR,
                COUNT(DISTINCT SESSION_ID) AS NUM_SESSIONS
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_EVENTS
            GROUP BY 1
        )

**Although we appear to have a session per hour, this may not always be the case. A better way to do this may be to create a list of hours from the min/max or sessions and join the counts to that in order to return 0 for any hours with no sessions**

        WITH RECURSIVE hours AS
        (
            SELECT
                MIN(DATE_TRUNC(hour, CREATED_AT)) AS HOUR
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_EVENTS
            UNION ALL
            SELECT
                DATEADD(hour, 1, HOUR) AS HOUR
            FROM hours
            WHERE HOUR < (SELECT MAX(DATE_TRUNC(hour, CREATED_AT)) FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_EVENTS)
        ), sessions AS
        (
            SELECT DISTINCT
                DATE_TRUNC(hour, CREATED_AT) AS SESSION_HOUR,
                COUNT(DISTINCT SESSION_ID) AS NUM_SESSIONS
            FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.STG_EVENTS
            GROUP BY 1
        )

        SELECT 
            ROUND(AVG(NVL(S.NUM_SESSIONS, 0)), 2) AS NUM_SESSIONS
        FROM hours H
        LEFT JOIN sessions S ON H.HOUR = S.SESSION_HOUR
