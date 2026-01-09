> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 16 - Preservation

## Objective
This contract (src\levels\16_Preservation\Preservation.sol) utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

The goal of this level is for you to claim ownership of the instance you are given.

  Things that might help

Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain. libraries, and what implications it has on execution scope.
Understanding what it means for delegatecall to be context-preserving.
Understanding how storage variables are stored and accessed.
Understanding how casting works between different data types.

## Challenge Address
```
=> Level address: 0x7ae0655F0Ee1e7752D7C62493CEa1E69A810e2ed
=> Instance address: 0x6D30D9Ac106ec6D80b07171f9C238299Ab495755

```

Following the other CTF pattern, we must create:
1- Attack Contract (src/levels/16_Preservation/PreservationAttacker.sol)
- implement using .env file
2- Deployment Script (script/levels/16_Preservation/PreservationAttacker.s.sol)
3- Execution Steps
4- Documentation (src/levels/16_Preservation/EXPLOIT_REPORT.md)
- Mermaid sequence diagram showing the double call vulnerability
- Explanation of the exploit
- Proof of success
- Fix recommendation (cache the result)

Constraint : use Foundry