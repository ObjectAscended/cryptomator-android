#!/bin/bash

# Find all unsigned apks in the current directory (/build/artifacts/)
for unsigned_apk in cryptomator-*-unsigned.apk; do
    # Skip if no match found
    [ -e "$unsigned_apk" ] || continue

    # Extract variant name (e.g., cryptomator-foss-unsigned.apk -> foss)
    variant=$(echo "$unsigned_apk" | sed -e 's/^cryptomator-//' -e 's/-unsigned\.apk$//')

    echo "Signing variant: $variant"
    apksigner sign \
        --v4-signing-enabled false \
        --ks ../release.p12 \
        --ks-pass pass:$SIGNING_KEYSTORE_PASSWORD \
        --ks-key-alias $SIGNING_KEY_ALIAS \
        --key-pass pass:$SIGNING_KEY_PASSWORD \
        --out cryptomator-$variant.apk \
        "$unsigned_apk"
done