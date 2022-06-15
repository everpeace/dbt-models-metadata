{% macro update_columns(cfg) %}
    {%- set schema_name = models_metadata.config__get_schema_name(cfg) -%}
    {%- set table_name = models_metadata.config__get_table_name(cfg) -%}
    {%- set relation = api.Relation.create(
        database=target.database, schema=schema_name, identifier=table_name, type='table'
    )-%}
    {%- set metadata_columns = models_metadata.metadata_columns(cfg) -%}

    {# 
       add/remove/alter columns
    #}
    {%- set existing_column_list = adapter.get_columns_in_relation(relation) -%}
    {%- set existing_columns = {} -%}
    {%- for col in existing_column_list -%}
        {%- set _ = existing_columns.update({ col.name|upper: {"column": col }}) -%}
    {%- endfor %}

    {# detecting columns to add #}
    {%- set to_add = [] -%}
    {%- for n, c in metadata_columns.items() -%}
        {%- if n|upper not in existing_columns -%}
            {%- set _ = to_add.append(c["column"]) -%}
        {%- endif -%}
    {%- endfor -%}

    {# detecting columns to remove #}
    {%- set to_remove = [] -%}
    {%- if models_metadata.config__column_drop(cfg) -%}
        {%- for n, c in existing_columns.items() -%}
            {%- if n|upper not in metadata_columns -%}
                {%- set _ = to_remove.append(c["column"]) -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}
    
    {# do add/remove columns #}
    {%- if to_add|length + to_remove|length > 0 -%}
        {{log("[dbt-models-metadata] Adding columns: " ~ to_add, true)}}
        {{log("[dbt-models-metadata] Removing columns: " ~ to_remove, true) }}
        {{ 
            alter_relation_add_remove_columns(
                relation,
                add_columns=to_add,
                remove_columns=to_remove,
            ) 
        }}
    {%- endif -%}

    {# detecting columns to alter type #}
    {%- set to_alter = [] -%}
    {%- for n1, c1 in existing_columns.items() %}
        {%- for n2, c2 in metadata_columns.items() %}
            {%- if n1|upper == n2|upper and c1.data_type|upper != c2.data_type|upper -%}
                {%- set _ = to_alter.append({"from": c1["column"], "to": c2["column"]}) -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endfor -%}

    {# do alter column types #}
    {%- if to_alter|length > 0 -%}
        {{log("[dbt-models-metadata] Altering columns: " ~ to_alter, true)}}
        {%- for alter in to_alter -%}
            {{ alter_column_type(relation, alter["from"].name, alter["to"].data_type) }}
        {%- endfor -%}
    {%- endif -%}

{% endmacro %}
