> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 10 - Reentrancy

## Objective
The goal of this level is for you to steal all the funds from the contract (src\levels\10_Reentrancy\Reentrance.sol).

  Things that might help:
Untrusted contracts can execute code where you least expect it.
Fallback methods
Throw/revert bubbling
Sometimes the best way to attack a contract is with another contract.
Drain all Ether from the contract.

## Challenge Address
```
=> Level address: 0x2a24869323C0B13Dff24E196Ba072dC790D52479
=> Instance address: 0x4bdaA92d8b1567BeaaBFc7aB3986fc47688E9a1C
```

## Vulnerability

**Reentrancy attack** - calling back into contract before state updates:

Problem is pragma solidity ^0.6.12 used.
Remix cannot use solidity < 0.8.0
Foundry too

Use web3.js javascript command in chrome console of Ethernaut WebSite


