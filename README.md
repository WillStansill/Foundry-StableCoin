# 🏦 Decentralized StableCoin (DSC)

## Overview
The **Decentralized StableCoin (DSC)** is a stable and secure cryptocurrency backed by Ethereum and Bitcoin. It maintains a peg to USD through dynamic minting, burning, and liquidation mechanisms. The project integrates advanced DeFi principles to ensure system solvency and security.

## 🚀 Features
- **Collateral Management**: Deposit ETH/BTC to mint DSC tokens.
- **Health Factor Calculations**: Ensures stability and prevents undercollateralization.
- **Liquidation Mechanism**: Automatic liquidation with a 10% bonus for liquidators.
- **Dynamic Minting & Burning**: Adjusts supply based on collateralization ratios.
- **Interoperability**: Configurable for mainnet, testnet, and local deployment.
- **Robust Security**: Fuzz testing and invariant testing using Foundry.

## 🛠 Tech Stack
- **Smart Contracts**: Solidity, OpenZeppelin
- **Frameworks**: Foundry, Forge-Std
- **Blockchain & Oracles**: Ethereum, Bitcoin, Chainlink

## 📂 Project Structure
```
DSC-Project/
│── contracts/           # Core Solidity contracts
│── script/              # Deployment scripts
│── test/                # Foundry test cases
│── forge-config.toml    # Foundry configuration
│── Makefile             # Streamlined deployment process
│── README.md            # Project documentation
```

## 🏗 Deployment Guide
### **1️⃣ Clone the Repository**
```bash
git clone https://github.com/yourusername/dsc-project.git
cd dsc-project
```
### **2️⃣ Install Dependencies**
```bash
forge install
```
### **3️⃣ Run Tests**
```bash
forge test --fuzz-runs 1000
```
### **4️⃣ Deploy Contracts**
```bash
forge script script/Deploy.s.sol --rpc-url <NETWORK_RPC> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

## 🔬 Testing & Security
- **Foundry Testing**: Comprehensive unit and integration tests.
- **Fuzz Testing**: Randomized input testing to ensure contract robustness.
- **Invariant Testing**: Ensures system maintains stability under all conditions.

## 📬 Contact
📧 Email: willstansill@gmail.com  
💼 LinkedIn: [linkedin.com/in/will-stansill](https://linkedin.com/in/will-stansill)  
🐙 GitHub: [github.com/yourusername](https://github.com/WillStansill)

---
**Decentralized finance with security and reliability.** 🔗
