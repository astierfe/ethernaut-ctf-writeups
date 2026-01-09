> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 19 - Aliencodex

## Objective
You've uncovered an Alien contract (src\levels\19_AlienCodex\Aliencodex.sol). Claim ownership to complete the level.

  Things that might help

Understanding how array storage works
Understanding ABI specifications
Using a very underhanded approach

## Challenge Address
```
=> Level address: 0x0BC04aa6aaC163A6B3667636D798FA053D43BD11
=> Instance address: 0x013D74D197324c611d070b213D1fAbff165E7B43

```

You must use this plan :
1- Implement Attack Contract (src\levels\19_AlienCodex\AliencodexAttacker.sol) using .env file
2- Deployment Script (script/levels/19_Aliencodex/AliencodexAttacker.s.sol)
3- Deploy and execute attack
4- Documentation (src/levels/19_Aliencodex/EXPLOIT_REPORT.md) 
- Mermaid sequence diagram showing the double call vulnerability
- Explanation of the exploit
- Proof of success
- Fix recommendation (cache the result) :only one recommendation
- 300 lines max.

Constraint : use Foundry
Consider this CTF as unique project. Don't read other CTF levels in this workspace.