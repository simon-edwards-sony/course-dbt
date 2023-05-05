# Part 1. dbt Snapshots

**Run the products snapshot model using dbt snapshot and query it in snowflake to see how the data has changed since last week.**
+ Ran the snapshot and created a fact table replicating the following query, to calculate the following questions:

<details>
<summary>Query</summary>

		SELECT
		  SS1.dbt_valid_to AS change_date,
		  SS1.product_id AS product_id,
		  SS1.name AS product_name,
		  SS1.inventory AS changed_from,
		  SS2.inventory AS changed_to
		FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.PRODUCTS_SNAPSHOT SS1
		JOIN DEV_DB.DBT_SIMONEDWARDSSONYCOM.PRODUCTS_SNAPSHOT SS2 ON SS1.product_id = SS2.product_id AND SS1.dbt_valid_to = SS2.dbt_valid_from
		
</details>

**Which products had their inventory change from week 3 to week 4?**
+ The following table summarises changes in inventory in the last week:

| product_name | changed_from | changed_to | 
| ------------ | ------------ | ---------- |
| Bamboo | 44 | 23 |
| Monstera | 50 | 31 |
| Philodendron | 15 | 30 |
| Pothos | 0 | 20 |
| String of pearls | 0 | 10 |
| ZZ Plant| 53| 41 |

<details>
<summary>Query</summary>

		SELECT product_name, changed_from, changed_to
		FROM DBT_SIMONEDWARDSSONYCOM.fact_postgres__product_inventory_changelog
		WHERE change_date > DATEADD(day, -DATE_PART(dow, CURRENT_DATE()), CURRENT_DATE())
		ORDER BY product_name
		
</details>

**Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory?**
+ I do not have the first week of changes however the we see that in the last two weeks the same 6 items have changed. The following displays the 6 items that have changed, along with the total of their relevant absolute stock change:

| product_name | count_changes | abs_inventory_change | 
| ------------ | ------------- | -------------------- |
| ZZ Plant | 2 | 48 |
| Pothos | 2 | 40 |
| Bamboo | 2 | 33 |
| Monstera | 2 | 33 |
| Philodendron | 2 | 25 |
| String of pearls| 2 | 20 |

<details>
<summary>Query</summary>

		SELECT
		product_name,
		COUNT(*) AS count_changes,
		SUM(ABS(changed_from - changed_to)) AS sum_inventory_change
		FROM DBT_SIMONEDWARDSSONYCOM.fact_postgres__product_inventory_changelog
		GROUP BY 1
		ORDER BY 3 DESC
		
</details>

**Did we have any items go out of stock in the last 3 weeks?**
+ We can see that both the Pothos and String of pearls went out of stock last week but were re-stocked the following week

<details>
<summary>Query</summary>

		SELECT product_name 
		FROM DBT_SIMONEDWARDSSONYCOM.fact_postgres__product_inventory_changelog
		WHERE changed_to = 0
		
</details>

# Part 2. Modeling challenge
**How are our users moving through the product funnel?**
**Which steps in the funnel have largest drop off points?**

**Product funnel is defined with 3 levels for our dataset:**
**Sessions with any event of type page_view**
**Sessions with any event of type add_to_cart**
**Sessions with any event of type checkout**

+ Although we already have a fact table (DEV_DB.DBT_SIMONEDWARDSSONYCOM.FACT_POSTGRES__PRODUCT_CONVERSION_RATE) to show us our conversion rates for the events to the session/product grain we would need to aggregate this to the session level rather than product grain. To make this more reproducible and remove business logic from the presentation layer we will create a new dim table named DEV_DB.DBT_SIMONEDWARDSSONYCOM.DIM_POSTGRES__PRODUCT_FUNNEL to calculate the totals and percentages of each level.

+ From our session statistics we see a total of 578 sessions with a product view, 467 (80.80%) added to cart and 361 (62.46%) checkouts.

+ For the dropoff this would depend on if we calculate this from the level above (add_to_cart) or from total (product_views).
  - Add to cart droppoff = 111 (19.20%)
  - Checkout dropoff from total views = 217 (37.54%)
  - Checkout dropoff from total add to carts = 106 (22.70%)

<details>
<summary>Query</summary>

		SELECT * 
		FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.DIM_POSTGRES__PRODUCT_FUNNEL

		/*
		WITH session_agg AS
		(
		SELECT
			SESSION_ID,
			SUM(CASE WHEN ADD_TO_CART_DATE IS NOT NULL THEN 1 ELSE 0 END) AS ADDED_TO_CART,
			SUM(CASE WHEN CHECKOUT_DATE IS NOT NULL THEN 1 ELSE 0 END) AS CHECKOUTS
		FROM DEV_DB.DBT_SIMONEDWARDSSONYCOM.FACT_POSTGRES__PRODUCT_VIEWS
		GROUP BY 1
		)

		SELECT
			COUNT(*) product_views_total,
			SUM(CASE WHEN ADDED_TO_CART > 0 THEN 1 ELSE 0 END) AS added_to_cart_total,
			SUM(CASE WHEN CHECKOUTS > 0 THEN 1 ELSE 0 END) AS checkouts_total,
			ROUND(DIV0(added_to_cart_total, product_views_total), 4) AS added_to_cart_pct,
			ROUND(DIV0(checkouts_total, product_views_total), 4) AS checkouts_pct,
			product_views_total - added_to_cart_total AS added_to_cart_dropoff_total,
			product_views_total - checkouts_total AS checkouts_dropoff_total,
			ROUND(1 - added_to_cart_pct, 4) AS added_to_cart_dropoff_pct,
			ROUND(1 - checkouts_pct, 4) AS checkouts_dropoff_pct,
			ROUND(DIV0(checkouts_total, added_to_cart_total), 4) AS checkouts_pct_fromcart,
			added_to_cart_total - checkouts_total AS checkouts_dropoff_total_fromcart,
			ROUND(1 - checkouts_pct_fromcart, 4) AS checkouts_dropoff_pct_fromcart
		FROM session_agg
		*/
		
</details>

# Part 3: Reflection questions -- please answer 3A or 3B, or both!
**3A. dbt next steps for you**
+ We currently use another ETL tool (Matillion) and due to the number of sources the transformations are starting to get very complex and timely. We also have a number of data quality issues that we were planning to write dashboards to alert us on, however it would make sense to wrap all of this up together. 
+ Our next step would be to migrate a single source to dbt and compare transformations times between current vs dbt. This along with tests/documentation should be a good the best way of demonstrating the value of dbt in our organization. We already utilize staging and datamarts so we won't require any radical changes in the models themselves, just how they're built.

**3B. Setting up for production / scheduled dbt run of your project**
+ Our current ETL tool has just recently added support out of the box for dbt so we should be able to integrate it relatively easily. We have a number of jobs that handle the ingestion and we typically run SQL scripts for each transformation as they're more flexible than the in-built transformation jobs. Scheduling dbt would just be a case of changing the data mart orchestration jobs to point to dbt instead.
+ Going forward we were looking at implementing some ML modelling as part of our workflow (thanks to the intemediate python for data science course) so we may look to start using another tool to schedule our workloads. I particularly like the look of Dagster for this use case. Given that our goal would be to port all transformations to dbt, this should make our workflow tool agnostic and the transformation piece can just be moved over to another tool, with us just needing to handle the ingestion/orchestration of other tools (Airbyte/Fivetran etc.)