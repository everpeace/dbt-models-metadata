{% macro metadata_columns() %}
    {{ return(adapter.dispatch('metadata_columns', 'models_metadata')()) }}
{% endmacro %}

{% macro default__metadata_columns() %}
    {{ exceptions.raise_compiler_error("Creating dbt_models_metadata is not implemented for the default adapter") }}
{% endmacro %}
