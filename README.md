<!-- markdownlint-disable MD022 MD032 MD031 MD040 MD047 -->

# Logistics Platform

## User Accounts

### User1
- Mnemonic: because isolate ring ethics smart else glimpse hazard leg tower harbor lyrics
- Public Key: 0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea
- Private Key: 0x9a34603def11e329864c45b520dab07e869a3bc7dc9910da310169130f2886e9

### User2
- Mnemonic: bridge settle honey stool daughter call candy bitter play alarm company gospel
- Public Key: 0x55c8dea9a4be53e5ca8b6c3908b099e7f0984f2cf3eebce681b661942f47316b
- Private Key: 0x9a15926fb0efa15bf1b3cd7c02de418ea611d01a99e0cb2a797610cb666c8ada

### User3
- Mnemonic: dash legal clinic travel liberty animal awkward cupboard eight love child harsh
- Public Key: 0xf259b5f88ed806f472f8bb72905e4de73c5dcf5cb8f09d9cecb839d6b085b3ed
- Private Key: 0x00ab4b2fb732b8c92c2e2ce969bf36b9d96f339842adb25b3f64f4051f52a770

### User4
- Mnemonic: scrub glance perfect zebra crush prepare convince merit any crush ritual burst
- Public Key: 0x08112834c88e612d3e522b722d18d4d54e0f9d70ede87c98264ea746ea9643ea
- Private Key: 0xb3248221137c9f88430fbd860da59d978d7738f33827a88244f23407ca484a57

## Setup Instructions

1. Show Aptos profiles:
   ```
   aptos config show-profiles
   ```

2. Initialize Aptos with default profile:
   ```
   aptos init --profile default --network devnet
   ```
   When prompted, input: 0x9a34603def11e329864c45b520dab07e869a3bc7dc9910da310169130f2886e9

3. Edit the address in `Move.toml`

4. Compile the contract:
   ```
   ./compile_contract.sh --dev
   ```

5. Deploy the contract:
   ```
   ./deploy_contract.sh devnet 0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea
   ```

6. Verify the account initialization:
   Open [Aptos Explorer](https://explorer.aptoslabs.com/account/0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea?network=devnet)

7. Configure the frontend:
   Edit the `REACT_APP_MOVE_MODULE_ADDRESS` in `dapp/.env` file to the deployed address.

8. Start the frontend:
   ```
   cd dapp
   npm start
   ```

9. Wallet setup:
   - Recover all accounts in Petra wallet
   - Switch to devnet
   - Use the User1 account