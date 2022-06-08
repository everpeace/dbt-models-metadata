{% macro generate(results) -%}
    {#
         load configuration from var
    #}
    {%- set cfg = var('models_metadata') -%}
    

    BEGIN;

    {#
         creating schema and table if not exists
    #}
    {{ models_metadata.create_table_if_not_exists(cfg) }}

    {#
        update columns
    #}
    {{ models_metadata.update_columns(cfg) }}

    {#
        upsert results
            NOTE: this package only focues on model results
    #}
    {{ models_metadata.upsert_results(cfg, results) }}
    
    COMMIT;

{%- endmacro %}
