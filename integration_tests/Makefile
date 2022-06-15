TARGET ?= postgres

HERE := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

export DBT_PROFILES_DIR=$(HERE)/.profiles
export GIT_COMMIT_HASH=$(shell git rev-parse head)

.PHONY: test
test: test-insert-and-update test-update-additional-columns

.PHONY: test-insert-and-update
test-insert-and-update:
	$(HERE)run_test.sh insert-and-update $(TARGET) 2

.PHONY: test-%
test-%:
	$(HERE)run_test.sh $* $(TARGET)

start-postgres:
	@docker run --name dbt-models-metadata-postgres \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_INITDB_ARGS="--encoding=UTF8 --no-locale" \
		-p 5432:5432 \
		--rm -d postgres

stop-postgres:
	@docker kill dbt-models-metadata-postgres
