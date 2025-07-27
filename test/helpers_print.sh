#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

printHeader() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

printTestStart() {
    echo -e "${YELLOW}Testing:${NC} $1"
    TESTS_RUN=$((TESTS_RUN + 1))
}

printPass() {
    echo -e "  ${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

printFail() {
    echo -e "  ${RED}✗ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$2: $1")
}

writePlainTextSummaryToFile() {
    local version="$1"
    local run_date="$2"
    
    # Create test results directory if it doesn't exist
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Format run date for filename (replace spaces and colons with underscores)
    local filename_date=$(echo "$run_date" | sed 's/[ :]/_/g')
    local filename_version=$(echo "$version" | sed 's/ /_/g')
    
    # Create filename
    local summary_file="$TEST_RESULTS_DIR/${filename_version}__${filename_date}.log"
    
    # Write summary to file
    {
        echo "SCCRYPT TEST SUMMARY"
        echo "===================="
        echo "Run Date: $run_date"
        echo "Tool Version: $version"
        echo "Tests Run: $TESTS_RUN"
        echo "Tests Passed: $TESTS_PASSED"
        echo "Tests Failed: $TESTS_FAILED"
        echo ""
        
        if [ $TESTS_FAILED -gt 0 ]; then
            echo "Failed Tests:"
            for failed_test in "${FAILED_TESTS[@]}"; do
                echo "  ✗ $failed_test"
            done
        else
            echo "All tests passed!"
        fi
    } > "$summary_file"
    
    echo -e "${BLUE}Summary written to:${NC} $summary_file"
}
