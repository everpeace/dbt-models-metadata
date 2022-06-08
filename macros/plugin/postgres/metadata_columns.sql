{% macro postgres__metadata_columns(cfg, result=none, now=none) %}
    {#
        Transform object in result suth that it can "|tojson" filter doesn't work
            TODO: how to make "|tojson" work??
    #}
    {%- set timing = [] -%}
    {%- set node = {} -%}
    {%- if result is not none -%}
        {%- for tinfo in result.timing -%}
            {%- do timing.append({
                "name": tinfo.name,
                "started_at": modules.pytz.utc.localize(tinfo.started_at).isoformat(),
                "completed_at": modules.pytz.utc.localize(tinfo.completed_at).isoformat(),
            })-%}
        {%- endfor -%}
        {%- do node.update({
            "raw_sql": result.node.raw_sql,
            "compiled": result.node.compiled,
            "database": result.node.database,
            "schema": result.node.schema,
            "fqn": result.node.fqn,
            "unique_id": result.node.unique_id,
            "package_name": result.node.package_name,
            "root_path": result.node.root_path,
            "path": result.node.path,
            "original_file_path": result.node.original_file_path,
            "name": result.node.name,
            "resource_type": result.node.resource_type,
            "alias": result.node.alias,
            "checksum": {
                "name": result.node.checksum.name,
                "checksum": result.node.checksum.checksum,
            },
            "config": {
                "enabled": result.node.config.enabled,
                "alias": result.node.config.alias,
                "schema": result.node.config.schema,
                "database": result.node.config.database,
                "tags": result.node.config.tags,
                "meta": result.node.config.meta,
                "materialized": result.node.config.materialized,
                "persist_docs": result.node.config.persist_docs,
                "post_hook": result.node.config.post_hook,
                "pre_hook": result.node.config.pre_hook,
                "quoting": result.node.config.quoting,
                "column_types": result.node.config.column_types,
                "full_refresh": result.node.config.full_refresh,
                "unique_key": result.node.config.unique_key,
                "on_schema_change": result.node.config.on_schema_change,
                "grants": result.node.config.grants,
            },
            "tags": result.node.tags,
            "refs": result.node.refs,
            "sources": result.node.sources,
            "depends_on": {
                "macros": result.node.depends_on.macros,
                "nodes": result.node.depends_on.nodes,
                "nodes": result.node.depends_on.nodes,
            },
            "nodes": result.node.nodes if result.node.nodes else none,
            "description": result.node.description,
            "columns": result.node.columns,
            "meta": result.node.meta,
            "docs": {
                "show": result.node.docs.show,
            },
            "patch_path": result.node.patch_path,
            "compiled_path": result.node.compiled_path,
            "build_path": result.node.build_path,
            "deferred": result.node.deferred,
            "unrendered_config": result.node.unrendered_config,
            "created_at": result.node.created_at,
            "config_call_dict": result.node.config_call_dict,
            "compiled_sql": result.node.compiled_sql,
            "extra_ctes_injected": result.node.extra_ctes_injected,
            "extra_ctes": result.node.extra_ctes,
            "relation_name": result.node.relation_name,
        }) -%}
    {%- endif -%}

    {# 
        Column definition of models_metadata_columns
        with values if result was passed
    #}
    {%- set column_list = [
        {
            "column": api.Column('unique_id', 'text'),
            "value": result.node.unique_id if result is not none,
        },
        {
            "column": api.Column('database', 'text'),
            "value": result.node.database if result is not none,
        },
        {
            "column": api.Column('schema', 'text'),
            "value": result.node.schema if result is not none,
        },
        {
            "column": api.Column('"table"', 'text'),
            "column_name": 'table',
            "value": result.node.name if result is not none,
        },
        {
            "column": api.Column('description', 'text'),
            "value": result.node.description if result is not none,
        },

        {
            "column": api.Column('dbt_version', 'text'),
            "value": dbt_version,
        },
        {
            "column": api.Column('invocation_id', 'text'),
            "value": invocation_id,
        },
        {
            "column": api.Column('node', 'jsonb'),
            "value": node|tojson,
        },
        {
            "column": api.Column('status', 'text'),
            "value": result.status if result is not none,
        },
        {
            "column": api.Column('thread_id', 'text'),
            "value": result.thread_id if result is not none,
        },
        {
            "column": api.Column('execution_time', 'double precision'),
            "value": result.execution_time|tojson if result is not none,
        },
        {
            "column": api.Column('timing', 'jsonb'),
            "value": timing|tojson if result is not none,
        },
        {
            "column": api.Column('adapter_response', 'jsonb'),
            "value": result.adapter_response|tojson if result is not none,
        },
        {
            "column": api.Column('message', 'text'),
            "value": result.message if result is not none,
        },
        {
            "column": api.Column('updated_at', 'timestamptz'),
            "value": now.isoformat() if now is not none,
        },
    ]-%}

    {# 
        transform list to dict
            to make column existence check easier in later process
    #}
    {%- set columns = {} -%}
    {%- for item in  column_list -%}
        {%- set key = item["column_name"] if "column_name" in item else item["column"].name -%}
        {%- do columns.update({
            key: item
        }) -%}
    {%- endfor -%}

    {# append user-defined additional_columns #}
    {%- set _ = columns.update(
        models_metadata.config__get_additional_columns(cfg),
    )-%}

    {{ return(columns) }}
{% endmacro %}
