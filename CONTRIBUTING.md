# Contributing

Contribution and bug fix PR's are welcome - but please adhere to the following guidelines;

* KISS - this tool is simple by design, other projects exist that do a lot more
* `./run_tests.sh` - to ensure nothing is broken in the core tool functionality
* Do not bump version - this will be done on merge to main
* Be hygenic - update docs, add comments and new tests where appropriate


## Test Framework Overview

`sccrypt` uses a bash-based testing framework located in the `test/` directory.

### Basic Usage

```bash
# Run all tests
./test/run_tests.sh

# Run tests with verbose output
./test/run_tests.sh --verbose

# Run tests and write summary to file
./test/run_tests.sh --write-summary

# Run tests with both verbose output and summary
./test/run_tests.sh --verbose --write-summary
```

### Directory Structure

```
test/
├── run_tests.sh            # Main test runner script
├── helpers_print.sh        # Print helpers
├── helpers_assertion.sh    # Test assertion methods and helpers
├── encryption.key          # Test encryption key file
├── test_cases/             # Test case files (original + encrypted)
└── test_results/           # Test summaries for each release
```

### `helpers_assertion.sh`
Methods to help run assertion tests - these are the core of the testing framework.

#### `runCommand "arguments"`
Used by the `test*` methods to run an `scrrypt` command in a standard way & store the results in global vars.

```bash
runCommand "-e testfile.txt"
echo "Output: $COMMAND_OUTPUT"
echo "Exit Code: $COMMAND_EXIT_CODE"
```

#### `testExitCode "test_name" "arguments" "expected_exit_code"`
Tests that a command returns the expected exit code.

```bash
testExitCode "Tool shows proper usage message" "" 1
testExitCode "Version flag returns success" "-v" 0
```

#### `testOutput "test_name" "arguments" "expected_pattern"`
Tests that command output contains a specific pattern.

```bash
testOutput "Tool shows usage message" "" "Usage:"
testOutput "Version flag shows version info" "-v" "sccrypt v"
```

#### `testLineCount "test_name" "arguments" "expected_line_count"`
Tests that command output has exactly the expected number of lines.

```bash
testLineCount "Encrypt to stdout does not contain additional output" "-e testfile.txt" 1
testLineCount "Empty output has zero lines" "--invalid-flag" 0
```

#### `testFileExists "test_name" "file_path"`
Tests that a file exists at the specified path.

```bash
testFileExists "Check .sccrypt file was created" "$TEST_TMP_DIR/test.sccrypt"
```

#### `testEncryptionCase "test_file"`
Tests that a file can be encrypted successfully.

```bash
testEncryptionCase "$TEST_CASES_DIR/2_simple_string"
```

#### `testDecryptionCase "test_file"`
Tests that an encrypted file can be decrypted and matches the original.

```bash
testDecryptionCase "$TEST_CASES_DIR/2_simple_string"
```
