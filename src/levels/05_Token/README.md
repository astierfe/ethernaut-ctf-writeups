> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 4 - Token

## Objective

Hack the basic token contract to accumulate tokens.

## Challenge Address

```
0x15D756da0f91Eb44C35cE8F0cbf30c5E2C3df187
```

## Vulnerability

### Problem

**Integer underflow** in token transfer logic.

Vulnerable code pattern:
```solidity
balances[msg.sender] -= _value;  // Can underflow!
balances[_to] += _value;
```

In Solidity < 0.8.0, unsigned integers wrap around:
- `uint(0) - 1 = uint(MAX_VALUE)` (2^256 - 1)

### Why It's Vulnerable

If you have 0 tokens and try to transfer 1 token:
1. `balances[you] -= 1` → underflows to 2^256-1
2. You now have billions of tokens!

Solidity 0.8+ added automatic overflow/underflow checks, but older versions don't.

## Attack Algorithm

### Step 1: Deploy Attacker

Deploy `TokenAttacker.sol` that:
```
1. Transfer 1 token to a contract
2. Attacker balance: 0 → 2^256 - 1 (from underflow)
```

### Step 2: Verify Balance

```bash
cast call <TARGET_ADDRESS> "balanceOf(<YOUR_ADDRESS>)" --rpc-url $SEPOLIA_RPC_URL
```

Should be very large (nearly 2^256).

## How to Fix

### Solution 1: Use SafeMath (Solidity < 0.8)

```solidity
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

balances[msg.sender] = balances[msg.sender].sub(_value);
```

### Solution 2: Use Solidity 0.8+ (Automatic Checks)

```solidity
pragma solidity ^0.8.0;
// Overflow/underflow automatically reverts
```

### Solution 3: Manual Checks

```solidity
require(balances[msg.sender] >= _value, "Insufficient balance");
balances[msg.sender] -= _value;
```

## Key Takeaway

Always validate arithmetic operations, especially with tokens. Use checked math libraries or Solidity 0.8+.
