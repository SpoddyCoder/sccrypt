#!/usr/bin/env bash

# sccrypt.sh - Secret encryption/decryption tool
VERSION="1.2.0"

set -e

# Function to display usage
usage() {
    echo
    echo "Usage: $(basename "$0") <-e|-d> [-i|-c] <file>"
    echo "       $(basename "$0") -v"
    echo "  -e  Encrypt the file"
    echo "  -d  Decrypt the file"
    echo "  -i  Modify file in-place (optional)"
    echo "  -c  Create file.sccrypt and keep original file (optional)"
    echo "  -v  Show version number"
    echo "  file  Path to the file to encrypt/decrypt"
    echo
    exit 1
}

# Helper function to encrypt a file
# Usage: encrypt_file <input_file> [output_file]
# If output_file is not provided, outputs to stdout
encrypt_file() {
    local input_file="$1"
    local output_file="$2"
    
    if [[ -z "$output_file" ]]; then
        # Output to stdout
        openssl enc -aes-256-cbc -salt -pbkdf2 -iter 600000 -in "$input_file" -pass pass:"$KEY" | base64 -w 0
        echo  # Add newline after base64 output
    else
        # Output to file
        openssl enc -aes-256-cbc -salt -pbkdf2 -iter 600000 -in "$input_file" -pass pass:"$KEY" | base64 -w 0 > "$output_file"
        echo >> "$output_file"  # Add newline
    fi
}

# Helper function to decrypt a file
# Usage: decrypt_file <input_file> [output_file]
# If output_file is not provided, outputs to stdout
decrypt_file() {
    local input_file="$1"
    local output_file="$2"
    
    if [[ -z "$output_file" ]]; then
        # Output to stdout
        base64 -d "$input_file" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -pass pass:"$KEY"
    else
        # Output to file
        base64 -d "$input_file" | openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -pass pass:"$KEY" > "$output_file"
    fi
}

# Check if key file exists
KEY_FILE="${SCCRYPT_KEY_FILE:-$HOME/.sccrypt.key}"
if [[ ! -f "$KEY_FILE" ]]; then
    echo "Error: Key file not found at $KEY_FILE" >&2
    exit 1
fi

# Parse command line arguments
MODE=""
IN_PLACE=false
CREATE_COPY=false
FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--encrypt)
            MODE="encrypt"
            shift
            ;;
        -d|--decrypt)
            MODE="decrypt"
            shift
            ;;
        -i|--in-place)
            if [[ "$CREATE_COPY" == true ]]; then
                echo "Error: Cannot use -i and -c together" >&2
                usage
            fi
            IN_PLACE=true
            shift
            ;;
        -c|--create)
            if [[ "$IN_PLACE" == true ]]; then
                echo "Error: Cannot use -i and -c together" >&2
                usage
            fi
            CREATE_COPY=true
            shift
            ;;
        -v|--version)
            echo "sccrypt v$VERSION"
            exit 0
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            usage
            ;;
        *)
            if [[ -z "$FILE" ]]; then
                FILE="$1"
            else
                echo "Error: Too many arguments" >&2
                usage
            fi
            shift
            ;;
    esac
done

# Check required arguments
if [[ -z "$MODE" || -z "$FILE" ]]; then
    usage
fi

# Check if file exists
if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found" >&2
    exit 1
fi

# Read the key
KEY=$(cat "$KEY_FILE")
if [[ -z "$KEY" ]]; then
    echo "Error: Key file is empty" >&2
    exit 1
fi

# Perform encryption or decryption
if [[ "$IN_PLACE" == true ]]; then
    # Create temporary file for in-place modification
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"' EXIT
    
    case "$MODE" in
        encrypt)
            encrypt_file "$FILE" "$TEMP_FILE"
            mv "$TEMP_FILE" "$FILE"
            ;;
        decrypt)
            decrypt_file "$FILE" "$TEMP_FILE"
            mv "$TEMP_FILE" "$FILE"
            ;;
    esac
elif [[ "$CREATE_COPY" == true ]]; then
    # Create a copy with .sccrypt extension or remove .sccrypt extension
    case "$MODE" in
        encrypt)
            OUTPUT_FILE="${FILE}.sccrypt"
            encrypt_file "$FILE" "$OUTPUT_FILE"
            echo "Created encrypted file: $OUTPUT_FILE"
            ;;
        decrypt)
            # Determine output filename by removing .sccrypt extension if present
            if [[ "$FILE" == *.sccrypt ]]; then
                OUTPUT_FILE="${FILE%.sccrypt}"
            else
                OUTPUT_FILE="${FILE}.decrypted"
            fi
            decrypt_file "$FILE" "$OUTPUT_FILE"
            echo "Created decrypted file: $OUTPUT_FILE"
            ;;
    esac
else
    # Output to stdout (default behavior)
    case "$MODE" in
        encrypt)
            encrypt_file "$FILE"
            ;;
        decrypt)
            decrypt_file "$FILE"
            ;;
    esac
fi

exit 0