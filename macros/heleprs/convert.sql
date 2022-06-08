{%- macro to_text_literal(v) -%}
    {{- return("'" ~ v|as_text ~ "'") -}}
{%- endmacro -%}
