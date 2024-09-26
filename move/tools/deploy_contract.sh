#!/bin/bash
###
 # @Author: JackyHuang hhyyy9@gmail.com
 # @Date: 2024-08-01 19:36:32
 # @LastEditors: JackyHuang hhyyy9@gmail.com
 # @LastEditTime: 2024-09-20 18:18:58
 # @FilePath: /event_verifier/tools/deploy_contract.sh
 # @Description: 
 # 
 # Copyright (c) 2024 by ${git_name_email}, All Rights Reserved. 
### 

set -e  # Exit immediately if a command exits with a non-zero status.

# Configuration
CONTRACT_NAME="logistics_platform"
PACKAGE_DIR="../"
SKIP_FETCH_LATEST_GIT_DEPS="--skip-fetch-latest-git-deps" # Optional

# Check if the user provided the necessary arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <network> <account_address>"
    echo "Available networks: local, devnet, mainnet"
    exit 1
fi

NETWORK=$1
ACCOUNT_ADDRESS=$2
PROFILE_NAME=""

case $NETWORK in
    local)
        PROFILE_NAME="local"
        ;;
    devnet|mainnet)
        PROFILE_NAME="default"
        ;;
    *)
        echo "Invalid network choice: $NETWORK"
        echo "Available networks: local, devnet, mainnet"
        exit 1
        ;;
esac

# Check if local testnet is ready (only applicable for local network)
if [ "$NETWORK" = "local" ]; then
    if ! curl -s http://127.0.0.1:8070 > /dev/null; then
        echo "Local network is not running. Please start it using create_local_chain.sh."
        exit 1
    fi
fi

# Create profile if it doesn't exist (only applicable for local network)
if [ "$NETWORK" = "local" ] && ! aptos config show-profiles | grep -q $PROFILE_NAME; then
    echo "Creating $PROFILE_NAME profile..."
    aptos init --profile $PROFILE_NAME --network $NETWORK
fi

echo "Publishing the module..."
aptos move publish --profile $PROFILE_NAME --package-dir $PACKAGE_DIR --named-addresses $CONTRACT_NAME=$ACCOUNT_ADDRESS $SKIP_FETCH_LATEST_GIT_DEPS

#echo "Initializing the event verifier..."
#aptos move run --profile $PROFILE_NAME --function-id ${ACCOUNT_ADDRESS}::$CONTRACT_NAME::initialize

echo "Event verifier contract deployed to $NETWORK with account address $ACCOUNT_ADDRESS."
