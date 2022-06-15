{% macro create_table_if_not_exists(cfg) %}
    {%- set schema_name = dbt_models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = dbt_models_metadata.config__get_table_name(cfg) -%}

    {%- do adapter.create_schema(api.Relation.create(
        target=database, 
        schema=schema_name,
    )) -%}

    {%- if adapter.get_relation(
            database=target.database, 
            schema=schema_name, 
            identifier=table_name
        ) is none
    -%}
        {# 
            TODO: how to create table via adapter (i.e. in adapter agnostic way)??
        #}
        {{log("[dbt-models-metadata] Creating table: "~adapter.quote(schema_name~"."~table_name), info=true)}}
        {%- set metadata_columns = dbt_models_metadata.metadata_columns(cfg) -%}
        {%- set query -%}
            CREATE TABLE {{schema_name}}.{{table_name}}(
            {% for cv in metadata_columns.values() -%}
               {{ cv["column"].name }} {{ cv["column"].data_type }}{{ ',' if not loop.last }}
            {% endfor -%}
            );
        {% endset %}
        {%- call statement(auto_begin=True) -%}
            {{query}}
        {%- endcall -%}
    {%- endif -%}

{% endmacro %}
