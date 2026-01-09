// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/09_King/KingAttacker.sol";

/**
 * @title DeployKingAttacker
 * @notice Deployment script for the KingAttacker contract
 */
contract DeployKingAttacker is Script {
    function run() external {
        // Read the target King contract address from environment
        address kingTarget = vm.envAddress("KING_TARGET");

        console.log("Deploying KingAttacker to target:", kingTarget);

        // Deploy the attacker contract
        vm.startBroadcast();
        KingAttacker attacker = new KingAttacker(kingTarget);
        vm.stopBroadcast();

        console.log("KingAttacker deployed at:", address(attacker));
    }
}
