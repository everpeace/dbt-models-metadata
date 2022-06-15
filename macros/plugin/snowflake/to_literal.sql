{%- macro snowflake__to_literal(v) -%}
    {{- return("$$" ~ v|as_text ~ "$$") -}}
{%- endmacro -%}
