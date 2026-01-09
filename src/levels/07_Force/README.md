> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 7 - Force

## Objective
Some contracts will simply not take your money ¯\_(ツ)_/¯
The goal of this level is to make the balance of the contract greater than zero.
  Things that might help:
Fallback methods
Sometimes the best way to attack a contract is with another contract.
See the "?" page above, section "Beyond the console"

Make the contract accumulate Ether.

## Challenge Address
```
Level address: 0xb6c2Ec883DaAac76D8922519E63f875c2ec65575
Level Instance: 0xADc24D6a4e1620bC78fcb24b6b210ACA27a9D424
```

## Vulnerability

**You can force Ether into any contract** using `selfdestruct()`:

```solidity
selfdestruct(payable(target))
// Sends this contract's Ether to target, even if it has no payable function!
```

### Why It's Vulnerable

No contract can prevent receiving Ether via:
- `selfdestruct()` (transfers balance forcefully)
- Mining rewards (validators can include code execution)

## Attack Algorithm

1. Create a contract with Ether
2. Call `selfdestruct(target_address)`
3. All Ether transferred immediately

## How to Fix

- Don't assume exact Ether balance
- Don't use strict balance checks: `balance == expected` ❌
- Use `balance >= expected` ✅
- Be careful with withdrawal patterns

## Key Takeaway

Ether can be forced into contracts. Never assume balance consistency.
