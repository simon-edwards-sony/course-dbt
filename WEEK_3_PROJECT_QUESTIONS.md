# Part 1: Create new models to answer the first two questions (answer questions in README file)
Created a new fact model named *fact_postgres__product_conversion_rate.sql* to consolidate session/product conversion rates

### What is our overall conversion rate?
**62.46%**

<details>
<summary>Query</summary>

		WITH sessions AS 
		(
		  SELECT
			SESSION_ID,
			SUM(NUM_CHECKOUT) AS SUM_CHECKOUT
		  FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.FACT_POSTGRES__PRODUCT_CONVERSION_RATE
		  GROUP BY 1
		)

		SELECT 
		  ROUND((SUM(CASE WHEN SUM_CHECKOUT > 0 THEN 1 ELSE 0 END) / COUNT(SESSION_ID)) * 100, 2) AS SESSION_CONV_RATE_PERCENT,
		  ROUND(SUM(CASE WHEN SUM_CHECKOUT > 0 THEN 1 ELSE 0 END) / COUNT(SESSION_ID), 4) AS SESSION_CONV_RATE
		FROM sessions
		
</details>
___

### What is our conversion rate by product?
**Conversion rate % per product can be found below:**
| **product_id** | **product_name** | **conversion_rate_%** |
| ---------- | ------------ | ----------------- |
| fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80 | String of pearls | 60.94 |
| 74aeb414-e3dd-4e8a-beef-0fa45225214d | Arrow Head | 55.56 |
| c17e63f7-0d28-4a95-8248-b01ea354840e | Cactus | 54.55 |
| b66a7143-c18a-43bb-b5dc-06bb5d1d3160 | ZZ Plant | 53.97 |
| 689fb64e-a4a2-45c5-b9f2-480c2155624d | Bamboo | 53.73 |
| 579f4cd0-1f45-49d2-af55-9ab2b72c3b35 | Rubber Plant | 51.85 |
| be49171b-9f72-4fc9-bf7a-9a52e259836b | Monstera | 51.02 |
| b86ae24b-6f59-47e8-8adc-b17d88cbd367 | Calathea Makoyana | 50.94 |
| e706ab70-b396-4d30-a6b2-a1ccf3625b52 | Fiddle Leaf Fig | 50 |
| 5ceddd13-cf00-481f-9285-8340ab95d06d | Majesty Palm | 49.25 |
| 615695d3-8ffd-4850-bcf7-944cf6d3685b | Aloe Vera | 49.23 |
| 35550082-a52d-4301-8f06-05b30f6f3616 | Devil's Ivy | 48.89 |
| 55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3 | Philodendron | 48.39 |
| a88a23ef-679c-4743-b151-dc7722040d8c | Jade Plant | 47.83 |
| 64d39754-03e4-4fa0-b1ea-5f4293315f67 | Spider Plant | 47.46 |
| 5b50b820-1d0a-4231-9422-75e7f6b0cecf | Pilea Peperomioides | 47.46 |
| 37e0062f-bd15-4c3e-b272-558a86d90598 | Dragon Tree | 46.77 |
| d3e228db-8ca5-42ad-bb0a-2148e876cc59 | Money Tree | 46.43 |
| c7050c3b-a898-424d-8d98-ab0aaad7bef4 | Orchid | 45.33 |
| 05df0866-1a66-41d8-9ed7-e2bbcddd6a3d | Bird of Paradise | 45 |
| 843b6553-dc6a-4fc4-bceb-02cd39af0168 | Ficus | 42.65 |
| bb19d194-e1bd-4358-819e-cd1f1b401c0c | Birds Nest Fern | 42.31 |
| 80eda933-749d-4fc6-91d5-613d29eb126f | Pink Anthurium | 41.89 |
| e2e78dfc-f25c-4fec-a002-8e280d61a2f2 | Boston Fern | 41.27 |
| 6f3a3072-a24d-4d11-9cef-25b0b5f8a4af | Alocasia Polly | 41.18 |
| e5ee99b6-519f-4218-8b41-62f48f59f700 | Peace Lily | 40.91 |
| e18f33a6-b89a-4fbc-82ad-ccba5bb261cc | Ponytail Palm | 40 |
| e8b6528e-a830-4d03-a027-473b411c7f02 | Snake Plant | 39.73 |
| 58b575f2-2192-4a53-9d21-df9a0c14fc25 | Angel Wings Begonia | 39.34 |
| 4cda01b9-62e2-46c5-830f-b7f262a58fb1 | Pothos | 34.43 |

<details>
<summary>Query</summary>

		WITH session_products AS 
		(
		  SELECT
			SESSION_ID AS "SESSION_ID",
			PRODUCT_ID AS "PRODUCT_ID",
			PRODUCT_NAME AS "PRODUCT_NAME",
			SUM(NUM_CHECKOUT) AS SUM_CHECKOUT
		  FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.FACT_POSTGRES__PRODUCT_CONVERSION_RATE
		  GROUP BY 1,2,3
		)

		SELECT
		  PRODUCT_ID,
		  PRODUCT_NAME,
		  ROUND((SUM(CASE WHEN SUM_CHECKOUT > 0 THEN 1 ELSE 0 END)  / COUNT(SESSION_ID)) * 100, 2) AS PRODUCT_CONV_RATE_PERCENT,
		  ROUND(SUM(CASE WHEN SUM_CHECKOUT > 0 THEN 1 ELSE 0 END)  / COUNT(SESSION_ID), 4) AS PRODUCT_CONV_RATE
		FROM session_products
		GROUP BY 1,2
		ORDER BY 3 DESC
		
</details>
___

# Part 2: We’re getting really excited about dbt macros after learning more about them and want to apply them to improve our dbt project.
Added a new macro named *macro_postgres__agg_event_types.sql* and integrated this into the *int_postgres__session_stats.sql* model.
___

# Part 3: We’re starting to think about granting permissions to our dbt models in our snowflake database so that other roles can have access to them.
Added and validated grants are being ran via Snowflake query history.
___

# Part 4:  After learning about dbt packages, we want to try one out and apply some macros or tests.
Installed the *dbt_utils* package and utilised the *get_column_values()* function within my *macro_postgres__agg_event_types.sql* macro.
___

# Part 5: After improving our project with all the things that we have learned about dbt, we want to show off our work!
The macros were used to improve the SQL code so the DAG has not changed apart from the inclusion of *fact_postgres__product_conversation_rate*
___

# Part 6. dbt Snapshots
| **product_name** | **changed_from** | **changed_to** | 
| ------------ | ------------ | ---------- |
| Pothos | 20 | 0 |
| Bamboo | 56 | 44 |
| Philodendron | 25 | 15 |
| Monstera | 64 | 50 |
| String of pearls | 10 | 0 |
| ZZ Plant | 89 | 53 |

<details>
<summary>Query</summary>

		SELECT
		  SS1.dbt_valid_to AS "change_date",
		  SS1.name AS "product_name",
		  SS1.inventory AS changed_from,
		  SS2.inventory AS changed_to
		FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.PRODUCTS_SNAPSHOT SS1
		JOIN DEV_DB.DBT_SIMONEDWARDSSONYCOM.PRODUCTS_SNAPSHOT SS2 ON SS1.product_id = SS2.product_id AND SS1.dbt_valid_to = SS2.dbt_valid_from
		WHERE SS1.dbt_valid_to > DATEADD(day, -DATE_PART(dow, CURRENT_DATE()), CURRENT_DATE())

</details>