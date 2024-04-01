#!/bin/bash

# Include the list of files
source files_to_process.sh

VAULT_PASSWORD_FILE=".vault_pass"
ENCRYPTED_SUFFIX=".encrypted"

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
  if [ -f "$file" ]; then
    ansible-vault encrypt $VAULT_CMD "$file" --output "${file}${ENCRYPTED_SUFFIX}"
    echo "Encrypted $file"
  else
    echo "$file does not exist and was not encrypted."
  fi
done
