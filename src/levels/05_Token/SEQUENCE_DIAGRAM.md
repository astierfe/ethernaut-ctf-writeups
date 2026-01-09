> **⚠️ EDUCATIONAL PURPOSE ONLY**
> This document is part of the [Ethernaut CTF](https://ethernaut.openzeppelin.com/) educational security challenges.
> The techniques described here are for **authorized security testing and learning purposes only**.
> **DO NOT** use these methods on contracts you don't own or without explicit authorization.

---

# Token Overflow Exploit - Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant TokenExploit
    participant Token
    participant Blockchain as State (balances mapping)

    User->>TokenExploit: deploy(tokenAddress)
    TokenExploit->>Token: (référence Token contract)

    Note over User,Blockchain: Initial state: User has 20 tokens

    User->>TokenExploit: exploit(targetAddress)
    TokenExploit->>Token: transfer(targetAddress, 21)

    Note over Token: balances[msg.sender] = 20 (TokenExploit)<br/>_value = 21

    Token->>Token: Check: 20 - 21 >= 0 ?

    Note over Token: uint256 underflow!<br/>20 - 21 = -1 en int<br/>= 2^256 - 1 en uint256<br/>= 115792089237316195423570985008687907853269984665640564039457584007913129639935

    Token->>Token: ✓ Check passes (huge number >= 0)

    Token->>Blockchain: balances[TokenExploit] -= 21
    Note over Blockchain: 20 - 21 = 2^256 - 1 (MASSIVE!)

    Token->>Blockchain: balances[targetAddress] += 21
    Note over Blockchain: Previous balance + 21

    Token-->>TokenExploit: return true

    Note over User,Blockchain: Exploit Success!<br/>TokenExploit now has 2^256 - 1 tokens
```

## Explication de la faille

**Le problème** : `require(balances[msg.sender] - _value >= 0)`

En Solidity 0.6.0, `uint256` ne peut pas représenter les nombres négatifs. Quand tu soustrais un nombre plus grand d'un plus petit :
- `20 - 21` wraparound → `2^256 - 1` (un énorme nombre positif)
- La condition `require()` passe car c'est un énorme nombre positif ≥ 0
- Les balances sont mises à jour avec ce nombre gigantesque

**Résultat** : Tu passes de 20 tokens à `115792089237316195423570985008687907853269984665640564039457584007913129639935` tokens ✨
