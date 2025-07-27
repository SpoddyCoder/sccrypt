#!/usr/bin/env bash

createTmpDir() {
    mkdir -p "$TEST_TMP_DIR"
}

cleanupTmpFiles() {
    rm -rf "$TEST_TMP_DIR"
}

runCommand() {
    local arguments="$1"
    local output
    local exit_code
    
    # Build command
    local command="$SCCRYPT_PATH"
    if [ ! -z "$arguments" ]; then
        command="$command $arguments"
    fi
    
    # Run command and capture output/exit code
    if output=$(export SCCRYPT_KEY_FILE="$TEST_KEY_FILE" && eval "$command" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Return values via global variables
    COMMAND_OUTPUT="$output"
    COMMAND_EXIT_CODE="$exit_code"
}

displayTestInfo() {
    local arguments="$1"
    local expected_exit_code="$2"
    local expected_pattern="$3"
    
    if [ "$VERBOSE_MODE" = true ]; then
        echo -e "  ${BLUE}Arguments:${NC} $arguments"
        echo -e "  ${BLUE}Output:${NC}"
        echo "$COMMAND_OUTPUT"
        echo -e "  ${BLUE}Exit Code:${NC} $COMMAND_EXIT_CODE"
        
        if [ ! -z "$expected_exit_code" ]; then
            echo -e "  ${BLUE}Expected Exit Code:${NC} $expected_exit_code"
        fi
        
        if [ ! -z "$expected_pattern" ]; then
            echo -e "  ${BLUE}Expected Pattern:${NC} '$expected_pattern'"
        fi
    fi
}

testExitCode() {
    local test_name="$1"
    local arguments="$2"
    local expected_exit_code="${3:-0}"
    
    printTestStart "$test_name"
    runCommand "$arguments"
    displayTestInfo "$arguments" "$expected_exit_code"
    
    if [ "$COMMAND_EXIT_CODE" -eq "$expected_exit_code" ]; then
        printPass
    else
        printFail "Expected exit code $expected_exit_code, got $COMMAND_EXIT_CODE" "$test_name"
    fi
    echo
}

testOutput() {
    local test_name="$1"
    local arguments="$2"
    local expected_pattern="$3"
    
    printTestStart "$test_name"
    runCommand "$arguments"
    displayTestInfo "$arguments" "" "$expected_pattern"
    
    if echo "$COMMAND_OUTPUT" | grep -q "$expected_pattern"; then
        printPass
    else
        printFail "Output did not contain expected pattern '$expected_pattern'" "$test_name"
    fi
    echo
}

testLineCount() {
    local test_name="$1"
    local arguments="$2"
    local expected_line_count="$3"
    
    printTestStart "$test_name"
    runCommand "$arguments"
    
    # Count lines in output (handles empty output correctly)
    local actual_line_count
    if [ -z "$COMMAND_OUTPUT" ]; then
        actual_line_count=0
    else
        actual_line_count=$(echo "$COMMAND_OUTPUT" | wc -l)
    fi
    
    if [ "$VERBOSE_MODE" = true ]; then
        echo -e "  ${BLUE}Arguments:${NC} $arguments"
        echo -e "  ${BLUE}Output:${NC}"
        echo "$COMMAND_OUTPUT"
        echo -e "  ${BLUE}Exit Code:${NC} $COMMAND_EXIT_CODE"
        echo -e "  ${BLUE}Expected Line Count:${NC} $expected_line_count"
        echo -e "  ${BLUE}Actual Line Count:${NC} $actual_line_count"
    fi
    
    if [ "$actual_line_count" -eq "$expected_line_count" ]; then
        printPass
    else
        printFail "Expected $expected_line_count lines, got $actual_line_count lines" "$test_name"
    fi
    echo
}

testFileExists() {
    local test_name="$1"
    local file_path="$2"
    
    printTestStart "$test_name"
    
    if [ "$VERBOSE_MODE" = true ]; then
        echo -e "  ${BLUE}Checking file:${NC} $file_path"
    fi
    
    if [ -f "$file_path" ]; then
        printPass
    else
        printFail "File does not exist: $file_path" "$test_name"
    fi
    echo
}

testEncryptionCase() {
    local test_file="$1"
    local test_name=$(basename "$test_file")

    printTestStart "Test case: $test_name - encrypt check"
    runCommand "-e \"$test_file\""
    displayTestInfo "-e \"$test_file\""

    if [ "$COMMAND_EXIT_CODE" -eq 0 ]; then
        printPass
    else
        printFail "Encryption failed" "Test case: $test_name"
    fi
    echo
}

testDecryptionCase() {
    local test_file="$1"
    local sccrypt_file="$1.sccrypt"
    local test_name=$(basename "$test_file")

    printTestStart "Test case: $test_name.sccrypt - decrypt matches reference file"
    
    # Create temporary file for decryption output (needed to handle binary data properly)
    local temp_output="$TEST_TMP_DIR/decrypt_output_$$"
    
    # Run decryption command and redirect output to temp file
    local command="$SCCRYPT_PATH -d \"$sccrypt_file\""
    if output=$(export SCCRYPT_KEY_FILE="$TEST_KEY_FILE" && eval "$command" > "$temp_output" 2>&1); then
        COMMAND_EXIT_CODE=0
    else
        COMMAND_EXIT_CODE=$?
    fi
    
    if [ "$VERBOSE_MODE" = true ]; then
        echo -e "  ${BLUE}Arguments:${NC} -d \"$sccrypt_file\""
        echo -e "  ${BLUE}Output:${NC}"
        cat "$temp_output"
        echo -e "  ${BLUE}Exit Code:${NC} $COMMAND_EXIT_CODE"
    fi

    if [ "$COMMAND_EXIT_CODE" -ne 0 ]; then
        printFail "Decryption failed" "Test case: $test_name"
    else
        if [ ! -f "$temp_output" ]; then
            printFail "Decryption failed to create file" "Test case: $test_name"
        else
            # Use cmp for binary-safe comparison
            if cmp -s "$test_file" "$temp_output"; then
                printPass
            else
                printFail "Decryption output does not match test file" "Test case: $test_name"
            fi
        fi
    fi
    echo
}
