> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 21 - Shop

## Objective

Сan you get the item from the shop for less than the price asked?
Things that might help:
Shop expects to be used from a Buyer
Understanding restrictions of view functions

## Challenge Address
```
=> Level address= 0x691eeA9286124c043B82997201E805646b76351a
=> Instance address= 0x3822bC43d96Be12DF77F90BB3bEFc004D5517cd6
```

You must :
1- Implement Solution with direct EOA script Attack (avoid smart contract deployment) with .env file
2- Execute the Attack with script (or deployed attack contract)
3- If attack ok, write report file (src/levels/21_Shop/EXPLOIT_REPORT.md)
- Mermaid sequence diagram showing the double call vulnerability
- Explanation of the exploit
- Proof of success
- Fix recommendation (cache the result) : ONLY ONE recommandation
- Max 400 lines (don't count mermaid code lines)
Constraint !
- The report must be like a story : used "I". 
For example : First I notice... I try this, but it doesn't work that's why I did this ... 
- DO NOT browse or read, directories or files, unless asking me

