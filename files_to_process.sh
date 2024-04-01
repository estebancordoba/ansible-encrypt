#!/bin/bash

# List of files to encrypt/decrypt

# DEBUG AND STAGING
FILES_TO_PROCESS=(
  ".env"
  ".env.staging"
  "android/app/src/debug/google-services.json"
  "android/app/src/debug/debug.keystore"
  "android/app/src/stagingrelease/google-services.json"
  "android/app/src/stagingrelease/debug.keystore"
  "ios/Environments/Staging/GoogleService-Info.plist"
  "android/app/src/debug/my-release-key.keystore"
)
