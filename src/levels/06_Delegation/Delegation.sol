// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    // VULNERABILITY: This function can be called via delegatecall from Delegation contract.
    // When delegatecall executes this, it modifies the CALLER's storage (Delegation contract),
    // not the Delegate's storage!
    // Storage slot 0 of Delegation (owner) becomes msg.sender.
    function pwn() public {
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    // CRITICAL VULNERABILITY: Unprotected fallback function
    // - Accepts ANY call that doesn't match a function signature
    // - delegatecall executes msg.data in the context of THIS contract (Delegation)
    // - This allows calling ANY function from Delegate contract while modifying Delegation's storage

    // WHAT SHOULD HAVE BEEN DONE:
    // 1. Never use delegatecall with untrusted contracts
    // 2. Implement a whitelist of allowed functions
    // 3. Validate storage layout compatibility between contracts
    // 4. Use a secure proxy pattern (TransparentProxy, UUPS) with proper access control
    // 5. Example:
    //    fallback() external {
    //        bytes4 sig = msg.sig;
    //        // Block dangerous functions like pwn()
    //        require(sig != 0x24e235cc, "Function not allowed");
    //        (bool result,) = address(delegate).delegatecall(msg.data);
    //        require(result, "Delegatecall failed");
    //    }
    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}