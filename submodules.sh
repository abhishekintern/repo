#!/bin/bash

# Run git submodule update with GitHub access token
echo "Running 'git submodule update --init --recursive'..."
GIT_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN
GIT_URL="https://YOUR_GITHUB_USERNAME:${GIT_ACCESS_TOKEN}@github.com/abhishekintern/submodule1"
export GIT_ASKPASS=echo
git config --global credential.helper cache
git submodule update --init --recursive
