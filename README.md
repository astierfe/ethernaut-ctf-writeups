# Ethernaut CTF - Solidity Security Challenges

> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This repository contains solutions to [Ethernaut CTF](https://ethernaut.openzeppelin.com/) security challenges.
> All techniques are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

A Foundry-based project to solve [Ethernaut](https://ethernaut.openzeppelin.com/) challenges on Sepolia testnet.

## Project Structure

Each level is organized in its own directory:

```
src/levels/
├── 01_Fallback/
│   ├── Fallback.sol           (target contract)
│   ├── FallbackAttacker.sol   (exploit contract)
│   └── README.md              (explanation & algorithm)
├── 02_CoinFlip/
│   ├── CoinFlip.sol
│   ├── CoinFlipAttacker.sol
│   └── README.md
├── 03_Telephone/
└── ... (15 levels total)
```

Each level directory contains:
- **Target contract**: The vulnerable smart contract from Ethernaut
- **Attacker contract**: Your exploit/attack implementation
- **README.md**: Vulnerability analysis and attack algorithm

## Setup

### 1. Configure Environment

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Required variables:
- `SEPOLIA_RPC_URL` - Your Sepolia RPC endpoint
- `PRIVATE_KEY` - Your wallet private key

### 2. Update Target Addresses

Edit `.env` and add Ethernaut instance addresses for each level.

## How to Solve a Level

1. **Read the level README** in `src/levels/NN_LevelName/README.md`
2. **Understand the vulnerability** and attack algorithm
3. **Deploy your attacker contract** with Foundry
4. **Execute the exploit** following the algorithm steps
5. **Verify** completion via `cast call`
6. **Submit** on https://ethernaut.openzeppelin.com/

## Completed Levels

### ✅ Completed (16/31)

- ✅ [03 - CoinFlip](src/levels/03_CoinFlip/README.md) - Predictable randomness
- ✅ [04 - Telephone](src/levels/04_Telephone/README.md) - tx.origin vs msg.sender
- ✅ [05 - Token](src/levels/05_Token/README.md) - Integer underflow
- ✅ [06 - Delegation](src/levels/06_Delegation/README.md) - Delegatecall vulnerability
- ✅ [07 - Force](src/levels/07_Force/README.md) - Forced ether transfer
- ✅ [08 - Vault](src/levels/08_Vault/README.md) - Storage visibility
- ✅ [09 - King](src/levels/09_King/README.md) - Denial of service
- ✅ [10 - Reentrancy](src/levels/10_Reentrancy/README.md) - Reentrancy attack
- ✅ [11 - Elevator](src/levels/11_Elevator/README.md) - Interface manipulation
- ✅ [16 - Preservation](src/levels/16_Preservation/README.md) - Delegatecall storage collision
- ✅ [19 - Alien Codex](src/levels/19_Aliencodex/README.md) - Array underflow
- ✅ [21 - Shop](src/levels/21_Shop/README.md) - View function manipulation
- ✅ [22 - Dex](src/levels/22_Dex/README.md) - DEX price manipulation
- ✅ [23 - Dex Two](src/levels/23_DexTwo/README.md) - Arbitrary token swap
- ✅ [24 - Puzzle Wallet](src/levels/24_PuzzleWallet/REPORT_EXPLOIT.md) - Proxy storage collision
- ✅ [32 - Impersonator](src/levels/32_Impersonator/README.md) - ECDSA signature malleability

### 🚧 In Progress (1)

- 🚧 [40 - Not Optimistic Portal](src/levels/40_NotOptimisticPortal/README.md) - Cross-chain message verification

## Quick Foundry Cheat Sheet

```bash
# Compile
forge build

# Deploy
forge create src/levels/NN_Name/Attack.sol:Attack --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Read state
cast call <address> "function()" --rpc-url $SEPOLIA_RPC_URL

# Send transaction
cast send <address> "function()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

## Important Notes

- All contracts deployed on **Sepolia testnet** only
- Never use these techniques on mainnet without authorization
- This is for educational purposes and authorized security testing
- Keep `.env` private - never commit it

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

These solutions are provided for educational purposes only. The author is not responsible for any misuse of the information contained in this repository. Always obtain proper authorization before testing security vulnerabilities on any system.
