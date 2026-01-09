// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/19_AlienCodex/AliencodexAttacker.sol";

/**
 * @title DeployAliencodexAttacker
 * @notice Deployment script for AliencodexAttacker contract
 * @dev Reads target address from ALIENCODEX_TARGET environment variable
 */
contract DeployAliencodexAttacker is Script {
    function run() external {
        // Read target address from .env
        address targetAddress = vm.envAddress("ALIENCODEX_TARGET");

        console.log("========================================");
        console.log("Deploying AliencodexAttacker...");
        console.log("========================================");
        console.log("Target AlienCodex address:", targetAddress);
        console.log("");

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy attacker contract
        AliencodexAttacker attacker = new AliencodexAttacker(targetAddress);

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("========================================");
        console.log("Deployment successful!");
        console.log("========================================");
        console.log("AliencodexAttacker deployed at:", address(attacker));
        console.log("");
        console.log("Next steps:");
        console.log("1. Execute attack:");
        console.log("   cast send", address(attacker), '"attack()"');
        console.log("   --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY");
        console.log("");
        console.log("2. Verify ownership:");
        console.log("   cast call", targetAddress, '"owner()"');
        console.log("   --rpc-url $SEPOLIA_RPC_URL");
        console.log("========================================");
    }
}
