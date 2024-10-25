#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Check for --dev argument
DEV_FLAG=""
if [[ "$*" == *"--dev"* ]]; then
    DEV_FLAG="--dev"
fi

# Compile the Move module
echo "Compiling the module..."
aptos move compile --package-dir ../ --skip-fetch-latest-git-deps $DEV_FLAG

echo "Event verifier contract successfully compiled."

# Run tests
echo "Running tests..."
aptos move test --package-dir ../ --skip-fetch-latest-git-deps $DEV_FLAG
