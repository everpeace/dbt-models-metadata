{% macro upsert_results(cfg, results) %}
    {%- set now = modules.datetime.datetime.now(modules.pytz.utc) -%}
    {%- set schema_name = dbt_models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = dbt_models_metadata.config__get_table_name(cfg) -%}

    {# Focusing just on model results #}
    {%- set model_results = [] -%}
    {%- for result in results -%}
        {%- if result.node.resource_type|as_text == "model" -%}
            {%- do model_results.append(result) -%}
        {%- endif -%}
    {%- endfor -%}

    {# insert or update model result #}
    {{ log(
        "[dbt-models-metadata] " ~ model_results|length ~ " rows will be affected in "
            ~ adapter.quote(schema_name~"."~table_name),
        info=true,
    ) }}
    {%- for model_result in model_results -%}
        {%- set column_values = dbt_models_metadata.metadata_columns(cfg, model_result, now) -%}

        {# filter out NULL so we dont override things during update #}
        {% set filtered_columns_values = {} %}
        {%- for key, item in column_values.items() -%}
            {%- if item["value"] is not none -%}
                {%- do filtered_columns_values.update({key: item}) -%}
            {%- endif -%}
        {%- endfor -%}

        {%- if adapter.dispatch('model_result_exists', 'dbt_models_metadata')(cfg, column_values) -%}

            {{ adapter.dispatch('insert_model_result', 'dbt_models_metadata')(cfg, filtered_columns_values) }}

        {%- else -%}

            {{ adapter.dispatch('update_model_result', 'dbt_models_metadata')(cfg, filtered_columns_values) }}

        {%- endif -%}
    {%- endfor -%}

{% endmacro %}

{% macro default__insert_model_result(cfg, column_values) %}
    {{ exceptions.raise_compiler_error("Creating dbt_models_metadata is not implemented for the default adapter") }}
{% endmacro %}

{% macro default__update_model_result(cfg, column_values) %}
    {{ exceptions.raise_compiler_error("Creating dbt_models_metadata is not implemented for the default adapter") }}
{% endmacro %}

{% macro default__model_result_exists(cfg, column_values) %}
    {{ exceptions.raise_compiler_error("Creating dbt_models_metadata is not implemented for the default adapter") }}
{% endmacro %}

{%- macro default__to_literal(v) -%}
    {{ exceptions.raise_compiler_error("Creating dbt_models_metadata is not implemented for the default adapter") }}
{%- endmacro -%}
