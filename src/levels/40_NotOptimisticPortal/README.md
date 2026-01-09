> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

This portal relies on a complex chain of cryptographic proofs to verify cross-chain messages. It claims to be secure against invalid state transitions, but the gap between verification and execution might be wider than it looks.

Can you manage to mint some tokens for your wallet?

Things that might help:

- Understanding Function Selectors.
- The Checks-Effects-Interactions (CEI) pattern.
- Merkle Patricia Tries and RLP encoding.

Tips:
Sometimes the data you verify isn't exactly the same data you execute.
If a hash cycle seems impossible to solve, look for a way to break the loop.