#!/usr/bin/env bash

printHeader "ENCRYPTION / DECRYPTION TEST CASES"

# Run tests on all test case files in numerical order
test_files=()
for test_file in "$TEST_CASES_DIR"/[0-9]*; do
    # Skip files with .sccrypt extension
    if [[ "$test_file" == *.sccrypt ]]; then
        continue
    fi
    if [ -f "$test_file" ]; then
        test_files+=("$test_file")
    fi
done
# Sort files numerically by filename
readarray -t sorted_test_files < <(printf '%s\n' "${test_files[@]}" | sort -V)

# Run tests on sorted files
for test_file in "${sorted_test_files[@]}"; do
    assertEncryptionCase "$test_file"
    assertDecryptionCase "$test_file"
done