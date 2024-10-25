<!-- markdownlint-disable MD022 MD032 MD031 MD040 MD047 -->

# Logistics Platform

## User Accounts

### Admin
- Mnemonic: because isolate ring ethics smart else glimpse hazard leg tower harbor lyrics
- Public Key: 0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea
- Private Key: 0x9a34603def11e329864c45b520dab07e869a3bc7dc9910da310169130f2886e9

### Create three users, two for customers, one for courier, write down their information for testing
#### Customer1
- Mnemonic: mule unhappy three fork network amused blood bicycle fancy sponsor swap cage
- Public Key: 0xd6a81c2feb078f039591c53f2338165e82f0f2a2691531fd52fe7d199a3b0cd8

#### Customer2
- Mnemonic: mule unhappy three fork network amused blood bicycle fancy sponsor swap cage
- Public Key: 0xd6a81c2feb078f039591c53f2338165e82f0f2a2691531fd52fe7d199a3b0cd8

#### Courier
- Mnemonic: knee wild copper kangaroo pass iron plate coffee maximum cost step insect
- Public Key: 0x5394f3b04dbae4b0680677d46f45ea64faf31d5dd47ebb00dc89b55d702c1f6e

## Setup Instructions


1. Install Petra Chrome Wallet
   - Visit the Chrome Web Store
   - Search for "Petra Aptos Wallet"
   - Click "Add to Chrome" to install the extension

2. Set up Petra Wallet
   - Open the Petra wallet
   - Choose "Create new wallet" or "Import existing wallet"
   - Follow the prompts to complete the wallet setup


3. Show Aptos profiles:
   ```
   aptos config show-profiles
   ```

4. Initialize Aptos with default profile:
   ```
   aptos init --profile default --network devnet
   ```
   When prompted, input: 0x9a34603def11e329864c45b520dab07e869a3bc7dc9910da310169130f2886e9

5. Edit the address in `Move.toml`

6. Compile the contract:
   ```
   ./compile_contract.sh --dev
   ```

7. Deploy the contract:
   ```
   ./deploy_contract.sh devnet 0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea
   ```

8. Verify the account initialization:
   Open [Aptos Explorer](https://explorer.aptoslabs.com/account/0x8b0988a046fb22800ea370b3194ade0709861ed987cd978c86ed4fc0709ca2ea?network=devnet)

9. Configure the frontend:
   Edit the `REACT_APP_MOVE_MODULE_ADDRESS` in `dapp/.env` file to the deployed address.

10. Start the frontend:
   ```
   cd dapp
   npm start
   ```

11. Wallet setup:
   - Recover all accounts in Petra wallet
   - Switch to devnet
   - Use the User1 account