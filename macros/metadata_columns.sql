{% macro metadata_columns(cfg, result=none, now=none, skip_node=False) %}
    {% set timing = [] %}
    {% set node = {} %}

    {%- if result is not none -%}
        {% set timing = dbt_models_metadata.convert_timing_to_dict(result.timing) %}
        {% if not skip_node %}
            {% set node = dbt_models_metadata.convert_node_to_dict(result.node) %}
        {% else %}
            {% set node = {} %}
        {% endif %}
    {% endif %}

    {# 
        Column definition of models_metadata_columns
        with values if result was passed
    #}
    {%- set column_types_mapping = adapter.dispatch('column_types_mapping', 'dbt_models_metadata')() -%}
    {%- set column_list = [
        {
            "column": api.Column('unique_id', column_types_mapping['text']),
            "value": result.node.unique_id if result is not none,
        },
        {
            "column": api.Column('database', column_types_mapping['text']),
            "value": result.node.database if result is not none,
        },
        {
            "column": api.Column('schema', column_types_mapping['text']),
            "value": result.node.schema if result is not none,
        },
        {
            "column": api.Column('"table"', column_types_mapping['text']),
            "column_name": 'table',
            "value": result.node.name if result is not none,
        },
        {
            "column": api.Column('description', column_types_mapping['text']),
            "value": result.node.description|replace("'", "\"") if result is not none,
        },

        {
            "column": api.Column('dbt_version', column_types_mapping['text']),
            "value": dbt_version,
        },
        {
            "column": api.Column('invocation_id', column_types_mapping['text']),
            "value": invocation_id,
        },
        {
            "column": api.Column('node', column_types_mapping['json']),
            "value": node|tojson,
        },
        {
            "column": api.Column('status', column_types_mapping['text']),
            "value": result.status if result is not none,
        },
        {
            "column": api.Column('thread_id', column_types_mapping['text']),
            "value": result.thread_id if result is not none,
        },
        {
            "column": api.Column('execution_time', column_types_mapping['float']),
            "value": result.execution_time|tojson if result is not none,
        },
        {
            "column": api.Column('timing', column_types_mapping['json']),
            "value": timing|tojson if result is not none,
        },
        {
            "column": api.Column('adapter_response', column_types_mapping['json']),
            "value": result.adapter_response|tojson if result is not none,
        },
        {
            "column": api.Column('message', column_types_mapping['text']),
            "value": result.message if result is not none,
        },
        {
            "column": api.Column('updated_at', column_types_mapping['timestamp']),
            "value": now.isoformat() if now is not none,
        },
        {
            "column": api.Column('last_success_at', column_types_mapping['timestamp']),
            "value": now.isoformat() if now is not none and result is not none and result.status == 'success' else None,
        },
        {
            "column": api.Column('last_error_at', column_types_mapping['timestamp']),
            "value": now.isoformat() if now is not none and result is not none and result.status == 'error' else None,
        },
    ]-%}

    {# 
        transform list to dict
            to make column existence check easier in later process
    #}
    {%- set columns = {} -%}
    {%- for item in column_list -%}
        {%- set key = item["column_name"] if "column_name" in item else item["column"].name -%}
        {%- do columns.update({
            key: item
        }) -%}
    {%- endfor -%}

    {# append user-defined additional_columns #}
    {%- set _ = columns.update(
        dbt_models_metadata.config__get_additional_columns(cfg),
    )-%}

    {{ return(columns) }}
{% endmacro %}
