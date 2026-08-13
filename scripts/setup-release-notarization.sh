#!/usr/bin/env bash

set -euo pipefail

PROFILE_NAME="${VOICEINK_NOTARY_PROFILE:-VoiceInk-Notarization}"
TEAM_ID="V6J6A3VWY2"

printf 'Apple Developer Apple ID: '
read -r APPLE_ID || true

if [[ -z "$APPLE_ID" ]]; then
    printf 'error: Apple ID is required\n' >&2
    exit 1
fi

printf '\nnotarytool will securely prompt for your app-specific password.\n'
xcrun notarytool store-credentials "$PROFILE_NAME" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --validate

printf '\nSaved and validated notarytool profile: %s\n' "$PROFILE_NAME"
