#!/bin/bash

# Include the list of files
source files_to_process.sh

VAULT_PASSWORD_FILE=".vault_pass"
ENCRYPTED_SUFFIX=".encrypted"
encrypted_list=()
skipped_list=()
not_exist_list=()
encrypt_errors=()

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check if ansible-vault is installed
if ! command -v ansible-vault &> /dev/null; then
    echo -e "${RED}ansible-vault is not installed. Please install it to continue.${NC}"
    exit 1
fi

# Check if the password file exists
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo -e "${RED}The vault password file $VAULT_PASSWORD_FILE was not found. Please create it to continue.${NC}"
    exit 1
fi

VAULT_CMD="--vault-password-file $VAULT_PASSWORD_FILE"

# File processing
for file in "${FILES_TO_PROCESS[@]}"; do
  encrypted_file="${file}${ENCRYPTED_SUFFIX}"
  echo -e "Processing ${file}..."
  if [ -f "$file" ]; then
    if [ -f "$encrypted_file" ]; then
      while true; do
        echo -ne "${YELLOW}The file $encrypted_file already exists. Do you want to overwrite it? (Y/n): ${NC}"
        read -r overwrite
        overwrite=${overwrite:0:1}

        if [[ $overwrite == [Yy] ]]; then
            echo -e "${YELLOW}Overwriting $encrypted_file${NC}"
            break
        elif [[ $overwrite == [Nn] ]] || [[ -z $overwrite ]]; then
            echo -e "${YELLOW}Skipping $encrypted_file${NC}"
            skipped_list+=("$encrypted_file")
            continue 2 # Correctly continues with the next file in the for loop.
        else
            echo -e "${RED}Invalid input. Please enter Y or n.${NC}"
        fi
      done
    fi
    # Catch error output in a variable
    error_output=$(ansible-vault encrypt $VAULT_CMD "$file" --output "$encrypted_file" 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error encrypting $file: $error_output${NC}"
        encrypt_errors+=("$file: $error_output")
        continue
    fi
    echo -e "${GREEN}Encrypted $file${NC}"
    encrypted_list+=("$encrypted_file")
  else
    echo -e "${RED}$file does not exist and was not encrypted.${NC}"
    not_exist_list+=("$file")
  fi
done

echo -e "\n==================================================\n"
echo -e "${GREEN}Encryption process completed.${NC}\n"
if [ ${#encrypted_list[@]} -ne 0 ]; then
    echo -e "${GREEN}Successfully encrypted:${NC}"
    for file in "${encrypted_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${GREEN}No files were encrypted.${NC}"
fi

if [ ${#skipped_list[@]} -ne 0 ]; then
    echo -e "${YELLOW}Skipped:${NC}"
    for file in "${skipped_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${YELLOW}No files were skipped.${NC}"
fi

if [ ${#not_exist_list[@]} -ne 0 ]; then
    echo -e "${RED}Files not found:${NC}"
    for file in "${not_exist_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${RED}All files existed and were processed.${NC}"
fi

# Show decryption errors if any
if [ ${#encrypt_errors[@]} -ne 0 ]; then
    echo -e "${RED}Encryption errors:${NC}"
    for error in "${encrypt_errors[@]}"; do
        echo -e "${RED} - $error${NC}"
    done
fi
