#!/bin/bash

# Include the list of files
source files_to_process.sh

VAULT_PASSWORD_FILE=".vault_pass"
success_decrypt_list=()
not_found_list=()
skipped_list=()
decrypt_errors=()

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
  encrypted_file="${file}.encrypted"
  echo -e "Processing ${file}..."
  if [ -f "$encrypted_file" ]; then
    original_file=$(echo $encrypted_file | sed 's/.encrypted$//')
    if [ -f "$original_file" ]; then
      while true; do
        echo -ne "${YELLOW}The file $original_file already exists. Do you want to overwrite it? (Y/n): ${NC}"
        read -r overwrite
        overwrite=${overwrite:0:1}

        if [[ $overwrite == [Yy] ]]; then
          echo -e "${YELLOW}Overwriting $original_file${NC}"
          break
        elif [[ $overwrite == [Nn] ]] || [[ -z $overwrite ]]; then
          echo -e "${YELLOW}Skipping $original_file${NC}"
          skipped_list+=("$original_file")
          continue 2 # Correctly continues with the next file in the for loop.
        else
          echo -e "${RED}Invalid input. Please enter Y or n.${NC}"
        fi
      done
    fi
    # Catch error output in a variable
    error_output=$(ansible-vault decrypt $VAULT_CMD "$encrypted_file" --output "$original_file" 2>&1)
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error decrypting $encrypted_file: $error_output${NC}"
        decrypt_errors+=("$encrypted_file: $error_output")
        continue
    fi
    echo -e "${GREEN}Decrypted $encrypted_file to $original_file${NC}"
    success_decrypt_list+=("$original_file")
  else
    echo -e "${RED}$encrypted_file does not exist.${NC}"
    not_found_list+=("$encrypted_file")
  fi
done

echo -e "\n==================================================\n"
echo -e "${GREEN}Decryption process completed.${NC}\n"
if [ ${#success_decrypt_list[@]} -ne 0 ]; then
    echo -e "${GREEN}Successfully decrypted:${NC}"
    for file in "${success_decrypt_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${GREEN}No files were decrypted.${NC}"
fi

if [ ${#skipped_list[@]} -ne 0 ]; then
    echo -e "${YELLOW}Skipped:${NC}"
    for file in "${skipped_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${YELLOW}No files were skipped.${NC}"
fi

if [ ${#not_found_list[@]} -ne 0 ]; then
    echo -e "${RED}Files not found:${NC}"
    for file in "${not_found_list[@]}"; do
        echo -e " - ${file}"
    done
else
    echo -e "${RED}All files were found.${NC}"
fi

# Show decryption errors if any
if [ ${#decrypt_errors[@]} -ne 0 ]; then
    echo -e "${RED}Decryption errors:${NC}"
    for error in "${decrypt_errors[@]}"; do
        echo -e "${RED} - $error${NC}"
    done
fi
