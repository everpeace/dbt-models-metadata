# dbt-models-metadata <!-- omit in toc -->

Extension package for [dbt][dbt] to build a metadata table for your dbt models along side your models.

### Table of Contents <!-- omit in toc -->

- [Generated Models' Metadata Table](#generated-models-metadata-table)
- [Install](#install)
- [Variables](#variables)
- [How It Works At a Glance](#how-it-works-at-a-glance)
- [LICENSE](#license)
- [Acknowledgement](#acknowledgement)

## Generated Models' Metadata Table

The models' metadata table is based on the information in [Results][results] object in [`run-on-end` context][run-on-end-ctx] (a.k.a. [`run_results.json` artifact]([run-results-json]) also contains the same information).

| Column           | Description                                                                                                                                               |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| unique_id        | model's unique_id                                                                                                                                         |
| database         | database name that the model created in                                                                                                                   |
| schema           | schema name that the model created in                                                                                                                     |
| table            | table name that the model created in                                                                                                                      |
| description      | description of the model                                                                                                                                  |
| dbt_version      | dbt's version the model creates                                                                                                                           |
| invocation_id    | [invocation_id][invocation-id] the model affects. [invocation_id][invocation-id] is generated for each dbt command execution                              |
| node             | Full object representation of the dbt model executed                                                                                                      |
| status           | dbt's interpretation of runtime success, failure, or error that affects to the model                                                                      |
| thread_id        | Which thread executed this node? E.g. `Thread-1`                                                                                                          |
| execution_time   | Total time spent executing the model (node)                                                                                                               |
| timing           | Array that breaks down execution time into steps (often `compile` + `execute`)                                                                            |
| adapter_response | Dictionary of metadata returned from the database, which varies by adapter. E.g. success `code`, number of `rows_affected`, total `bytes_processed`, etc. |
| message          | How dbt will report this result on the CLI, based on information returned from the database                                                               |
| updated_at       | timestamp at which the row updated                                                                                                                        |

You can add your *additional_columns* to the table which might contain supplemental information (e.g. git information that generates the models).  See [Variables](#variables) section for details.

## Install

1. define package dependency in your `packages.yml`

    ```yaml
    # in your package.yml
    packages:
    - git: "git@github.com:everpeace/dbt-models-metadata.git"
      revision: v0.0.1
    ```

    For latest release, see https://github.com/everpeace/dbt-models-metadata/releases

2. please define [run-on-end] hook to generate model's metadata table

    ```yaml
    # in your dbt_project.yml
    on-run-end:
    - '{{models_metadata.generate(results)}}'
    ```

## Variables

You can configure this package via [`var`][var] in your `dbt_project.yml`

```yaml
vars:
  models_metadata:
    # table_name specifies metadata table name
    table_name: dbt_models_metadata
    # schema specifies the schema in which metadata table is created
    #   target schema will be used if not set
    schema: your_desired_schema
    
    # You can define additional columns to the metadata table
    # git information would be very useful when your project is maintained by git
    additional_columns:
    - name: 'git_repo'
      value: 'http://github.com/everpeace/dbt-models-metadata'
      dtype: 'text'
    - name: 'git_commit_hash'
      value: '{{ env_var("GIT_COMMIT_HASH") }}' # you can use various macro here
      dtype: 'text'

      # Column data type is defined by Column API
      #   see: https://docs.getdbt.com/reference/dbt-classes#column
      # dtype: The data type of the column (database-specific)
      # char_size: <If dtype is a variable width character type, the size of the column, or else None>
      # numeric_size: <If dtype is a fixed precision numeric type, the size of the column, or else None>
```

## How It Works At a Glance

To understand how dbt-models-metadata package works, inspecting `integration_test` directory is handy.

```shell
$ cd integration_tests/test

# specify sample profile directory
$ export DBT_PROFILES_DIR=$(pwd)/../.profiles

# prepare sample postgres server
$  docker run --name dbt-models-metadata-postgres \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_INITDB_ARGS="--encoding=UTF8 --no-locale" \
    -p 5432:5432 \
    --rm -d postgres

# dbt run!
#   note that you would need GIT_COMMIT_HASH environment variable
#   because the sample project has 'git_commit_hash' additional columns 
#   which refers to the environment variable
$ dbt deps
$ GIT_COMMIT_HASH=$(git rev-parse head) dbt build
...
11:02:37  Running 1 on-run-end hook
11:23:05  [dbt-models-metadata] Creating table: "integration_tests_postgres.dbt_models_metadata"
11:23:05  [dbt-models-metadata] Adding columns: [<Column unique_id (text)>, <Column database (text)>, <Column schema (text)>, <Column "table" (text)>, <Column description (text)>, <Column dbt_version (text)>, <Column invocation_id (text)>, <Column node (jsonb)>, <Column status (text)>, <Column thread_id (text)>, <Column execution_time (double precision)>, <Column timing (jsonb)>, <Column adapter_response (jsonb)>, <Column message (text)>, <Column updated_at (timestamptz)>, <Column git_repo (text)>, <Column git_commit_hash (text)>]
11:23:05  [dbt-models-metadata] Removing columns: []
11:02:37  [dbt-models-metadata] 2 rows will be affected in "integration_tests_postgres.dbt_models_metadata"
11:02:37  1 of 1 START hook: models_metadata_integration_tests.on-run-end.0 .............. [RUN]
11:02:37  1 of 1 OK hook: models_metadata_integration_tests.on-run-end.0 ................. [COMMIT in 0.00s]

# see the metadata table
$ cat <<EOT | PGPASSWORD=password psql -h localhost -U postgres
    select * from integration_tests_postgres.dbt_models_metadata;
EOT
# ...you'll see the table contents...

# cleanup sample postgres server
$ docker stop dbt-models-metadata-postgres
```

## LICENSE

[MIT License](./LICENSE)

## Acknowledgement

This project is inspired by https://github.com/dbt-content/google-datacatalog-dbt-tag

[dbt]: https://docs.getdbt.com/
[run-on-end]: https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end
[var]: https://docs.getdbt.com/reference/dbt-jinja-functions/var
[run-on-end-ctx]: https://docs.getdbt.com/reference/dbt-jinja-functions/on-run-end-context
[results]: https://docs.getdbt.com/reference/dbt-jinja-functions/on-run-end-context#results
[run-results-json]: https://docs.getdbt.com/reference/artifacts/run-results-json
[invocation-id]: https://docs.getdbt.com/reference/dbt-jinja-functions/invocation_id
