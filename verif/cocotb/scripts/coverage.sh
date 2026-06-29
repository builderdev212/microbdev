#!/bin/bash
MYDIR=$(pwd)
files=$(find . -type f -name 'coverage_test*.dat')
echo "$files"
verilator_coverage --write-info coverage.info $files
cd ../../
lcov_cobertura verif/cocotb/coverage.info -o verif/cocotb/coverage.xml
awk -F 'branch-rate="|"' -v pkg="all" '/<package / && $0 ~ pkg {print "branch-rate=\"" $4 * 100 "\""; exit}' verif/cocotb/coverage.xml
cd $MYDIR
