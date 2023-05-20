#!/bin/bash

# Function to clone or update submodules recursively
clone_or_update_submodules() {
    git config submodule.$1.url https://$GITHUB_ACCESS_TOKEN@$2
    git config submodule.$1.active true
    git submodule update --init --recursive $1
    git submodule update --remote $1
}

# Set up GitHub access token
if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
    echo "Error: GITHUB_ACCESS_TOKEN is empty"
    exit 1
fi

# Stop execution on error - don't proceed if something goes wrong
set -e

# Clone or update the main repository and its submodules
git clone --recursive https://$GITHUB_ACCESS_TOKEN@github.com/abhishekintern/submodule1
cd submodule1

# Get submodule commit and update submodules recursively
output=$(git submodule status --recursive)
while IFS= read -r line; do
    submodule_path=${line#*-} # Remove prefix
    submodule_commit=${submodule_path% *} # Remove suffix

    submodule_path=${submodule_path#* } # Extract submodule path
    submodule_path=${submodule_path%/} # Remove trailing slash

    echo "Processing submodule: $submodule_path"

    cd $submodule_path

    submodule_url=$(git config --get remote.origin.url)
    submodule_url=${submodule_url#https://}

    clone_or_update_submodules "$submodule_path" "$submodule_url"

    cd ..
done <<< "$output"

# Clean up
rm -rf .git

echo "Submodules have been cloned/updated successfully."
