#!/bin/bash

# GitHub submodule repo addresses without the "https://" prefix
declare -A remotes=(
    ["submodule1"]="github.com/abhishekintern/submodule1"
    ["submodule2"]="github.com/abhishekintern/submodule2"
)

# Check if GITHUB_ACCESS_TOKEN environment variable is set
if [[ -z "$GITHUB_ACCESS_TOKEN" ]]; then
    echo "Error: GITHUB_ACCESS_TOKEN is empty"
    exit 1
fi

# Stop execution on error - don't proceed if something goes wrong
set -e

# Get submodule commit
output=$(git submodule status --recursive) # Get submodule info

# Extract each submodule commit hash and path
submodules=$(echo "$output" | sed "s/ -/__/g" | sed "s/ /=/g" | sed "s/-//g" | tr "__" "\n")

for submodule in $submodules; do
    IFS="=" read -r COMMIT SUBMODULE_PATH <<<"$submodule"

    SUBMODULE_GITHUB="${remotes[$SUBMODULE_PATH]}"

    # Set up an empty temporary work directory
    rm -rf tmp || true # Remove the tmp folder if it exists
    mkdir tmp          # Create the tmp folder
    cd tmp             # Go into the tmp folder

    # Checkout the current submodule commit
    git init                                                                      # Initialize empty repo
    git remote add "$SUBMODULE_PATH" "https://$GITHUB_ACCESS_TOKEN@$SUBMODULE_GITHUB" # Add origin of the submodule
    git fetch --depth=1 "$SUBMODULE_PATH" "$COMMIT"                                   # Fetch only the required version
    git checkout "$COMMIT"                                                          # Checkout the right commit

    # Move the submodule from tmp to the submodule path
    cd ..                     # Go up one level
    rm -rf tmp/.git           # Remove .git folder
    mv tmp/* "$SUBMODULE_PATH"/ # Move the submodule to the submodule path

    # Clean up
    rm -rf tmp # Remove the tmp folder
done
