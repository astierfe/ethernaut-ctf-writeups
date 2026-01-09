> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 8 - Vault

## Objective

Unlock the vault (find the password).

## Challenge Address
```
=> Level address: 0xB7257D8Ba61BD1b3Fb7249DCd9330a023a5F3670
=> Instance address: 0xB43dD192Db629aD3f4D486D82F3251d8fCd831F2
```

Code : src\levels\08_Vault\Vault.sol
use .env for environnement variables

## Vulnerability

**Blockchain is transparent.** Private variables are NOT encrypted.

```solidity
bytes32 private password;  // ❌ Still visible on chain!
```

You can read any storage slot from the blockchain.

## Attack Algorithm

1. Read contract storage at password slot
2. Use cast or ethers.js to query storage
3. Use password to unlock vault

Example:
```bash
cast storage <TARGET_ADDRESS> 1 --rpc-url $SEPOLIA_RPC_URL
```

## How to Fix

- Never store secrets on-chain
- Use encryption for sensitive data
- If needed, hash secrets and store hash only

## Key Takeaway

All contract data is public and readable. The blockchain is transparent.
