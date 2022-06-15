{% macro snowflake__column_types_mapping() %}
    {{return({
        'text': 'text',
        'json': 'variant',
        'float': 'float',
        'timestamp': 'timestamp_tz'
    })}}
{% endmacro %}
