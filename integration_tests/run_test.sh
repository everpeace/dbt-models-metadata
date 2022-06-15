#! /usr/bin/env bash
set -ue -o pipefail

SCRIPT_DIR=$(cd $(dirname $0); pwd)

test_case=${1}
target=${2}
num_build=${3:-1}

function prep() {
    dbt clean -t "${target}"
    dbt deps -t "${target}"
}

echo "#"
echo "# ${test_case}: test"
echo "#"
function test() {
    prep
    for _ in $(seq 1 "${num_build}"); do
        dbt build -t "${target}"
    done
}
(cd "${SCRIPT_DIR}/${test_case}/test" && test)

echo "#"
echo "# ${test_case}: assert"
echo "#"
function assert() {
    prep
    dbt build -t "${target}"
}
(cd "${SCRIPT_DIR}/${test_case}/assert" && assert)
