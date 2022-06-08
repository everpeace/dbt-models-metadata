{%- macro config__get_schema_name(config) -%}
    {%- set schema = target.schema -%}

    {%- if 'schema' in config -%}
        {%- set schema = config.get('schema') -%}
    {%- elif '+schema' in config -%}
        {%- set schema = generate_metadata(config.get('+schema')) -%}
    {%- endif -%}

    {{- return(schema) -}}
{%- endmacro -%}

{%- macro config__get_table_name(config) -%}
    {{ return(config.get('table_name', 'dbt_models_metadata')) }}
{%- endmacro -%}

{%- macro config__column_drop(config) -%}
    {{ return(config.get('column_drop', false)) }}
{%- endmacro -%}

{%- macro config__get_additional_columns(cfg) -%}
    {%- set additional_columns_cfg = cfg.get('additional_columns',[]) -%}

    {%- set ret = {} -%}
    {%- for col_cfg in additional_columns_cfg -%}
        {%- set _ = ret.update({
            col_cfg["name"]: {
                "additional": true,
                "column": api.Column(
                    col_cfg["name"], 
                    col_cfg["dtype"], 
                    char_size=col_cfg.get("char_size", None), 
                ),
                "value": col_cfg["value"],
            },
        }) -%}
    {%- endfor -%}

    {{ return(ret) }}
{%- endmacro -%}
