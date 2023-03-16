{% macro convert_timing_to_dict(timing) %}
    {#
        Transform timing in result to dict so that it can work with "|tojson" filter 
    #}
    {%- set timing_dict = [] -%}
    {%- for tinfo in timing -%}
        {%- do timing_dict.append({
            "name": tinfo.name,
            "started_at": modules.pytz.utc.localize(tinfo.started_at).isoformat(),
            "completed_at": modules.pytz.utc.localize(tinfo.completed_at).isoformat(),
        })-%}
    {%- endfor -%}
    {{return(timing_dict)}}
{% endmacro %}

{% macro convert_node_to_dict(node) %}
    {#
        Transform node in result to dict so that it can work with "|tojson" filter 
    #}
    
    {{return({
        "raw_sql": node.raw_sql,
        "compiled": node.compiled,
        "database": node.database,
        "schema": node.schema,
        "fqn": node.fqn,
        "unique_id": node.unique_id,
        "package_name": node.package_name,
        "root_path": node.root_path,
        "path": node.path,
        "original_file_path": node.original_file_path,
        "name": node.name,
        "resource_type": node.resource_type,
        "alias": node.alias,
        "checksum": {
            "name": node.checksum.name,
            "checksum": node.checksum.checksum,
        },
        "config": {
            "enabled": node.config.enabled,
            "alias": node.config.alias,
            "schema": node.config.schema,
            "database": node.config.database,
            "tags": node.config.tags,
            "meta": node.config.meta,
            "materialized": node.config.materialized,
            "persist_docs": node.config.persist_docs,
            "post_hook": node.config.post_hook,
            "pre_hook": node.config.pre_hook,
            "quoting": node.config.quoting,
            "column_types": node.config.column_types,
            "full_refresh": node.config.full_refresh,
            "unique_key": node.config.unique_key,
            "on_schema_change": node.config.on_schema_change,
            "grants": node.config.grants,
        },
        "tags": node.tags,
        "refs": node.refs,
        "sources": node.sources,
        "depends_on": {
            "macros": node.depends_on.macros,
            "nodes": node.depends_on.nodes,
            "nodes": node.depends_on.nodes,
        },
        "nodes": node.nodes if node.nodes else none,
        "description": node.description,
        "columns": node.columns,
        "meta": node.meta,
        "docs": {
            "show": node.docs.show,
        },
        "patch_path": node.patch_path,
        "compiled_path": node.compiled_path,
        "build_path": node.build_path,
        "deferred": node.deferred,
        "unrendered_config": node.unrendered_config,
        "created_at": node.created_at,
        "config_call_dict": node.config_call_dict,
        "compiled_sql": node.compiled_sql,
        "extra_ctes_injected": node.extra_ctes_injected,
        "extra_ctes": node.extra_ctes,
        "relation_name": node.relation_name,
    })}}
{% endmacro %}

