{% macro snowflake__column_types_mapping() %}
    {{return({
        'text': 'text',
        'json': 'variant',
        'float': 'double precision',
        'timestamp': 'timestamp_tz'
    })}}
{% endmacro %}
