#!/usr/bin/env bash

# a simple testing framework for sccrypt.sh

set -e

# Parse command line arguments
VERBOSE_MODE=false
WRITE_SUMMARY=false
export VERBOSE_MODE
export WRITE_SUMMARY
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE_MODE=true
            export VERBOSE_MODE
            shift
            ;;
        --write-summary)
            WRITE_SUMMARY=true
            export WRITE_SUMMARY
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--verbose] [--write-summary]"
            exit 1
            ;;
    esac
done

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCCRYPT_PATH="$PROJECT_ROOT/sccrypt.sh"
TEST_DIR="$PROJECT_ROOT/test"
TEST_CASES_DIR="$TEST_DIR/test_cases"
TEST_RESULTS_DIR="$TEST_DIR/test_results"
TEST_KEY_FILE="$TEST_DIR/encryption.key"
TEST_TMP_DIR="/tmp/sccrypt_testing"

# Load helpers
source "$TEST_DIR/helpers_print.sh"
source "$TEST_DIR/helpers_assertion.sh"

# Pre-flight checks
if [ ! -f "$SCCRYPT_PATH" ]; then
    echo -e "${RED}Error: sccrypt.sh not found at $SCCRYPT_PATH${NC}"
    echo -e "${RED}Project root detected as: $PROJECT_ROOT${NC}"
    exit 1
fi
if [ ! -d "$TEST_CASES_DIR" ]; then
    echo -e "${RED}Error: test_cases directory not found at $TEST_CASES_DIR${NC}"
    exit 1
fi
if [ ! -f "$TEST_KEY_FILE" ]; then
    echo -e "${RED}Error: Test key file not found at $TEST_KEY_FILE${NC}"
    exit 1
fi


##########################################
# Start testing
#

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()
RUN_DATE=$(date '+%Y-%m-%d %H:%M:%S')
TOOL_VERSION=$(export SCCRYPT_KEY_FILE="$TEST_KEY_FILE" && $SCCRYPT_PATH -v 2>/dev/null || echo "Unknown")
# start with clean slate
cleanupTmpFiles
createTmpDir


printHeader "SCCRYPT TESTS"
echo -e "${BLUE}Run Date:${NC} $RUN_DATE"
echo -e "${BLUE}Tool Version:${NC} $TOOL_VERSION"
echo -e "${BLUE}Verbose Mode:${NC} $VERBOSE_MODE"
echo -e "${BLUE}Write Summary:${NC} $WRITE_SUMMARY"
echo -e "${BLUE}Script Location:${NC} $SCRIPT_DIR"
echo -e "${BLUE}Project Root:${NC} $PROJECT_ROOT"
echo -e "${BLUE}Test Cases Directory:${NC} $TEST_CASES_DIR"
echo -e "${BLUE}Sccrypt Path:${NC} $SCCRYPT_PATH"
echo -e "${BLUE}Test Key File:${NC} $TEST_KEY_FILE"
echo


source "$TEST_DIR/suite_arguments.sh"

source "$TEST_DIR/suite_modes.sh"

source "$TEST_DIR/suite_test_cases.sh"


##########################################
# Summary
#
cleanupTmpFiles
printHeader "TEST SUMMARY"

# Generate and display summary content
echo -e "${BLUE}Run Date:${NC} $RUN_DATE"
echo -e "${BLUE}Tool Version:${NC} $TOOL_VERSION"
echo -e "${BLUE}Tests Run:${NC} $TESTS_RUN"
echo -e "${GREEN}Tests Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Tests Failed:${NC} $TESTS_FAILED"

if [ $TESTS_FAILED -gt 0 ]; then
    echo
    echo -e "${RED}Failed Tests:${NC}"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $failed_test"
    done
    echo
else
    echo
    echo -e "${GREEN}All tests passed!${NC}"
    echo
fi

# Write summary to file if requested
if [ "$WRITE_SUMMARY" = true ]; then
    writePlainTextSummaryToFile "$TOOL_VERSION" "$RUN_DATE"
fi

# Set exit code based on test results
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
