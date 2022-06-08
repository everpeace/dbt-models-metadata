{% macro create_table_if_not_exists(cfg) %}
    {%- set schema_name = models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = models_metadata.config__get_table_name(cfg) -%}

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
        {%- call statement(auto_begin=True) -%}
            CREATE TABLE {{schema_name}}.{{table_name}}();
        {%- endcall -%}
    {%- endif -%}

{% endmacro %}
