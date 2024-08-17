#!/bin/bash
###
 # @Author: JackyHuang hhyyy9@gmail.com
 # @Date: 2024-08-02 19:14:08
 # @LastEditors: JackyHuang hhyyy9@gmail.com
 # @LastEditTime: 2024-08-02 20:31:02
 # @FilePath: /event_verifier/tools/compile_contract.sh
 # @Description: 
 # 
 # Copyright (c) 2024 by ${git_name_email}, All Rights Reserved. 
### 

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
