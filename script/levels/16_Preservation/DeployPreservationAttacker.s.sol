// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/16_Preservation/PreservationAttacker.sol";

/**
 * @title DeployPreservationAttacker
 * @notice Deployment script for PreservationAttacker contract
 * @dev Reads target address from PRESERVATION_TARGET environment variable
 */
contract DeployPreservationAttacker is Script {
    function run() external {
        // Read target Preservation contract address from environment variable
        address preservationTarget = vm.envAddress("PRESERVATION_TARGET");

        console.log("Deploying PreservationAttacker to target:", preservationTarget);

        // Deploy the attacker contract
        vm.startBroadcast();
        PreservationAttacker attacker = new PreservationAttacker(preservationTarget);
        vm.stopBroadcast();

        console.log("PreservationAttacker deployed at:", address(attacker));
    }
}
