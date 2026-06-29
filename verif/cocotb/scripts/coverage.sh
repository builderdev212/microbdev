#!/bin/bash
MYDIR=$(pwd)
files=$(find . -type f -name 'coverage_test*.dat')
echo "$files"
verilator_coverage --write-info coverage.info $files
cd ../../../../
lcov_cobertura verif/cocotb/tests/$MODULE_NAME/coverage.info -o verif/cocotb/tests/$MODULE_NAME/coverage.xml
awk -F 'branch-rate="|"' -v pkg="$MODULE_NAME" '/<package / && $0 ~ pkg {print "branch-rate=\"" $4 * 100 "\""; exit}' verif/cocotb/tests/$MODULE_NAME/coverage.xml
cd $MYDIR
