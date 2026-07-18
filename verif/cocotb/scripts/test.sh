#!/bin/bash
MYDIR=$(pwd)

# Get the full path of the test script to ensure relative path to tests.
# https://www.baeldung.com/linux/bash-get-location-within-script#4-full-bash-script-location
SCRIPT_PATH="${BASH_SOURCE}"
while [ -L "${SCRIPT_PATH}" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
  SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
  [[ ${SCRIPT_PATH} != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
done
SCRIPT_PATH="$(readlink -f "${SCRIPT_PATH}")"
SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"
BASE_DIR="$(dirname $(dirname "$SCRIPT_DIR"))"

# Get the test's directory in the tests/ directory.
while getopts "p:" flag
do
    case "$flag" in
        p) currenttest=$OPTARG;;
    esac
done

TEST_DIR="${SCRIPT_DIR}/tests/${currenttest}"
if [ -d "$TEST_DIR" ]; then
    echo "Found valid directory at: ${TEST_DIR}"
else
    echo "Error: Test directory not found. (${TEST_DIR})"
    exit 1
fi

# Simple checker to make sure that directory is valid. Assumes there must be a tb.py
if [[ ! -f "${TEST_DIR}/tb.py" ]]; then
    echo "Error: Invalid test path. (No tb.py)"
    exit 1
else
    echo "Valid test found."
fi

# Run test
cd $TEST_DIR
pytest -ra -q -n 5 --retries 2 --junitxml=${TEST_DIR}/test-results.xml

# Create coverage report
cd $BASE_DIR
files=$(find $TEST_DIR -type f -name 'coverage_test*.dat')
coverage_output=$(verilator_coverage --annotate ${TEST_DIR}/coverage $files)
line_cov=$(echo "${coverage_output}" | awk '/line *:/ { print $3 }')
toggle_cov=$(echo "${coverage_output}" | awk '/toggle *:/ { print $3 }')
branch_cov=$(echo "${coverage_output}" | awk '/branch *:/ { print $3 }')
expr_cov=$(echo "${coverage_output}" | awk '/expr *:/ { print $3 }')
fsm_state_cov=$(echo "${coverage_output}" | awk '/fsm_state *:/ { print $3 }')
fsm_arc_cov=$(echo "${coverage_output}" | awk '/fsm_arc *:/ { print $3 }')
annotate_cov=$(echo "${coverage_output}" | awk '/attached points covered/ { print $8 }')

cat << EOF > ${TEST_DIR}/coverage/coverage_report.yml
module: $currenttest
coverage:
  line: $line_cov
  toggle: $toggle_cov
  branch: $branch_cov
  expr: $expr_cov
  fsm_state: $fsm_state_cov
  fsm_arc: $fsm_arc_cov
  annotate: $annotate_cov
EOF

# Return to place test was run from.
cd $MYDIR
