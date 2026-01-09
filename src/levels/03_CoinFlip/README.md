> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 2 - CoinFlip

## Objective

Build up a winning streak by correctly guessing the outcome of a coin flip **10 times in a row**.

## Challenge Address

```
0xE43E8b748129ab9633e26D08026691E68b0612E7 (Sepolia)
```

## Vulnerability

### Problem

The contract uses `blockhash(block.number - 1)` as the source of randomness to determine coin flip outcomes. This is **completely predictable** because:

1. Block hashes are public data on the blockchain
2. The contract uses the **previous block's hash** (`block.number - 1`)
3. An attacker can calculate the same value **before calling** `flip()`
4. Smart contracts execute in the **same block**, so they see the **same blockhash**

### Why It's Vulnerable

```solidity
// Target contract's logic
uint256 blockValue = uint256(blockhash(block.number - 1));
uint256 coinFlip = blockValue / FACTOR;
bool side = coinFlip == 1 ? true : false;
```

A malicious contract in the **same transaction** can:
- Calculate `blockhash(block.number - 1)` identically
- Know the result **before** calling `flip()`
- Always send the correct guess

## Attack Algorithm

### Step 1: Deploy Attacker Contract

Deploy `CoinFlipAttacker.sol` with the target address as constructor argument.

**Attacker address:** `<YOUR_DEPLOYED_ADDRESS>`

### Step 2: Execute Attack 10 Times

Each attack call must happen in a **different block**:

```
For i = 1 to 10:
  1. Call cheat() on your attacker contract
  2. Wait ~12-15 seconds (1 block on Sepolia)
  3. Verify consecutiveWins increased by 1
  4. Repeat
```

The `cheat()` function will:
1. Calculate `blockhash(block.number - 1)` (same as target)
2. Divide by FACTOR to get the coin side
3. Call `flip()` with the correct prediction
4. Always win because it knows the outcome

### Step 3: Verify Success

```bash
cast call 0xE43E8b748129ab9633e26D08026691E68b0612E7 "consecutiveWins()" --rpc-url $SEPOLIA_RPC_URL
```

Should return `0x0a` (10 in decimal).

### Step 4: Submit on Ethernaut

Visit https://ethernaut.openzeppelin.com/level/3 and click "Submit instance".

## How to Fix

### Solution 1: Commit-Reveal Scheme

```
1. Players submit hash of their guess (commit phase)
2. Multiple blocks pass
3. Players reveal their guess (reveal phase)
4. Smart contract verifies commitment matches reveal
```

The delay between blocks makes `blockhash` values change, preventing prediction.

### Solution 2: Use Chainlink VRF

Integrate [Chainlink Verifiable Randomness Function](https://docs.chain.link/vrf) for cryptographically secure randomness from an oracle.

### Solution 3: Use Block Timestamp + User Input

Combine `block.timestamp` with user-provided entropy, but this is still somewhat predictable for experienced miners.

### Solution 4: Avoid On-Chain Randomness

For games requiring true randomness, use:
- Off-chain randomness generation
- Encrypted/signed commitments
- Oracle services (VRF)

## Key Takeaway

**Never use blockchain state as randomness source.** `blockhash()`, `block.timestamp`, and `nonce` are all deterministic and knowable in advance by anyone with contract execution privileges.
