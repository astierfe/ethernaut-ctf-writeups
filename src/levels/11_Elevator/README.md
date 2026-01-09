> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Level 11 - Elevator

## Objective
This elevator won't let you reach the top of your building. Right?
Things that might help:
Sometimes solidity is not good at keeping promises.
This Elevator expects to be used from a Building.

Solidity Code : src\levels\11_Elevator\Building.sol

Reach the top floor.

## Challenge Address
```
=> Level address: 0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2
=> Instance address: 0x7326cf985DdB483853E7c03096b63C8F9D84178a

```

Code Solidity: 

## Vulnerability

**Contract callback can change behavior.** The `isLastFloor()` function is called on an external contract you control.

Vulnerable pattern:
```solidity
if (! building.isLastFloor(_floor)) {
    floor = _floor;
    top = false;
} else {
    top = true;
}
```

You can make `isLastFloor()` return different values on different calls!

## Attack Algorithm

1. Deploy attacker contract that implements `Building` interface
2. `isLastFloor()` returns `false` on first call (to pass check)
3. When called again in else block, return `true`
4. Reach top floor

## How to Fix

- Don't rely on untrusted external calls for critical logic
- Cache return values to prevent inconsistent behavior
- Validate state after external calls

## Key Takeaway

External contract calls can return different values. Don't assume consistency.
