{% snapshot products_snapshot %}

  {{
    config(
      target_database = target.database,
      target_schema = target.schema,
      unique_key = 'product_id',
      strategy='check',
      check_cols=['inventory']
    )
  }}

  select * from {{ source('postgres', 'products') }}

{% endsnapshot %}