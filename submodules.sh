#!/bin/bash

# Deploy Next.js project on Vercel
vercel

# Run git submodule update with GitHub access token
echo "Running 'git submodule update --init --recursive'..."
export GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN
export GIT_ASKPASS=echo
git config --global credential.helper cache
git submodule update --init --recursive
