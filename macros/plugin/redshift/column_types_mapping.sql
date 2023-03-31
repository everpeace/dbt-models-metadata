{% macro redshift__column_types_mapping() %}
    {{return({
        'text': 'character varying(16384)',
        'json': 'character varying(65535)',
        'float': 'double precision',
        'timestamp': 'timestamp with time zone'
    })}}
{% endmacro %}
