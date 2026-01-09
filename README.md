# Ethernaut CTF - Security Learning Writeups

> **⚠️ EDUCATIONAL & RESEARCH PURPOSE ONLY**
>
> This repository documents solutions to the official [Ethernaut CTF](https://ethernaut.openzeppelin.com/) security challenges by OpenZeppelin.
> These are **authorized CTF challenges** designed for educational purposes and security research.
>
> All code is for **learning and authorized testing environments only**.
> **DO NOT** use these techniques on systems you don't own or without explicit authorization.

---

## About Ethernaut

[Ethernaut](https://ethernaut.openzeppelin.com/) is an official Web3/Solidity security training platform created by OpenZeppelin. It teaches smart contract security through hands-on Capture The Flag (CTF) challenges on Ethereum testnets.

This repository contains my personal solutions and writeups for learning purposes.

## Project Structure

Each challenge is organized in its own directory with complete documentation:

```
src/levels/
├── 03_CoinFlip/
│   ├── CoinFlip.sol              (challenge contract)
│   ├── CoinFlipSolution.sol      (solution implementation)
│   └── README.md                 (writeup & analysis)
├── 04_Telephone/
│   ├── Telephone.sol
│   ├── TelephoneSolution.sol
│   └── README.md
└── ... (17 challenges total)
```

**Each challenge folder contains:**
- 📄 Challenge contract from Ethernaut
- 💡 Solution contract (proof of concept)
- 📝 Detailed writeup explaining the security concept

## Environment Setup

### 1. Install Dependencies

This project uses [Foundry](https://book.getfoundry.sh/getting-started/installation) for Solidity development.

```bash
# Install Foundry (if not already installed)
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your values
```

Required configuration:
- `SEPOLIA_RPC_URL` - Sepolia testnet RPC endpoint
- `PRIVATE_KEY` - Your test wallet private key (⚠️ never use real funds)
- `ETHERSCAN_API_KEY` - For contract verification (optional)

### 3. Compile Contracts

```bash
forge build
```

## Completed Challenges

### ✅ Solved (16/31)

| # | Challenge | Security Concept |
|---|-----------|-----------------|
| 03 | [CoinFlip](src/levels/03_CoinFlip/README.md) | Predictable randomness |
| 04 | [Telephone](src/levels/04_Telephone/README.md) | tx.origin vs msg.sender |
| 05 | [Token](src/levels/05_Token/README.md) | Integer underflow |
| 06 | [Delegation](src/levels/06_Delegation/README.md) | Delegatecall context |
| 07 | [Force](src/levels/07_Force/README.md) | Forced ether transfer |
| 08 | [Vault](src/levels/08_Vault/README.md) | Storage visibility |
| 09 | [King](src/levels/09_King/README.md) | Denial of service |
| 10 | [Reentrancy](src/levels/10_Reentrancy/README.md) | Reentrancy pattern |
| 11 | [Elevator](src/levels/11_Elevator/README.md) | Interface manipulation |
| 16 | [Preservation](src/levels/16_Preservation/README.md) | Storage collision |
| 19 | [Alien Codex](src/levels/19_Aliencodex/README.md) | Array underflow |
| 21 | [Shop](src/levels/21_Shop/README.md) | View function side effects |
| 22 | [Dex](src/levels/22_Dex/README.md) | DEX price manipulation |
| 23 | [Dex Two](src/levels/23_DexTwo/README.md) | Swap validation |
| 24 | [Puzzle Wallet](src/levels/24_PuzzleWallet/REPORT_EXPLOIT.md) | Proxy storage |
| 32 | [Impersonator](src/levels/32_Impersonator/README.md) | ECDSA malleability |

### 🚧 In Progress (1)

- 🚧 [40 - Not Optimistic Portal](src/levels/40_NotOptimisticPortal/README.md) - Cross-chain verification

## Learning Path

### For Each Challenge:

1. **Study** the challenge README and contract code
2. **Analyze** the security concept being demonstrated
3. **Review** the solution implementation
4. **Test** on Sepolia testnet
5. **Submit** your solution on https://ethernaut.openzeppelin.com/

### Useful Foundry Commands

```bash
# Build all contracts
forge build

# Run tests
forge test

# Deploy a contract
forge create src/levels/XX_Name/Solution.sol:Solution \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

# Call a view function
cast call <contract_address> "functionName()" --rpc-url $SEPOLIA_RPC_URL

# Send a transaction
cast send <contract_address> "functionName()" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

## Security Research Context

This repository is part of Web3 security research and education. All challenges are:

✅ Official CTF platform by OpenZeppelin
✅ Designed for learning smart contract security
✅ Run on testnets with no real value
✅ Open and authorized for educational purposes

## Important Guidelines

- 🧪 **Testnet Only**: All solutions work on Sepolia testnet exclusively
- 📚 **Learning**: Focus is on understanding security patterns
- 🔒 **Ethics**: Never apply these techniques without authorization
- 🚫 **No Real Funds**: Never use private keys with real assets

## Resources

- [Ethernaut Official Platform](https://ethernaut.openzeppelin.com/)
- [OpenZeppelin Security](https://www.openzeppelin.com/security-audits)
- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

**Educational Use Only**: These solutions are provided strictly for educational purposes as part of authorized CTF challenges. The author assumes no responsibility for any misuse. Always obtain proper authorization before security testing any system.

This repository documents personal learning progress through the official Ethernaut CTF platform. All techniques shown are part of authorized security training exercises.
