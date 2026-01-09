> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 22 - DEX

## Objective

The goal of this level is for you to hack the basic DEX contract below and steal the funds by price manipulation.

You will start with 10 tokens of token1 and 10 of token2. The DEX contract starts with 100 of each token.

You will be successful in this level if you manage to drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a "bad" price of the assets.

## Quick note ##
Normally, when you make a swap with an ERC20 token, you have to approve the contract to spend your tokens for you. To keep with the syntax of the game, we've just added the approve method to the contract itself. So feel free to use contract.approve(contract.address, <uint amount>) instead of calling the tokens directly, and it will automatically approve spending the two tokens by the desired amount. Feel free to ignore the SwappableToken contract otherwise.

  Things that might help:

How is the price of the token calculated?
How does the swap method work?
How do you approve a transaction of an ERC20?
Theres more than one way to interact with a contract!
Remix might help
What does "At Address" do?

## Challenge Address
```
=> Level address= 0xB468f8e42AC0fAe675B56bc6FDa9C0563B61A52F
=> Instance address= 0x8B41962BE31F1FB753f443C2d4aD8c8634c5f2f7

```

You must :
1- Implement Attack Contract (src/levels/22_Dex/DexAttacker.sol) using .env file if needed
2- Implement Script (script/levels/22_Dex/DexAttacker.s.sol) using .env file if needed
3- Execute the Attack
If Attaque Ok else return 
4- Documentation (src/levels/16_Preservation/EXPLOIT_REPORT.md)
- Mermaid sequence diagram showing the double call vulnerability
- Explanation of the exploit
- Proof of success
- Fix recommendation (cache the result) : only one recommandation
- Max 400 lines (don't count mermaid code lines)
The report must be like a story : used "I". 
For example : First I notice... I try this, but it doesn't work that's why I did this ... 

