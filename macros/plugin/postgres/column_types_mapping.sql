{% macro postgres__column_types_mapping() %}
    {{return({
        'text': 'text',
        'json': 'jsonb',
        'float': 'double precision',
        'timestamp': 'timestamptz'
    })}}
{% endmacro %}
