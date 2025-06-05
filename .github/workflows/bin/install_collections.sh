#!/bin/bash

# Ansible stores collections in multiple places, which may vary by version.
# To keep everything in a controlled, local directory:
# - we use --collections-path
# - we force install only if the hash changes
# - we use --force because Galaxy doesn’t detect changes well

COLLECTIONS_DIR="$PWD/collections"
HASH_FILE="$COLLECTIONS_DIR/ansible_collections.hash"

function compute_hash(){
    (find "$COLLECTIONS_DIR" -type f ! -name "$(basename "$HASH_FILE")"; echo "$PWD/requirements.yml") \
    | sort | xargs sha256sum | sha256sum | cut -f1 -d' '
}

# Compute current hash excluding the hash file itself
CURRENT_HASH=$(compute_hash)

if [ ! -f "$HASH_FILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASH_FILE")" ]; then
    echo "Installing collections (hash mismatch or missing)..."
    ansible-galaxy collection install -r "$PWD/requirements.yml" --collections-path "$COLLECTIONS_DIR" --force

    # Recompute hash *after* install
    UPDATED_HASH=$(compute_hash)
    echo "$UPDATED_HASH" > "$HASH_FILE"
else
    echo "Collections are up to date. Skipping installation."
fi