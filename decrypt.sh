#!/bin/bash

VAULT_PASSWORD_FILE=".vault_pass"

# Lista de archivos a desencriptar (mismos archivos pero con sufijo .encrypted)
FILES_TO_DECRYPT=(
  ".env.encrypted"
  ".env.staging.encrypted"
  "android/app/src/debug/google-services.json.encrypted"
  "android/app/src/debug/debug.keystore.encrypted"
  "android/app/src/stagingrelease/google-services.json.encrypted"
  "android/app/src/stagingrelease/debug.keystore.encrypted"
  "ios/Environments/Staging/GoogleService-Info.plist.encrypted"
)

for file in "${FILES_TO_DECRYPT[@]}"; do
  original_filename=$(echo $file | sed 's/.encrypted$//')
  if [ -f "$file" ]; then
    ansible-vault decrypt --vault-password-file $VAULT_PASSWORD_FILE "$file" --output "$original_filename"
    echo "Decrypted $file to $original_filename"
  else
    echo "$file does not exist and was not decrypted."
  fi
done

