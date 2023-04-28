
{% macro postgres__agg_event_types() %} 

    {% set event_type_vals = dbt_utils.get_column_values(table=ref('stg_postgres__events') , column='EVENT_TYPE') %}

    {% for event_type in event_type_vals  %}
      SUM(CASE WHEN EVENT_TYPE = '{{ event_type }}' THEN 1 ELSE 0 END) AS NUM_{{ event_type }},
    {% endfor %}

{% endmacro %}