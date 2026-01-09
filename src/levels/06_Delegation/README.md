> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 5 - Delegation

## Objective
The goal of this level is for you to claim ownership of the instance you are given.
  Things that might help

Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain libraries, and what implications it has on execution scope.
Fallback methods
Method ids
(Claim ownership via `delegatecall`.)

## Challenge Address
```
0x73379d8B82Fda494ee59555f333DF7D44483fD58
```

Code : src\levels\06_Delegation\Delegation.sol

## Vulnerability

**Delegatecall** changes execution context. The called contract modifies the **caller's state**, not its own.

### Problem Pattern

```solidity
delegatecall(abi.encodeWithSignature("pwn()"))
// pwn() runs in Delegation contract's storage context!
```

If called contract modifies storage slot 0, it modifies caller's slot 0 (owner).

## Attack Algorithm

1. Find the delegated function signature
2. Send transaction with matching signature
3. Delegated contract modifies your state
4. You become owner

## How to Fix

- Avoid delegatecall with untrusted contracts
- Always validate the target contract's state layout
- Use proxy patterns carefully (TransparentProxy, UUPS)

## Key Takeaway

Delegatecall executes code in the caller's context. Storage layout mismatches = state corruption.
