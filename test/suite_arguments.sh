#!/usr/bin/env bash

printHeader "ARGUMENT VALIDATION TESTS"


assertExitCode "Tool shows proper usage message (exit code)" \
    "" 1

assertOutput "Tool shows proper usage message (output)" \
    "" "Usage:"

assertExitCode "Rejects invalid switch -x" \
    "-x $TEST_CASES_DIR/1_empty_file" 1

assertExitCode "Rejects missing mode (-e or -d)" \
    "$TEST_CASES_DIR/1_empty_file" 1

assertExitCode "Rejects missing file argument" \
    "-e" 1

assertExitCode "Rejects non-existent file" \
    "-e non_existent_file.txt" 1

assertExitCode "Rejects conflicting flags -i and -c together" \
    "-e -i -c $TEST_CASES_DIR/1_empty_file" 1

assertExitCode "Version flag -v returns success" \
    "-v" 0

assertOutput "Version flag -v shows version info" \
    "-v" "sccrypt v"