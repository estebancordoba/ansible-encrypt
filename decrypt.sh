#!/bin/bash

# Include the list of files
source files_to_process.sh

VAULT_PASSWORD_FILE=".vault_pass"

# Check if ansible-vault is installed
if ! command -v ansible-vault &> /dev/null; then
    echo "ansible-vault is not installed. Please install it to continue."
    exit 1
fi

# Password handling
if [ -f "$VAULT_PASSWORD_FILE" ]; then
    VAULT_CMD="--vault-password-file $VAULT_PASSWORD_FILE"
else
    echo -n "Enter the ansible-vault password: "
    read -s VAULT_PASSWORD
    echo
    VAULT_CMD="--vault-password $VAULT_PASSWORD"
fi

for file in "${FILES_TO_PROCESS[@]}"; do
  encrypted_file="${file}.encrypted"
  if [ -f "$encrypted_file" ]; then
    original_file=$(echo $encrypted_file | sed 's/.encrypted$//')
    if [ -f "$original_file" ]; then
      echo -n "The file $original_file already exists. Do you want to overwrite it? (y/n): "
      read overwrite
      if [ "$overwrite" != "y" ]; then
        echo "Skipping $original_file"
        continue
      fi
    fi
    ansible-vault decrypt $VAULT_CMD "$encrypted_file" --output "$original_file"
    echo "Decrypted $encrypted_file to $original_file"
  else
    echo "$encrypted_file does not exist and was not decrypted."
