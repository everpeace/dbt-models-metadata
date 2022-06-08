{% macro postgres__model_result_exists(cfg, column_values) %}
    {%- set schema_name = models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = models_metadata.config__get_table_name(cfg) -%}

    {%- set check_query -%}
        SELECT 1 FROM {{schema_name}}.{{table_name}} WHERE UNIQUE_ID={{models_metadata.to_text_literal(column_values["unique_id"]["value"])}};
    {%- endset -%}

    {{ return(run_query(check_query).rows|length == 0) }}
{% endmacro %}

{% macro postgres__insert_model_result(cfg, column_values) %}
    {%- set schema_name = models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = models_metadata.config__get_table_name(cfg) -%}

    INSERT INTO {{schema_name}}.{{table_name}} (
        {%- for cv in column_values.values() %}
            {{cv["column"].name}}{%- if not loop.last -%},{%- endif -%}
        {%- endfor %}
    ) VALUES (
        {%- for cv in column_values.values() %}
            {%- if cv.get('additional', False) -%}
                {{models_metadata.to_text_literal(render(cv["value"]))}}
            {%- else -%}
                {{models_metadata.to_text_literal(cv["value"])}}
            {%- endif -%}
            {%- if not loop.last -%},{%- endif -%}
        {%- endfor %}
    );

{% endmacro %}

{% macro postgres__update_model_result(cfg, column_values) %}
    {%- set schema_name = models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = models_metadata.config__get_table_name(cfg) -%}

    UPDATE {{schema_name}}.{{table_name}}
    SET
        {%- for cv in column_values.values() %}
            {{cv["column"].name}} = {% if cv.get('additional', False) -%}
                {{models_metadata.to_text_literal(render(cv["value"]))}}
            {%- else -%}
                {{models_metadata.to_text_literal(cv["value"])}}
            {%- endif -%}
            {%- if not loop.last -%},{%- endif -%}
        {%- endfor %}
    WHERE UNIQUE_ID = {{models_metadata.to_text_literal(column_values["unique_id"]["value"])}};

{% endmacro %}
