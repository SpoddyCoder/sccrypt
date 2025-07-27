#!/usr/bin/env bash

printHeader "MODE TESTS"


# Test encrypt/decrypt tostdout mode (default)
assertExitCode "Encrypt to stdout (default mode)" \
    "-e $TEST_CASES_DIR/2_simple_string"

assertExitCode "Decrypt to stdout (default mode)" \
    "-d $TEST_CASES_DIR/2_simple_string.sccrypt"

assertLineCount "Encrypt to stdout does not contain additional output" \
    "-e $TEST_CASES_DIR/2_simple_string" 1

assertLineCount "Decrypt to stdout does not contain additional output" \
    "-d $TEST_CASES_DIR/2_simple_string.sccrypt" 1

# Test encrypt/decrypt with create mode (-c)
cp $TEST_CASES_DIR/2_simple_string $TEST_TMP_DIR/test_create_encrypt
assertExitCode "Encrypt with -c flag" \
    "-e -c $TEST_TMP_DIR/test_create_encrypt"

assertFileExists "Check .sccrypt file was created" \
    "$TEST_TMP_DIR/test_create_encrypt.sccrypt"

cp $TEST_CASES_DIR/2_simple_string $TEST_TMP_DIR/test_create_encrypt_msg
assertOutput "Encrypt with -c flag shows create message" \
    "-e -c $TEST_TMP_DIR/test_create_encrypt_msg" "Created encrypted file:"

cp $TEST_CASES_DIR/2_simple_string.sccrypt $TEST_TMP_DIR/test_create_decrypt.sccrypt
assertExitCode "Dencrypt with -c flag" \
    "-d -c $TEST_TMP_DIR/test_create_decrypt.sccrypt"

assertFileExists "Check original file was created" "$TEST_TMP_DIR/test_create_decrypt"

cp $TEST_CASES_DIR/2_simple_string.sccrypt $TEST_TMP_DIR/test_create_decrypt_msg.sccrypt
assertOutput "Decrypt with -c flag shows create message" \
    "-d -c $TEST_TMP_DIR/test_create_decrypt_msg.sccrypt" "Created decrypted file:"

# Test encrypt/decrypt with in-place mode (-i)
cp $TEST_CASES_DIR/2_simple_string $TEST_TMP_DIR/test_inplace_encrypt
chmod 644 $TEST_TMP_DIR/test_inplace_encrypt
assertExitCode "Encrypt with -i flag" \
    "-e -i $TEST_TMP_DIR/test_inplace_encrypt"

assertFileExists "Check file was encrypted in-place" \
    "$TEST_TMP_DIR/test_inplace_encrypt"

cp $TEST_CASES_DIR/2_simple_string $TEST_TMP_DIR/test_inplace_encrypt_msg
chmod 644 $TEST_TMP_DIR/test_inplace_encrypt_msg
assertOutput "Encrypt with -i flag shows in-place message" \
    "-e -i $TEST_TMP_DIR/test_inplace_encrypt_msg" "Encrypted file in-place:"

cp $TEST_CASES_DIR/2_simple_string.sccrypt $TEST_TMP_DIR/test_inplace_decrypt
chmod 644 $TEST_TMP_DIR/test_inplace_decrypt
assertExitCode "Decrypt with -i flag" \
    "-d -i $TEST_TMP_DIR/test_inplace_decrypt"

assertFileExists "Check file was decrypted in-place" \
    "$TEST_TMP_DIR/test_inplace_decrypt"

cp $TEST_CASES_DIR/2_simple_string.sccrypt $TEST_TMP_DIR/test_inplace_decrypt_msg
chmod 644 $TEST_TMP_DIR/test_inplace_decrypt_msg
assertOutput "Decrypt with -i flag shows in-place message" \
    "-d -i $TEST_TMP_DIR/test_inplace_decrypt_msg" "Decrypted file in-place:"
