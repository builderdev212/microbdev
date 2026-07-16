#!/bin/bash
MYDIR=$(pwd)
files=$(find . -type f -name 'coverage_test*.dat')
echo "$files"
verilator_coverage --write-info coverage.info $files
cd ../../
lcov_cobertura verif/cocotb/coverage.info -o verif/cocotb/coverage.xml
cd $MYDIR
