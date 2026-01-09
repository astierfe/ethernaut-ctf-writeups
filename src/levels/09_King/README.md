> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 9 - King

## Objective
The contract src\levels\09_King\King.sol represents a very simple game: whoever sends it an amount of ether that is larger than the current prize becomes the new king. On such an event, the overthrown king gets paid the new prize, making a bit of ether in the process! As ponzi as it gets xD

Such a fun game. Your goal is to break it.

When you submit the instance back to the level, the level is going to reclaim kingship. You will beat the level if you can avoid such a self proclamation.

(Prevent the king from reclaiming the throne.)

## Challenge Address
```
=> Level address: 0x3049C00639E6dfC269ED1451764a046f7aE500c6
=> Instance address: 0xA898595A93c7ffb76f8F1Ba6AD341c83faD1E3b5
```

## Vulnerability

**Ether can be rejected.** A contract can revert on receive:

```solidity
receive() external payable {
    revert();  // I don't accept Ether!
}
```

If the king tries to send Ether to reclaim, it fails and reverts the entire transaction.

## Attack Algorithm using foundry

1. Deploy a contract that:
   - Has a `receive()` function that reverts
   - Claims the throne by sending > current prize
2. King can never reclaim because refund always fails
3. You permanently hold the throne

## How to Fix

- Handle failed transfers gracefully (pull instead of push)
- Use withdrawal pattern instead of sending directly
- Check return value of send/transfer

## Key Takeaway

Receivers can refuse Ether. Handle payment failures gracefully.
