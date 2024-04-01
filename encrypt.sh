#!/bin/bash

VAULT_PASSWORD_FILE=".vault_pass"
ENCRYPTED_SUFFIX=".encrypted"

# Lista de archivos a encriptar
FILES_TO_ENCRYPT=(
  ".env"
  ".env.staging"
  "android/app/src/debug/google-services.json"
  "android/app/src/debug/debug.keystore"
  "android/app/src/stagingrelease/google-services.json"
  "android/app/src/stagingrelease/debug.keystore"
  "ios/Environments/Staging/GoogleService-Info.plist",
  "android/app/src/debug/my-release-key.keystore"
)

for file in "${FILES_TO_ENCRYPT[@]}"; do
  if [ -f "$file" ]; then
    ansible-vault encrypt --vault-password-file $VAULT_PASSWORD_FILE "$file" --output "${file}${ENCRYPTED_SUFFIX}"
    echo "Encrypted $file"
  else
    echo "$file does not exist and was not encrypted."
  fi
done

